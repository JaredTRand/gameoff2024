extends Area3D

@export var this_triggers:Node3D
@export var using_method:String
#@export var triggered_by:Node3D
@export var trigger_once:bool = true
@export var delay:float = 0.0

func _ready():
	if not this_triggers:
		self.queue_free()
func _on_body_entered(body):
	if body.name == "Player":
		trigger()

func trigger():
	if this_triggers.has_method(using_method):
		if delay > 0:
			await get_tree().create_timer(delay).timeout
		this_triggers.call_deferred(using_method)
		if trigger_once:
			self.queue_free()
