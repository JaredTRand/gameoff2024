extends MeshInstance3D

@export var is_active:bool = true
@export var interaction_type:String = "Open"
@export var interaction_name:String
@export var interaction_cooldown_time:float = 3.0
@export var thought:String

@export var hvr_txt_size:int = 100

@export_group("Pickup")
@export var pickup_able:bool = false
@export var inv_img:CompressedTexture2D
@export var parent_interactable:Node3D

@export_group("Openable")
@export var openable:bool = false
@export var locked:bool = false
@export var open_lockable:bool = false
@export var open_sound:AudioStreamWAV
@export var unlocked_with:String = "*"
@export var unlock_thought:String = ""
@export var open_locked_thought:String = ""
@export var additional_open:Node3D

@onready var animator:AnimationPlayer = find_child("AnimationPlayer")
@onready var sound:AudioStreamPlayer3D = find_child("AudioStreamPlayer3D")

var hover_text_canbevisible = true

enum open_states {closed, open_locked, open, done}
var  open_state = open_states.closed

@onready var interaction_cooldown:Timer = Timer.new()
var in_player_interact_area = false

@onready var felix = get_tree().get_first_node_in_group("player")
@onready var hotbar = get_tree().get_first_node_in_group("hotbar")
@onready var debug = get_tree().get_first_node_in_group("debug_panel")
var hover_text:Label3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(interaction_cooldown)
	interaction_cooldown.wait_time = interaction_cooldown_time
	interaction_cooldown.one_shot = true
	interaction_cooldown.connect("timeout", _on_interaction_cooldown_timeout)
	
	debug.add_property(interaction_name + " active1?", is_active)
	if not check_is_active():
		is_active = false
	debug.add_property(interaction_name + " active2?", is_active)
	
	if hover_text == null:
		hover_text = load("res://Felix/assets/hover_text.tscn").instantiate()
		add_child(hover_text)
		hover_text.font_size = hvr_txt_size

func interact_with_on():
	if not is_active: return
	
	in_player_interact_area = true
	if hover_text_canbevisible:
		hover_text.visible = true
		hover_text.global_position = global_position
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
			self.queue_free()
	
	if openable:
		if locked:
			if unlocked_with == "*" or hotbar.is_in_hotbar(unlocked_with):
				open_state = open_states.open
				felix.think(unlock_thought)
				locked = false
				animator.play("open")
				if sound: sound.play()
				add_open()
			elif open_lockable and open_state != open_states.open_locked:
				open_state = open_states.open_locked
				felix.think(open_locked_thought)
				animator.play("open_locked")
				if sound: sound.play()
				
		else:
			if open_state == open_states.open:
				open_state = open_states.closed
				animator.play_backwards("open")
				if sound: sound.play()
				add_open()
				interaction_type = "Open"
			else:
				open_state = open_states.open
				animator.play("open")
				if sound: sound.play()
				add_open()
				interaction_type = "Close"
			
func add_open():
	if is_instance_valid(additional_open):
		#await get_tree().create_timer(2.0).timeout 
		var add_anim = additional_open.find_child("AnimationPlayer")
		if add_anim:
			add_anim.play("open")
			
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
	if in_player_interact_area and hover_text_canbevisible:
		hover_text.visible = true
