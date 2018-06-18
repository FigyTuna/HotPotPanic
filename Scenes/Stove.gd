extends Node2D

var SmallPot = preload("res://Scenes/Pots/SmallPot.tscn")
var RegularPot = preload("res://Scenes/Pots/RegularPot.tscn")
var LargePot = preload("res://Scenes/Pots/LargePot.tscn")

onready var life1 = $'Life1'
onready var life2 = $'Life2'
onready var life3 = $'Life3'
onready var pots_cleared_label = $'PotsCleared'

class Stage:
	
	var max_pots = 1
	var small_available = false
	var regular_available = true
	var large_available = false
	var min_spawn_time = 0.5
	var max_spawn_time = 1.0
	var time_until_cleared = 7.0
	var next_stage = null

var stage = null
var first_stage = null

var spawn_timer = 0.0
var spawn_time_target = 0.5

var stoves = []
var stoves_used = 0
var lives = 3
var pots_cleared = 0
var time_this_stage = 0.0

signal game_over(score)

func _ready():
	randomize()
	stoves.append($'StovePlateA')
	stoves.append($'StovePlateB')
	stoves.append($'StovePlateC')
	stoves.append($'StovePlateD')
	
	var stages = []
	
	for i in range(12):
		stages.append(Stage.new())
		if i > 0:
			stages[i - 1].next_stage = stages[i]
	
	stages[1].max_pots = 2
	stages[1].time_until_cleared = 10.0
	
	stages[2].max_pots = 2
	stages[2].small_available = true
	stages[2].time_until_cleared = 12.0

	stages[3].max_pots = 2
	stages[3].large_available = true
	stages[3].time_until_cleared = 12.0

	stages[4].max_pots = 3
	stages[4].small_available = true
	stages[4].time_until_cleared = 19.0
	stages[4].min_spawn_time = 1.0
	stages[4].max_spawn_time = 2.5

	stages[5].max_pots = 3
	stages[5].large_available = true
	stages[5].time_until_cleared = 15.0

	stages[6].max_pots = 3
	stages[6].small_available = true
	stages[6].regular_available = false
	stages[6].large_available = true
	stages[6].time_until_cleared = 16.0

	stages[7].max_pots = 3
	stages[7].small_available = true
	stages[7].large_available = true
	stages[7].time_until_cleared = 17.0

	stages[8].max_pots = 4
	stages[8].small_available = true
	stages[8].time_until_cleared = 18.0

	stages[9].max_pots = 4
	stages[9].small_available = true
	stages[9].large_available = true
	stages[9].time_until_cleared = 25.0

	stages[10].max_pots = 4
	stages[10].regular_available = false
	stages[10].large_available = true
	stages[10].time_until_cleared = 14.0

	stages[11].max_pots = 4
	stages[11].small_available = true
	stages[11].large_available = true
	stages[11].min_spawn_time = 0.1
	stages[11].max_spawn_time = 0.3
	
	first_stage = stages[0]

	reset()

func reset_spawn():
	spawn_timer = 0.0
	spawn_time_target = rand_range(stage.min_spawn_time, stage.max_spawn_time)

func _physics_process(delta):
	if stoves_used < stage.max_pots:
		spawn_timer += delta
		
		if spawn_timer >= spawn_time_target:
			spawn()
	
	time_this_stage += delta
	if stage.next_stage and time_this_stage >= stage.time_until_cleared:
		stage = stage.next_stage
		time_this_stage = 0.0

func spawn():
	var pot_types = []
	if stage.small_available:
		pot_types.append(SmallPot)
	if stage.regular_available:
		pot_types.append(RegularPot)
	if stage.large_available:
		pot_types.append(LargePot)
	
	var stove_choices = []
	for stove in stoves:
		if not stove.is_occupied():
			stove_choices.append(stove)
	
	stoves_used += 1
	stove_choices[randi() % stove_choices.size()].add_pot(pot_types[randi() % pot_types.size()].instance())
	reset_spawn()

func _on_pot_cooked():
	pots_cleared += 1
	update_pots_cleared()

func _on_pot_failed():
	lives -= 1
	update_lives()
	if lives <= 0:
		emit_signal("game_over", pots_cleared)

func _on_stove_cleared():
	stoves_used -= 1
	
	if stoves_used == 0 and spawn_time_target - spawn_timer > 0.5:
		spawn_time_target = 0.5
		spawn_timer = 0.0

func update_lives():
	life1.visible = lives > 0
	life2.visible = lives > 1
	life3.visible = lives > 2

func update_pots_cleared():
	pots_cleared_label.text = "Score: " + str(pots_cleared)

func reset():
	for stove_plate in stoves:
		stove_plate.reset()
	stage = first_stage
	lives = 3
	pots_cleared = 0
	time_this_stage = 0.0
	stoves_used = 0
	reset_spawn()