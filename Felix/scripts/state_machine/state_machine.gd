extends Node

@export var felix:CharacterBody3D

enum STATES {IDLE, WALKING, RUNNING, IN_AIR, LEDGE_GRAB}
var PREVIOUS_STATE: STATES
var CURRENT_STATE: STATES

@onready var debug_panel = $"../UserInterface/DebugPanel"

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if felix.speed == felix.run_speed:
		change_states(STATES.RUNNING)
	else:
		change_states(STATES.WALKING)
		
	if not felix.move_direction:
		change_states(STATES.IDLE)
		
	if not felix.is_on_floor(): 
		change_states(STATES.IN_AIR)
		if felix.can_ledge_grab and CURRENT_STATE == STATES.LEDGE_GRAB:
			change_states(STATES.LEDGE_GRAB)

	debug_panel.add_property("STATE", STATES.find_key(CURRENT_STATE))

func change_states(newState):
	if newState == CURRENT_STATE: return
	
	#get_children()[CURRENT_STATE].set_active(false)
	PREVIOUS_STATE = CURRENT_STATE
	CURRENT_STATE = newState
	#get_children()[newState].set_active(true)
