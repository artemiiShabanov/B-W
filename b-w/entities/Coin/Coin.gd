extends Area2D
class_name Coin

enum Type {LIFE = -1, REGULAR = 1, UNCOMMON = 3, RARE = 10}

signal eaten(value)

@onready var anim = $AnimatedSprite2D
@onready var sound = $Sound
@export var type: Type = Type.REGULAR
var was_eaten = false

func _ready() -> void:
	match type:
		Type.REGULAR:
			anim.play("Regular")
		Type.UNCOMMON:
			anim.play("Uncommon")
		Type.RARE:
			anim.play("Rare")
		Type.LIFE:
			anim.play("Life")

func _on_body_entered(body: Node2D) -> void:
	if was_eaten:
		return
	sound.play()
	if body.name == "Player":
		eaten.emit(type)
		was_eaten = true
		anim.play("Collected")
		await anim.animation_finished
		queue_free()
