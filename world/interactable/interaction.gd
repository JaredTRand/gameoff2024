extends MeshInstance3D

@export var is_active:bool = true
@export var interaction_type:String
@export var interaction_name:String
@export var interaction_cooldown_time:float = 3.0
@export var thought:String

@export var hvr_txt_size:int = 300

@export_group("Pickup")
@export var pickup_able:bool = false
@export var inv_img:CompressedTexture2D
@export var parent_interactable:Node3D

@export_group("Openable")
@export var openable:bool = false
@export var locked:bool = false
@export var open_sound:AudioStreamWAV
@export var unlocked_with:String
@export var unlock_thought:String = ""
@export var additional_open:Node3D

@onready var animator:AnimationPlayer = find_child("AnimationPlayer")
@onready var sound:AudioStreamPlayer3D = find_child("AudioStreamPlayer3D")

var hover_text_canbevisible = true

@onready var interaction_cooldown:Timer = Timer.new()
var in_player_interact_area = false

@onready var felix = get_tree().get_first_node_in_group("player")
@onready var hotbar = get_tree().get_first_node_in_group("hotbar")

var hover_text:Label3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(interaction_cooldown)
	interaction_cooldown.wait_time = interaction_cooldown_time
	interaction_cooldown.one_shot = true
	interaction_cooldown.connect("timeout", _on_interaction_cooldown_timeout)
	
	if parent_interactable and parent_interactable.locked:
		is_active = false
	
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
			if hotbar.is_in_hotbar(unlocked_with):
				felix.think(unlock_thought)
				locked = false
				animator.play("open")
				if sound: sound.play()
				add_open()
				set_script(null)
		else:
			animator.play("open")
			if sound: sound.play()
			add_open()
			
func add_open():
	if is_instance_valid(additional_open):
		#await get_tree().create_timer(2.0).timeout 
		var add_anim = additional_open.find_child("AnimationPlayer")
		if add_anim:
			add_anim.play("open")
			
func check_is_active():
	if is_active: return true
	if parent_interactable and not parent_interactable.locked:
			return true
	return false
	
func _on_interaction_cooldown_timeout():
	hover_text_canbevisible = true
	if in_player_interact_area and hover_text_canbevisible:
		hover_text.visible = true
