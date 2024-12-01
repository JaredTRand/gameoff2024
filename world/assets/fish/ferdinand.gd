extends "res://world/interactable/interaction.gd"

@onready var resource = load("res://world/dialogue/tipfish1.dialogue")
@export var other_tips:Array

func interact():
	hover_text.visible = false
	hover_text_canbevisible = false
	interaction_cooldown.start()
	
	if not GameState.fish_introduction:
		if GameState.first_flake:
			DialogueManager.show_dialogue_balloon(resource, "firstFlakeandNoIntro")
		else:
			DialogueManager.show_dialogue_balloon(resource, "introduction")
	elif not GameState.first_flake:
		DialogueManager.show_dialogue_balloon(resource, "beforeFirstFlake")
	elif GameState.first_flake and not GameState.fish_intro_completed:
		DialogueManager.show_dialogue_balloon(resource, "firstFlake")
	elif GameState.fish_intro_completed:
		if hotbar.items_not_collected.is_empty() and other_tips.is_empty():
			DialogueManager.show_dialogue_balloon(resource, "noMoreTips")

		var rng = RandomNumberGenerator.new().randi_range(1,2)
		if rng == 1:
			var tipitem = "fishtip_" + hotbar.items_not_collected.pick_random().to_lower()
			var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, tipitem)
			if dialogue_line:
				DialogueManager.show_dialogue_balloon(resource, tipitem)
		else:
			var tipitem = "fishtip_" + other_tips.pick_random().to_lower()
			var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, tipitem)
			if dialogue_line:
				DialogueManager.show_dialogue_balloon(resource, tipitem)
func _on_tipfish_1_area_entered(area):
	if not GameState.met_fish: 
		DialogueManager.show_dialogue_balloon(resource, "comehere") 
