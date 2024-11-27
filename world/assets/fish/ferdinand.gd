extends "res://world/interactable/interaction.gd"

@onready var resource = load("res://world/dialogue/tipfish1.dialogue")

func interact():
	hover_text.visible = false
	hover_text_canbevisible = false
	interaction_cooldown.start()
	
	if not GameState.fish_introduction:
		DialogueManager.show_dialogue_balloon(resource, "introduction")
	elif not GameState.first_flake:
		DialogueManager.show_dialogue_balloon(resource, "beforeFirstFlake")
	elif GameState.first_flake:
		DialogueManager.show_dialogue_balloon(resource, "beforeFirstFlake")

func _on_tipfish_1_area_entered(area):
	if not GameState.met_fish: 
		DialogueManager.show_dialogue_balloon(resource, "comehere") 
