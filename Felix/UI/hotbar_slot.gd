extends TextureRect
var image:CompressedTexture2D
var item_name:String
var is_empty = true

func add_item(image, newname):
	item_name = newname
	is_empty = false
	
	self.texture = image
	

func remove_item():
	item_name = ""
	is_empty = true
	self.texture = load("res://Felix/UI/hotbar/hotbar_empty.jpg")
