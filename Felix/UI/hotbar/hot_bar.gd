extends HBoxContainer
var items_collected = []
var items_not_collected:Array

func _ready():
	for item in get_tree().get_nodes_in_group("interactable"):
		if item.get_parent().pickup_able and item.get_parent().interaction_name != "Fish Flakes":
			if item.get_parent().txt_name:
				items_not_collected.append(item.get_parent().txt_name)
			else:
				items_not_collected.append(item.get_parent().interaction_name)

func add_item(image, newname):
	var empty_child = get_empty_child()
	if empty_child == null:
		return false
		
	empty_child.add_item(image, newname) 
	items_collected.append(newname)
	for item in items_not_collected:
		if item == newname:
			items_not_collected.remove_at(items_not_collected.find(newname))
	return true
	
func remove_item(itemname):
	for child in get_children():
		if child.item_name == itemname:
			child.remove_item()
	
func get_empty_child():
	var emptyChild
	for child in get_children():
		if child.is_empty:
			emptyChild = child
			break
	
	return emptyChild

func is_in_hotbar(itemname):
	for child in get_children():
		if child.item_name == itemname:
			return true
	return false
