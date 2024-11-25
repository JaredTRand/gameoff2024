extends MeshInstance3D

@export var interaction_type:String
@export var interaction_name:String
@export var interaction_cooldown_time:float = 3.0
@export var thought:String
@export var unlock_thought:String
@export var hvr_txt_size:int = 300

@export_group("Pickup")
@export var pickup_able:bool = false
@export var inv_img:CompressedTexture2D

@export_group("Openable")
@export var openable:bool = false
@export var locked:bool = false
@export var unlocked_with:String

@onready var animator:AnimationPlayer = find_child("AnimationPlayer")

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
	
	if hover_text == null:
		hover_text = load("res://Felix/assets/hover_text.tscn").instantiate()
		add_child(hover_text)
		hover_text.font_size = hvr_txt_size

func interact_with_on():
	in_player_interact_area = true
	if hover_text_canbevisible:
		hover_text.visible = true
		hover_text.global_position = global_position
		hover_text.text = interaction_type + " " + interaction_name

func interact_with_off():
	hover_text.visible = false
	in_player_interact_area = false
	
func interact():
	hover_text.visible = false
	hover_text_canbevisible = false
	interaction_cooldown.start()
	
	if thought:
		felix.think(thought)
		
	if pickup_able:
		var success = hotbar.add_item(inv_img, interaction_name)
		if success: 
			self.queue_free()
	
	if openable:
		if locked:
			if hotbar.is_in_hotbar(unlocked_with):
				if unlock_thought: 
					felix.think(unlock_thought)
				locked = false
				animator.play("open")
				set_script(null)
		else:
			animator.play("open")

func _on_interaction_cooldown_timeout():
	hover_text_canbevisible = true
	if in_player_interact_area and hover_text_canbevisible:
		hover_text.visible = true
