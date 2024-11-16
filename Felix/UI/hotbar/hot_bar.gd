extends HBoxContainer

func add_item(image, newname):
	var empty_child = get_empty_child()
	if empty_child == null:
		return false
		
	empty_child.add_item(image, newname) 
	return true
	
func get_empty_child():
	var emptyChild
	for child in get_children():
		if child.is_empty:
			emptyChild = child
			break
	
	return emptyChild
