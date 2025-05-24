extends Node2D

var min_r = 15
var min_c = 7
var min_diff = 2
var grid_size = 6
var cell_size = 64
var prev_r = 15
var prev_c = 7

var max_score: int
var current_score = 0
var coin_scene = preload("res://entities/Coin/Coin.tscn")
var rng = RandomNumberGenerator.new()

@onready var player = $Player
@onready var hScoreLabel = $HighScore
@onready var scoreLabel = $Score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_score = SaveLoad.load_highscore()
	_create_coin()
	
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
	current_score += value
	if current_score > max_score:
		max_score = current_score
		SaveLoad.save_highscore(max_score)
	print(current_score)
	print(max_score)
	scoreLabel.text = str(current_score)
	hScoreLabel.text = str(max_score)
	_create_coin()
