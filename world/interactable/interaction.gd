extends StaticBody3D

@export var interaction_type:String
@export var interaction_name:String
@export var interaction_cooldown_time:float = 3.0

@onready var hover_text:Label3D = $"../../hover_text"
var hover_text_canbevisible = true

@onready var interaction_cooldown:Timer = Timer.new()
var in_player_interact_area = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(interaction_cooldown)
	interaction_cooldown.wait_time = interaction_cooldown_time
	interaction_cooldown.one_shot = true
	interaction_cooldown.connect("timeout", _on_interaction_cooldown_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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

func _on_interaction_cooldown_timeout():
	hover_text_canbevisible = true
	if in_player_interact_area and hover_text_canbevisible:
		hover_text.visible = true
