extends Node2D

onready var stove = $'Stove'
onready var instruction = $'Instruction'
onready var scoreboard = $'Scoreboard'

onready var title_anim = $'Title/AnimationPlayer'
onready var instruction_anim = $'Instruction/AnimationPlayer'
onready var scoreboard_anim = $'Scoreboard/AnimationPlayer'

enum STATES {TITLE, TITLE_OUT, INSTRUCTION, INSTRUCTION_OUT, GAME, GAME_OUT, SCOREBOARD, SCOREBOARD_OUT}

var state = STATES.TITLE

func _ready():
	stove.set_physics_process(false)
	instruction.set_process_input(false)
	
	title_anim.connect("animation_finished", self, "on_animation_finished")
	instruction_anim.connect("animation_finished", self, "on_animation_finished")
	scoreboard_anim.connect("animation_finished", self, "on_animation_finished")

func _input(event):
	if event.is_pressed():
		if state == STATES.TITLE or state == STATES.SCOREBOARD_OUT:
			title_anim.play("Fade")
			instruction.reset()
			instruction.set_process_input(true)
			state = STATES.TITLE_OUT
			stove.pots_cleared_label.hide()
		elif state == STATES.SCOREBOARD:
			scoreboard_anim.play("Fade")
			state = STATES.SCOREBOARD_OUT

func _on_instructions_complete():
	instruction_anim.play("Fade")
	instruction.set_process_input(false)
	state = STATES.INSTRUCTION_OUT
	stove.update_pots_cleared()

func on_animation_finished(anim_name):
	if state == STATES.TITLE_OUT:
		state = STATES.INSTRUCTION
		instruction_anim.play_backwards("Fade")
	elif state == STATES.INSTRUCTION_OUT:
		state = STATES.GAME
		stove.set_physics_process(true)
		stove.update_lives()
		stove.pots_cleared_label.show()
	elif state == STATES.SCOREBOARD_OUT:
		title_anim.play_backwards("Fade")
		state = STATES.TITLE
		stove.pots_cleared_label.hide()
	elif state == STATES.GAME_OUT:
		state = STATES.SCOREBOARD

func _on_game_over(score):
	stove.set_physics_process(false)
	scoreboard_anim.play_backwards("Fade")
	state = STATES.GAME_OUT
	stove.reset()