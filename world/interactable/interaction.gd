extends StaticBody3D

@export var interaction_type:String
@export var interaction_name:String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interact_with_on():
	print(1)

func interact_with_off():
	print(0)
