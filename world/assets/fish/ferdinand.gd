extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tipfish_1_area_entered(area):
	var resource = load("res://world/dialogue/tipfish1.dialogue")
	#var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, "comehere")
	DialogueManager.show_dialogue_balloon(resource, "comehere") 
