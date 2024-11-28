@tool
extends Node

var dialogue_on = false
var met_fish = false
var fish_introduction = false
var first_flake = false
var fish_intro_completed = false

var numOfFlakes:int = 0
@onready var phantom_cams
@onready var look_at:PhantomCamera3D

@onready var fishflakes = get_tree().get_first_node_in_group("ff_container")

func _ready():
	phantom_cams = get_tree().get_nodes_in_group("phantomcams")
	
func swap_camera(cam_to_switch_to:String):
	var new_cam 
	for cam in phantom_cams:
		if is_instance_valid(cam) and cam.get_meta("name") == cam_to_switch_to:
			new_cam = cam
			
	if is_instance_valid(new_cam) and new_cam != look_at:
		if look_at: 
			look_at.priority = 10
		look_at = new_cam
		look_at.priority = 20

func use_fish_flake():
	var cur_flake_count:int = int(fishflakes.find_child("flakecount").text)
	
	if cur_flake_count <= 0:
		return false
	
	cur_flake_count = cur_flake_count - 1
	fishflakes.find_child("flakecount").text = str(cur_flake_count)
	fishflakes.find_child("AnimationPlayer").play("moreflakes2")
	
	if cur_flake_count <= 0:
		var TRfishflakes:TextureRect = fishflakes.find_child("fishflakes")
		if TRfishflakes.visible:
			TRfishflakes.visible = false
	
func get_fish_flake():
	var cur_flake_count:int = int(fishflakes.find_child("flakecount").text)
	fishflakes.find_child("flakecount").text = str(cur_flake_count + 1)
	
	fishflakes.find_child("AnimationPlayer").play("moreflakes2")
	
	var TRfishflakes:TextureRect = fishflakes.find_child("fishflakes")
	if !TRfishflakes.visible:
		TRfishflakes.visible = true
	return true
