extends Node2D

var min_r = 14
var min_c = 6
var prev_r = 0
var prev_c = 0
var min_diff = 3
var grid_size = 6
var cell_size = 64
var rare_chance = 0.05
var life_chance = 0.05
var uncommon_chance = 0.1

var restricted_pos = []

var columns_layouts = [
	[Vector2(2, 2), Vector2(2, 3), Vector2(3, 3), Vector2(3, 2)],
	[Vector2(1, 1), Vector2(1, 4), Vector2(4, 1), Vector2(4, 4)],
	[Vector2(1, 1), Vector2(1, 4), Vector2(3, 3), Vector2(3, 2)],
	[Vector2(4, 1), Vector2(4, 4), Vector2(2, 3), Vector2(2, 2)],
	[Vector2(4, 1), Vector2(1, 1), Vector2(2, 3), Vector2(3, 3)],
	[Vector2(4, 4), Vector2(1, 4), Vector2(3, 2), Vector2(2, 2)]
]

#var heart_image = load("res://assets/h.jpg")

var timer_progression = 0.1

var max_score: int
var current_score = 0
var health = 3
var max_health = 3

#var is_slow_mo = false
#var clow_mo_timer

var coin_scene = preload("res://entities/Coin/Coin.tscn")
var track_scene = preload("res://entities/Track/Track.tscn")
var wall_scene = preload("res://entities/Wall/Wall.tscn")

var rng = RandomNumberGenerator.new()

@onready var player = $Player
@onready var hScoreLabel = $HighScore
@onready var scoreLabel = $Score
@onready var healthLabel = $HealthLabel
@onready var progress_bar = $ProgressBar
@onready var timer = $Timer
@onready var healthStack = $HealthContainer
@onready var bgMusic = $BGMusic
@onready var grain = $FilmGrain
@onready var palyer_light = $Player/PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_score = SaveLoad.load_highscore()
	_update_lives()
	_generate_walls()
	_generate_columns()
	_create_coin()
	bgMusic.play()
	grain.z_index = 1000
	
func _process(delta):
	progress_bar.value = timer.time_left / timer.wait_time * 100
	
func _generate_walls() -> void:
	# up
	for c in range(-1, grid_size + 1):
		var w = wall_scene.instantiate()
		w.position = pos(c, -1)
		add_child(w)
	# left
	for r in range(0, grid_size + 1):
		var w = wall_scene.instantiate()
		w.position = pos(-1, r)
		add_child(w)
	# right
	for r in range(0, grid_size + 1):
		var w = wall_scene.instantiate()
		w.position = pos(grid_size, r)
		add_child(w)
	# down
	for c in range(0, grid_size):
		var w = wall_scene.instantiate()
		w.position = pos(c, grid_size)
		add_child(w)
		
func _generate_columns() -> void:
	var l = columns_layouts.pick_random()
	restricted_pos.append_array(l)
	for v in l:
		var w = wall_scene.instantiate()
		w.position = pos(v.x, v.y)
		add_child(w)
	
func _create_coin() -> void:
	var coin = coin_scene.instantiate()
	if health < max_health && rng.randf() > (1 - life_chance):
		coin.type = Coin.Type.LIFE
	elif current_score == 0:
		coin.type = Coin.Type.REGULAR
	elif rng.randf() > (1 - rare_chance):
		coin.type = Coin.Type.RARE
	elif rng.randf() > (1 - uncommon_chance):
		coin.type = Coin.Type.UNCOMMON
	else:
		coin.type = Coin.Type.REGULAR
	
	var r = prev_r
	var c = prev_c
	while (abs(prev_r - r) < min_diff && abs(prev_c - c) < min_diff) || restricted_pos.has(Vector2(c, r)):
		c = rng.randi_range(0, grid_size - 1)
		r = rng.randi_range(0, grid_size - 1)
	coin.position = pos(c, r)
	prev_c = c
	prev_r = r
	
	coin.eaten.connect(self._on_coin_eaten)
	add_child(coin)

func pos(c, r) -> Vector2:
	var x = (min_c + c) * cell_size - cell_size / 2
	var y = (min_r + r) * cell_size - cell_size / 2
	return Vector2(x, y)

func _on_coin_eaten(value: int) -> void:
	bgMusic.volume_db = 0
	if value == -1:
		health += 1
		_update_lives()
	else:
		current_score += value
		if current_score > max_score:
			max_score = current_score
			SaveLoad.save_highscore(max_score)
		scoreLabel.text = str(current_score)
		hScoreLabel.text = str(max_score)
	
	_create_coin()
	timer.wait_time = timer.wait_time - timer_progression
	timer.start()


func _on_timer_timeout() -> void:
	health -= 1
	bgMusic.volume_db = -15
	_update_lives()

func _update_lives() -> void:
	healthLabel.text = str(health)
	#for ch in healthStack.get_children():
		#healthStack.remove_child(ch)
	#for i in health:
		#var texture = ImageTexture.new()
		#var heart_image = Image.new()
		#heart_image.load("res://assets/h.jpg")
		#texture.create_from_image(heart_image)
		#var tr = TextureRect.new()
		#tr.texture = texture
		#healthStack.add_child(tr)


func _on_player_will_move(from_position: Variant) -> void:
	for node in get_children():
		if node is Track && node.position == from_position:
			node.queue_free()
	var track = track_scene.instantiate()
	track.position = from_position
	add_child(track)
