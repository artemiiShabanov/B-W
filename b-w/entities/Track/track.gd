extends Area2D
class_name Track

@onready var timer = $Timer
@export var timeout: float = 5

func _ready() -> void:
	timer.wait_time = timeout
	timer.start()
	var tween = get_tree().create_tween()
	tween.tween_property($PointLight2D, "energy", 0, timer.wait_time)

func _on_timer_timeout() -> void:
	queue_free()
