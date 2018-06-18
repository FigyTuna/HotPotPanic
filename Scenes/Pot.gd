extends Node2D

const GOOD_RANGE = 1.0

onready var anim_player = $'AnimationPlayer'

onready var ice = $'Ice'
onready var heat = $'Heat'

var time_cooked = 0.0
var health = 10.0

var temperature = 0.0

var logic_done = false

export var cool_rate = 1.0
export var heat_rate = 1.0
export var cook_time = 2.0

signal finished_cooking()
signal cooking_failed()
signal despawn()

func _ready():
	anim_player.play("SlideIn")

func _physics_process(delta):
	if not logic_done:
		temperature -= delta * cool_rate
		
		if temperature < GOOD_RANGE and temperature > -GOOD_RANGE:
			time_cooked += delta
		else:
			health -= delta * abs(temperature)
		
		if time_cooked >= cook_time:
			logic_done = true
			emit_signal("finished_cooking")
			anim_player.play("SlideOut")
		
		if health <= 0:
			logic_done = true
			emit_signal("cooking_failed")
			anim_player.play("Fail")
		
		ice.modulate.a = -temperature / 4
		heat.modulate.a = temperature / 4

func heat_up():
	temperature += heat_rate

func _on_animation_finished(anim_name):
	if not anim_name == "SlideIn":
		emit_signal("despawn")
