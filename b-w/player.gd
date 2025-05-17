extends Area2D

var animation_speed = 5
var tile_size = 64
var moving = false
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}
			
			
@onready var ray = $RayCast2D

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func _physics_process(delta: float) -> void:
	for key in inputs.keys():
		if Input.is_action_pressed(key):
			handle_dir(key)
			
func handle_dir(dir):
	if moving:
		return
	move(dir)

func move(dir):
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + inputs[dir] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		#$AnimationPlayer.play(dir)
		await tween.finished
		moving = false
