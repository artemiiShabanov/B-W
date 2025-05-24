extends Area2D
class_name Track

@onready var timer = $Timer
@onready var sprite = $Sprite2D

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 1)

func _on_timer_timeout() -> void:
	queue_free()
