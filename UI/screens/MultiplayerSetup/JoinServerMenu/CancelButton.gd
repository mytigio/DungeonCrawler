extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("pressed", self, "_button_pressed")

func _button_pressed():
	#update this scene to be the lobby and wait for folks to join
	get_tree().network_peer = null
	get_tree().change_scene(GameManager.MULTIPLAYER_MENU)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
