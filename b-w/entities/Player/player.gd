extends CharacterBody2D

signal will_move(from_position)

var tile_size = 64

var animation_speed = 5
var fast_animation_speed = 10

var inputs = {"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN}
var states = {"right": State.RIGHT,
	"left": State.LEFT,
	"up": State.UP,
	"down": State.DOWN}
	
var animations = {State.RIGHT: "right",
	State.LEFT: "left",
	State.UP: "up",
	State.DOWN: "down",
	State.STALE: "stale",
	State.TRANSITION: "transition",
	State.RTRANSITION: "r_transition"}

enum State {STALE, TRANSITION, RTRANSITION, LEFT, UP, RIGHT, DOWN}

var _state: State = State.STALE
var state: State:
	get:
		return _state
	set(value):
		_state = value
		anim.play(animations[value])

var sliding_dir_input = null
var is_sliding = false

@onready var ray = $RayCast2D
@onready var track_ray = $TrackRayCast2D
@onready var whoosh_sound = $WhooshSound
@onready var anim = $AnimatedSprite2D

func _ready():
	# set initial position
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

# keyboard input
func _input(event):
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			step(dir)

func _physics_process(delta: float) -> void:
	if !is_sliding && sliding_dir_input != null:
		await slide(sliding_dir_input)

func _on_touch_handler_hold_detected(dir: Variant) -> void:
	sliding_dir_input = dir

func _on_touch_handler_swipe_detected(dir: Variant) -> void:
	step(dir)

func _on_touch_handler_release_detected() -> void:
	if sliding_dir_input != null:
		sliding_dir_input = null
		stop_slide()

func step(dir):
	is_sliding = true
	if state != State.STALE || !can_move_in(dir):
		is_sliding = false
		return
	
	state = State.TRANSITION
	await anim.animation_finished
	
	state = states[dir]
	await move(dir, false)
	
	state = State.RTRANSITION
	await anim.animation_finished
	
	state = State.STALE
	is_sliding = false

func slide(dir):
	if !can_move_in(dir) || !check_ray(track_ray, dir):
		return
	is_sliding = true
	if ![State.LEFT, State.RIGHT, State.UP, State.DOWN].has(state):
		state = State.TRANSITION
		await anim.animation_finished
	if states[dir] != state:
		state = states[dir]
	
	await move(dir, true)
	is_sliding = false
	
func stop_slide():
	if ![State.LEFT, State.RIGHT, State.UP, State.DOWN].has(state):
		return
	state = State.RTRANSITION
	await anim.animation_finished
	
	state = State.STALE

func can_move_in(dir) -> bool:
	return !check_ray(ray, dir)
	
func check_ray(ray, dir) -> bool:
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	return ray.is_colliding()

func move(dir, fast):
	# sound
	if fast:
		whoosh_sound.pitch_scale = 0.8
	else:
		whoosh_sound.pitch_scale = 0.6
	whoosh_sound.play()
	
	# position
	will_move.emit(position)
	var tween = get_tree().create_tween()
	var new_pos = position + inputs[dir] * tile_size
	var time = 1.0 / (fast_animation_speed if fast else animation_speed)
	tween.tween_property(self, "position", new_pos, time).set_trans(Tween.TRANS_SINE)
	await tween.finished
