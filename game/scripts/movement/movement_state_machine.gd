class_name MovementStateMachine
extends Node

signal state_changed(previous_state: MovementState, current_state: MovementState)
signal landed(landing_state: MovementState, impact_speed: float)

enum MovementState {
	IDLE,
	WALKING,
	JOGGING,
	SPRINTING,
	JUMPING,
	RISING,
	FALLING,
	SOFT_LANDING,
	HARD_LANDING,
}

const STATE_NAMES: PackedStringArray = [
	"idle",
	"walking",
	"jogging",
	"sprinting",
	"jumping",
	"rising",
	"falling",
	"soft_landing",
	"hard_landing",
]

var current_state := MovementState.IDLE
var previous_state := MovementState.IDLE
var last_landing_state := MovementState.IDLE
var last_landing_impact_speed := 0.0
var landing_recovery_remaining := 0.0
var transition_count := 0
var jump_count := 0
var landing_count := 0
var visited_state_mask := 1 << MovementState.IDLE
var _jumping_state_remaining := 0.0


func reset() -> void:
	current_state = MovementState.IDLE
	previous_state = MovementState.IDLE
	last_landing_state = MovementState.IDLE
	last_landing_impact_speed = 0.0
	landing_recovery_remaining = 0.0
	transition_count = 0
	jump_count = 0
	landing_count = 0
	visited_state_mask = 1 << MovementState.IDLE
	_jumping_state_remaining = 0.0


func begin_jump(tuning: MovementTuning) -> void:
	jump_count += 1
	landing_recovery_remaining = 0.0
	_jumping_state_remaining = tuning.jumping_state_time
	_set_state(MovementState.JUMPING)


func register_landing(impact_speed: float, tuning: MovementTuning) -> void:
	landing_count += 1
	last_landing_impact_speed = maxf(0.0, impact_speed)
	if impact_speed >= tuning.hard_landing_speed:
		last_landing_state = MovementState.HARD_LANDING
		landing_recovery_remaining = tuning.hard_landing_recovery
		_set_state(MovementState.HARD_LANDING)
	elif impact_speed >= tuning.soft_landing_speed:
		last_landing_state = MovementState.SOFT_LANDING
		landing_recovery_remaining = tuning.soft_landing_recovery
		_set_state(MovementState.SOFT_LANDING)
	else:
		last_landing_state = MovementState.IDLE
		landing_recovery_remaining = 0.0
	emit_signal(&"landed", last_landing_state, last_landing_impact_speed)


func update_state(
	grounded: bool,
	vertical_velocity: float,
	horizontal_speed: float,
	move_strength: float,
	sprint_requested: bool,
	walk_requested: bool,
	tuning: MovementTuning,
	delta: float
) -> void:
	landing_recovery_remaining = maxf(0.0, landing_recovery_remaining - delta)
	_jumping_state_remaining = maxf(0.0, _jumping_state_remaining - delta)

	if not grounded:
		if _jumping_state_remaining > 0.0 and vertical_velocity > 0.0:
			_set_state(MovementState.JUMPING)
		elif vertical_velocity > 0.05:
			_set_state(MovementState.RISING)
		else:
			_set_state(MovementState.FALLING)
		return

	if landing_recovery_remaining > 0.0:
		return
	if move_strength <= tuning.input_deadzone or horizontal_speed <= 0.08:
		_set_state(MovementState.IDLE)
	elif sprint_requested and not walk_requested and move_strength >= tuning.sprint_input_threshold:
		_set_state(MovementState.SPRINTING)
	elif walk_requested or move_strength <= tuning.walk_input_threshold:
		_set_state(MovementState.WALKING)
	else:
		_set_state(MovementState.JOGGING)


func movement_control_scale(tuning: MovementTuning) -> float:
	match current_state:
		MovementState.SOFT_LANDING:
			return tuning.soft_landing_control_scale
		MovementState.HARD_LANDING:
			return tuning.hard_landing_control_scale
		_:
			return 1.0


func jump_is_locked() -> bool:
	return landing_recovery_remaining > 0.0


func state_name() -> StringName:
	return StringName(STATE_NAMES[current_state])


func has_visited(state: MovementState) -> bool:
	return (visited_state_mask & (1 << state)) != 0


func _set_state(next_state: MovementState) -> void:
	if current_state == next_state:
		return
	previous_state = current_state
	current_state = next_state
	transition_count += 1
	visited_state_mask |= 1 << current_state
	emit_signal(&"state_changed", previous_state, current_state)
