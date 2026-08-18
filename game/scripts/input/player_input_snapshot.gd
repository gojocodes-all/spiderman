class_name PlayerInputSnapshot
extends RefCounted

var move := Vector2.ZERO
var jump_pressed := false
var sprint_held := false
var walk_held := false
var burst_pressed := false


func clear_one_shots() -> void:
	jump_pressed = false
	burst_pressed = false
