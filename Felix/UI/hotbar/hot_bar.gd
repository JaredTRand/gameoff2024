extends HBoxContainer

func add_item(image, newname):
	var empty_child = get_empty_child()
	if empty_child == null:
		return false
		
	empty_child.add_item(image, newname) 
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
