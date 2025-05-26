extends Node2D

var min_r = 15
var min_c = 7
var min_diff = 2
var grid_size = 6
var cell_size = 64
var prev_r = 15
var prev_c = 7

#var heart_image = load("res://assets/h.jpg")

var timer_progression = 0.1

var max_score: int
var current_score = 0
var health = 3

#var is_slow_mo = false
#var clow_mo_timer

var coin_scene = preload("res://entities/Coin/Coin.tscn")
var track_scene = preload("res://entities/Track/Track.tscn")

var rng = RandomNumberGenerator.new()

@onready var player = $Player
@onready var hScoreLabel = $HighScore
@onready var scoreLabel = $Score
@onready var healthLabel = $HealthLabel
@onready var progress_bar = $ProgressBar
@onready var timer = $Timer
@onready var healthStack = $HealthContainer
@onready var bgMusic = $BGMusic

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_score = SaveLoad.load_highscore()
	_update_lives()
	_create_coin()
	bgMusic.play()
	
func _process(delta):
	progress_bar.value = timer.time_left / timer.wait_time * 100
	
func _create_coin() -> void:
	var coin = coin_scene.instantiate()
	if rng.randf() > 0.9:
		coin.type = Coin.Type.RARE
	elif rng.randf() > 0.5:
		coin.type = Coin.Type.UNCOMMON
	else:
		coin.type = Coin.Type.REGULAR
	
	var r = prev_r
	var c = prev_c
	while abs(prev_r - r) < min_diff && abs(prev_c - c) < min_diff:
		r = rng.randi_range(min_r, min_r + grid_size - 1)
		c = rng.randi_range(min_c, min_c + grid_size - 1)
	var x = (c - 1) * cell_size - cell_size / 2
	var y = (r - 1) * cell_size - cell_size / 2
	coin.position = Vector2(x, y)
	prev_r = r
	prev_c = c
	
	coin.eaten.connect(self._on_coin_eaten)
	add_child(coin)

func _on_coin_eaten(value: int) -> void:
	bgMusic.pitch_scale = 1
	current_score += value
	if current_score > max_score:
		max_score = current_score
		SaveLoad.save_highscore(max_score)
	print(current_score)
	print(max_score)
	scoreLabel.text = str(current_score)
	hScoreLabel.text = str(max_score)
	_create_coin()
	
	timer.wait_time = timer.wait_time - timer_progression
	timer.start()


func _on_timer_timeout() -> void:
	health -= 1
	bgMusic.pitch_scale = 0.5
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
	var track = track_scene.instantiate()
	track.position = from_position
	add_child(track)
