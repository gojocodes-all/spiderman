class_name TraversalStateMachine
extends Node

signal state_changed(previous_state: TraversalState, current_state: TraversalState, reason: StringName)

enum TraversalState {
	IDLE,
	WALL_RUN,
	VERTICAL_WALL_RUN,
	WALL_CLIMB,
	WALL_JUMP,
	VAULT,
	MANTLE,
	LEDGE_GRAB,
	LEDGE_CLIMB,
	RECOVERY,
}

const STATE_NAMES: PackedStringArray = [
	"idle",
	"wall_run",
	"vertical_wall_run",
	"wall_climb",
	"wall_jump",
	"vault",
	"mantle",
	"ledge_grab",
	"ledge_climb",
	"traversal_recovery",
]

var current_state := TraversalState.IDLE
var previous_state := TraversalState.IDLE
var state_elapsed := 0.0
var transition_count := 0
var rejected_transition_count := 0
var visited_state_mask := 1 << TraversalState.IDLE
var last_reason := &"reset"


func reset() -> void:
	current_state = TraversalState.IDLE
	previous_state = TraversalState.IDLE
	state_elapsed = 0.0
	transition_count = 0
	rejected_transition_count = 0
	visited_state_mask = 1 << TraversalState.IDLE
	last_reason = &"reset"


func tick(delta: float) -> void:
	state_elapsed += delta


func transition(next_state: TraversalState, reason: StringName) -> bool:
	if next_state == current_state:
		return true
	if not _transition_is_allowed(current_state, next_state):
		rejected_transition_count += 1
		return false
	previous_state = current_state
	current_state = next_state
	state_elapsed = 0.0
	transition_count += 1
	visited_state_mask |= 1 << current_state
	last_reason = reason
	emit_signal(&"state_changed", previous_state, current_state, reason)
	return true


func force_idle(reason: StringName = &"reset") -> void:
	if current_state == TraversalState.IDLE:
		state_elapsed = 0.0
		last_reason = reason
		return
	previous_state = current_state
	current_state = TraversalState.IDLE
	state_elapsed = 0.0
	transition_count += 1
	visited_state_mask |= 1 << current_state
	last_reason = reason
	emit_signal(&"state_changed", previous_state, current_state, reason)


func owns_character_motion() -> bool:
	return current_state != TraversalState.IDLE and current_state != TraversalState.RECOVERY


func is_wall_state() -> bool:
	return current_state in [
		TraversalState.WALL_RUN,
		TraversalState.VERTICAL_WALL_RUN,
		TraversalState.WALL_CLIMB,
		TraversalState.WALL_JUMP,
	]


func state_name() -> StringName:
	return StringName(STATE_NAMES[current_state])


func has_visited(state: TraversalState) -> bool:
	return (visited_state_mask & (1 << state)) != 0


func _transition_is_allowed(from_state: TraversalState, to_state: TraversalState) -> bool:
	if to_state == TraversalState.RECOVERY:
		return from_state != TraversalState.IDLE and from_state != TraversalState.RECOVERY
	match from_state:
		TraversalState.IDLE:
			return to_state in [
				TraversalState.WALL_RUN,
				TraversalState.VERTICAL_WALL_RUN,
				TraversalState.VAULT,
				TraversalState.MANTLE,
				TraversalState.LEDGE_GRAB,
			]
		TraversalState.WALL_RUN:
			return to_state in [TraversalState.WALL_JUMP, TraversalState.MANTLE, TraversalState.LEDGE_GRAB]
		TraversalState.VERTICAL_WALL_RUN:
			return to_state in [
				TraversalState.WALL_CLIMB,
				TraversalState.WALL_JUMP,
				TraversalState.MANTLE,
				TraversalState.LEDGE_GRAB,
			]
		TraversalState.WALL_CLIMB:
			return to_state in [TraversalState.WALL_JUMP, TraversalState.MANTLE, TraversalState.LEDGE_GRAB]
		TraversalState.LEDGE_GRAB:
			return to_state in [TraversalState.LEDGE_CLIMB, TraversalState.WALL_JUMP]
		TraversalState.RECOVERY:
			return to_state == TraversalState.IDLE
		TraversalState.WALL_JUMP:
			return to_state == TraversalState.IDLE
		_:
			return false
