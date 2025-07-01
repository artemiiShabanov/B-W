extends Node2D

signal changed_paused_state(paused)

var paused = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		paused = !paused
		changed_paused_state.emit(paused)
