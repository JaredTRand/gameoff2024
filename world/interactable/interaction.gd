extends MeshInstance3D

@export var is_active:bool = true
@export var interaction_type:String
@export var interaction_name:String
@export var interaction_cooldown_time:float = 3.0
@export var thought:String

@export var hvr_txt_size:int = 50

@export_group("Pickup")
@export var pickup_able:bool = false
@export var pickup_sound:AudioStreamWAV = load("res://world/sounds/pickupitem.wav")
@export var inv_img:CompressedTexture2D
@export var parent_interactable:Node3D

@export_group("Openable")
@export var openable:bool = false
@export var interactable_after_open:bool = true
@export var delete_after_open:bool = false
@export var locked:bool = false
@export var open_sound:AudioStreamWAV
@export var close_sound:AudioStreamWAV
@export var open_locked_sound:AudioStreamWAV
@export var unlocked_with:String = "*"
@export var unlock_thought:String = ""
@export var open_lockable:bool = false
@export var open_locked_thought:String = ""
@export var additional_open:Node3D
@export var add_open_wait_time:float = 0.0

@export var animator:AnimationPlayer
@export var sound:AudioStreamPlayer3D
@onready var hotbar_sound:AudioStreamPlayer = get_tree().get_first_node_in_group("hotbar_sound")

var hover_text_canbevisible = true

enum open_states {closed, open_locked, open, done}
var  open_state = open_states.closed

@onready var interaction_cooldown:Timer = Timer.new()
var in_player_interact_area = false

@onready var felix = get_tree().get_first_node_in_group("player")
@onready var hotbar = get_tree().get_first_node_in_group("hotbar")
@onready var debug = get_tree().get_first_node_in_group("debug_panel")
@onready var hover_text_placement:Node3D = find_child((interaction_name + "_text_placement").to_lower())
var hover_text:Label3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(interaction_cooldown)
	interaction_cooldown.wait_time = interaction_cooldown_time
	interaction_cooldown.one_shot = true
	interaction_cooldown.connect("timeout", _on_interaction_cooldown_timeout)
	
	if not check_is_active():
		is_active = false
	
	if not interaction_type:
		if pickup_able:
			interaction_type = "Pick Up"
		elif openable:
			interaction_type = "Open"
		else:
			interaction_type = "Interact"
	
	if not animator:
		animator = find_child("AnimationPlayer")
	
	if not sound:
		sound = find_child("AudioStreamPlayer3D")
		
	if hover_text == null:
		hover_text = load("res://Felix/assets/hover_text.tscn").instantiate()
		if hover_text_placement:
			hover_text_placement.add_child(hover_text)
			hover_text.global_position = hover_text_placement.global_position
		else:
			add_child(hover_text)
		
		hover_text.font_size = hvr_txt_size

func interact_with_on():
	if not is_active: return
	
	in_player_interact_area = true
	if hover_text_canbevisible:
		hover_text.visible = true
		#hover_text.global_position = global_position
		hover_text.text = interaction_type + " " + interaction_name

func interact_with_off():
	hover_text.visible = false
	in_player_interact_area = false
	
func interact():
	if not is_active: return
			
	hover_text.visible = false
	hover_text_canbevisible = false
	interaction_cooldown.start()
	
	if thought:
		felix.think(thought)
		
	if pickup_able:
		var success
		if interaction_name == "Fish Flakes":
			GameState.first_flake = true
			success = GameState.get_fish_flake()
		else:
			success = hotbar.add_item(inv_img, interaction_name)
			
		if success: 
			if hotbar_sound:
				if pickup_sound: hotbar_sound.stream = pickup_sound
				if hotbar_sound.stream: hotbar_sound.play()
			self.queue_free()
	
	if openable:
		if locked:
			if unlocked_with == "*" or hotbar.is_in_hotbar(unlocked_with):
				felix.think(unlock_thought)
				open()
				
				if unlocked_with != "*":
					hotbar.remove_item(unlocked_with)				
			elif open_lockable and open_state != open_states.open_locked:
				open_state = open_states.open_locked
				felix.think(open_locked_thought)
				animator.play("open_locked")
				
				
				if sound:
					if open_locked_sound: sound.stream = open_locked_sound
					if sound.stream: sound.play()
				
		else:
			if open_state == open_states.open:
				close()
			else:
				open()
					
func open():
	locked = false
	open_state = open_states.open
	interaction_type = "Close"
	
	if animator: animator.play("open")
	
	
	if sound:
		if open_sound: sound.stream = open_sound
		if sound.stream: sound.play()
	
	if additional_open: add_open()
	if delete_after_open: self.queue_free()
	if not interactable_after_open: set_script(null)
	
func close():
	open_state = open_states.closed
	if animator: animator.play_backwards("open")
	
	if sound:
		if close_sound: sound.stream = close_sound
		if sound.stream: sound.play()
	#add_open()
	interaction_type = "Open"
	
func add_open():
	if is_instance_valid(additional_open) and additional_open.has_method("open"):
		if add_open_wait_time > 0:
			await get_tree().create_timer(add_open_wait_time).timeout 
		additional_open.open()
		
func check_is_active():
	if is_active: 
		return true

	if is_instance_valid(parent_interactable):
		debug.add_property(interaction_name + " parent valid?", is_instance_valid(parent_interactable))
		debug.add_property(interaction_name + " has method?", parent_interactable.has_method("interact"))
		debug.add_property(interaction_name + " is locked?", parent_interactable.locked)
		debug.add_property(interaction_name + " all together", is_instance_valid(parent_interactable) and parent_interactable.has_method("interact") and not parent_interactable.locked)

	if is_instance_valid(parent_interactable):
		if parent_interactable.has_method("interact") and not parent_interactable.locked:
			is_active = true
		else: 
			is_active = false
	
	return is_active
	
func _on_interaction_cooldown_timeout():
	hover_text_canbevisible = true
	if in_player_interact_area and hover_text_canbevisible and not GameState.dialogue_on:
		hover_text.visible = true
