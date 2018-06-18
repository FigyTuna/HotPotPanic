extends Node2D

onready var slide_sound = $'Slide'
onready var clear_sound = $'Clear'
onready var fail_sound = $'Fail'

onready var hot = $'Hot'

export var action_key = ""

var current_pot = null

signal stove_cleared()
signal pot_cooked()
signal pot_failed()

func _input(event):
	if event.is_action_pressed(action_key):
		if current_pot:
			current_pot.heat_up()
		hot.modulate.a = 1.0

func _physics_process(delta):
	hot.modulate.a -= delta

func is_occupied():
	return current_pot != null

func add_pot(pot):
	current_pot = pot
	add_child(pot)
	pot.connect("finished_cooking", self, "on_finished_cooking")
	pot.connect("cooking_failed", self, "on_cooking_failed")
	pot.connect("despawn", self, "on_despawn", [pot])
	slide_sound.play()

func remove_pot():
	current_pot.disconnect("finished_cooking", self, "on_finished_cooking")
	current_pot.disconnect("cooking_failed", self, "on_cooking_failed")
	current_pot = null

func on_finished_cooking():
	remove_pot()
	emit_signal("stove_cleared")
	emit_signal("pot_cooked")
	clear_sound.play()

func on_cooking_failed():
	remove_pot()
	emit_signal("stove_cleared")
	emit_signal("pot_failed")
	fail_sound.play()

func on_despawn(pot):
	remove_child(pot)
	pot.disconnect("despawn", self, "on_despawn")

func reset():
	if current_pot != null:
		current_pot.logic_done = true
		current_pot.anim_player.play("Fail")
		remove_pot()