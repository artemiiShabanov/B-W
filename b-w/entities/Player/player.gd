extends CharacterBody2D

signal will_move(from_position)

var animation_speed = 5
var fast_animation_speed = 10
var tile_size = 64
var moving = false
var inputs = {"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN}
			
			
@onready var ray = $RayCast2D
@onready var track_ray = $TrackRayCast2D
@onready var whoosh_sound = $WhooshSound
@onready var tick_sound = $TickSound
@onready var anim = $AnimatedSprite2D

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	anim.play("stale")
	
#func _input(event):
	#for key in inputs.keys():
		#if Input.is_action_just_pressed(key):
			#track_ray.target_position = inputs[key] * tile_size
			#track_ray.force_raycast_update()
			#if track_ray.is_colliding():
				#handle_dir(key, true)
			#else:
				#handle_dir(key, false)

func _physics_process(delta: float) -> void:
	for key in inputs.keys():
		if Input.is_action_pressed(key):
			track_ray.target_position = inputs[key] * tile_size
			track_ray.force_raycast_update()
			if track_ray.is_colliding():
				handle_dir(key, true)
			else:
				handle_dir(key, false)

func handle_dir(dir, fast):
	if moving:
		return
	move(dir, fast)

func move(dir, fast):
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		moving = true
		if fast:
			tick_sound.pitch_scale = 1.5
		else:
			tick_sound.pitch_scale = 1
		tick_sound.play()
		if !fast:
			anim.play("transition")
			await anim.animation_finished
		if anim.animation != dir:
			anim.play(dir)
		will_move.emit(global_position)
		var tween = get_tree().create_tween()
		var new_pos = position + inputs[dir] * tile_size
		var time = 1.0 / (fast_animation_speed if fast else animation_speed)
		tween.tween_property(self, "position", new_pos, time).set_trans(Tween.TRANS_SINE)
		await tween.finished
		moving = false
		if !fast:
			anim.play("r_transition")
			await anim.animation_finished
		anim.play("stale")
		
