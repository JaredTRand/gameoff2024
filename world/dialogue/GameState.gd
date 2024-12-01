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
@onready var hotbar_sound:AudioStreamPlayer = get_tree().get_first_node_in_group("hotbar_sound")

func _ready():
	phantom_cams = get_tree().get_nodes_in_group("phantomcams")
	
func swap_camera(cam_to_switch_to:String, speaking=true):
	var new_cam 
	for cam in phantom_cams:
		if is_instance_valid(cam) and cam.get_meta("name") == cam_to_switch_to:
			new_cam = cam
			
	if is_instance_valid(new_cam) and new_cam != look_at:
		var sounds
		if new_cam.has_meta("sounds"):
			sounds = new_cam.get_meta("sounds")
		
		if sounds and not sounds.is_empty() and hotbar_sound and not hotbar_sound.playing:
			hotbar_sound.stream = load(sounds[randi() % sounds.size()])
			if speaking and hotbar_sound.stream: hotbar_sound.play()
		if look_at: 
			look_at.priority = 10
		look_at = new_cam
		look_at.priority = 20

func use_fish_flake():
	var cur_flake_count:int = int(fishflakes.find_child("flakecount").text)
	
	if cur_flake_count <= 0:
		return false
	
	if hotbar_sound:
		hotbar_sound.stream = load("res://world/sounds/flake4shakes.wav")
		if hotbar_sound.stream: hotbar_sound.play()
	
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
