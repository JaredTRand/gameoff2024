extends Node3D

@onready var textbox:Label3D = $text
@onready var animations:AnimationPlayer = $AnimationPlayer
@onready var hide_timer:Timer = $hide_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	animations.play("RESET")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func think(text):
	if text == "" or text == null:
		cancel_think()
		return
	animations.play("pop_out")
	textbox.text = text
	hide_timer.start()

func cancel_think():
	animations.play("RESET")

func _on_hide_timer_timeout():
	animations.play("pop_in")
