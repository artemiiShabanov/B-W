extends Area2D
class_name Coin

enum Type {REGULAR = 50, UNCOMMON = 3, RARE = 10}

signal eaten(value)

@onready var anim = $AnimatedSprite2D
@export var type: Type = Type.REGULAR

func _ready() -> void:
	match type:
		Type.REGULAR:
			anim.play("Regular")
		Type.UNCOMMON:
			anim.play("Uncommon")
		Type.RARE:
			anim.play("Rare")

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player":
		eaten.emit(type)
		anim.play("Collected")
		await anim.animation_finished
		queue_free()
