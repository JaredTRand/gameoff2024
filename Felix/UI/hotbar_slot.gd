extends TextureRect
var item:PackedScene
var image:CompressedTexture2D
var item_name:String
var is_empty = true

func add_item(image, newname):
	#item = newItem
	item_name = newname
	is_empty = false
	
	self.texture = image
	
