extends Node2D

onready var readyA = $'ReadyA'
onready var readyB = $'ReadyB'
onready var readyC = $'ReadyC'
onready var readyD = $'ReadyD'

onready var ready_sound = $'Ding'

var a = false
var b = false
var c = false
var d = false

signal instructions_complete()

func _input(event):
	if event.is_action_pressed("StoveA") and not a:
		readyA.modulate.a = 0.6
		a = true
		ready_sound.play()
	if event.is_action_pressed("StoveB") and not b:
		readyB.modulate.a = 0.6
		b = true
		ready_sound.play()
	if event.is_action_pressed("StoveC") and not c:
		readyC.modulate.a = 0.6
		c = true
		ready_sound.play()
	if event.is_action_pressed("StoveD") and not d:
		readyD.modulate.a = 0.6
		d = true
		ready_sound.play()
	
	if a and b and c and d:
		emit_signal("instructions_complete")

func reset():
	readyA.modulate.a = 0
	readyB.modulate.a = 0
	readyC.modulate.a = 0
	readyD.modulate.a = 0

	a = false
	b = false
	c = false
	d = false
