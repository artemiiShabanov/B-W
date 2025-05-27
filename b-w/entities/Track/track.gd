extends Area2D
class_name Track

@onready var timer = $Timer
@onready var light = $Timer

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($PointLight2D, "energy", 0, timer.wait_time)

func _on_timer_timeout() -> void:
	queue_free()
