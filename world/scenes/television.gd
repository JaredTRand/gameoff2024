extends "res://world/interactable/interaction.gd"

	
func interact():
	hover_text.visible = false
	hover_text_canbevisible = false
	interaction_cooldown.start()
	
	
