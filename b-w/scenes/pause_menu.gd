extends Control

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	visible = false
	
func pause():
	visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
