extends Node
class_name State

var active = false
var stateMachine = get_parent()
var felix
var STATES

func _ready():
	felix = get_parent().body
	STATES = get_parent().STATES
	
func set_active(activate):
	if activate: enter()
	else: exit()
	
	set_physics_process(activate)
	set_process(activate)
	
func enter():
	pass

func exit():
	pass
	
