extends Node2D

# Constants for swipe detection
const SWIPE_THRESHOLD = 50  # Minimum distance for a swipe to be recognized
const HOLD_THRESHOLD = 0.2  # Minimum time in seconds for a hold to be recognized

# Signals for swipe and hold gestures
signal swipe_detected(direction)
signal hold_detected(direction)
signal release_detected()

# Variables to track touch state
var touch_start_position = Vector2()
var touch_start_time = 0.0
var prev_dir = null
var is_holding = false

func _ready():
	# Enable input processing
	set_process_input(true)

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			# Touch started
			touch_start_position = event.position
			touch_start_time = Time.get_ticks_msec() / 1000.0
			is_holding = true
		else:
			# Touch ended
			var touch_end_position = event.position
			var touch_duration = (Time.get_ticks_msec() / 1000.0) - touch_start_time
			is_holding = false
			prev_dir = null
			emit_signal("release_detected")

			# Check for swipe
			var swipe_vector = touch_end_position - touch_start_position
			if swipe_vector.length() >= SWIPE_THRESHOLD:
				var direction = get_swipe_direction(swipe_vector)
				emit_signal("swipe_detected", direction)

	elif event is InputEventScreenDrag and is_holding:
		# Update hold state if dragging
		var touch_end_position = event.position
		var current_position = event.position
		var swipe_vector = touch_end_position - touch_start_position
		if (Time.get_ticks_msec() / 1000.0) - touch_start_time >= HOLD_THRESHOLD:
			var direction = get_swipe_direction(swipe_vector)
			if direction != prev_dir:
				emit_signal("hold_detected", direction)
				prev_dir = direction
			#touch_start_position = touch_end_position
			#is_holding = false  # Prevent multiple hold signals

func get_swipe_direction(swipe_vector: Vector2) -> String:
	# Determine the direction of the swipe
	if abs(swipe_vector.x) > abs(swipe_vector.y):
		return "right" if swipe_vector.x > 0 else "left"
	else:
		return "down" if swipe_vector.y > 0 else "up"
