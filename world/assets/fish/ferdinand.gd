extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tipfish_1_area_entered(area):
	if not GameState.met_fish:
		var resource = load("res://world/dialogue/tipfish1.dialogue")
		DialogueManager.show_dialogue_balloon(resource, "comehere") 
