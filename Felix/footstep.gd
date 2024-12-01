extends AudioStreamPlayer3D

@onready var statemachine = %STATE_MACHINE

func do_walk():
	if statemachine.CURRENT_STATE == statemachine.STATES.WALKING:
		volume_db = -1
		play()

func do_run():
	if statemachine.CURRENT_STATE == statemachine.STATES.RUNNING:
		volume_db = 0
		play()
