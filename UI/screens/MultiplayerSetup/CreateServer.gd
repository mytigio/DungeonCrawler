extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("pressed", self, "_button_pressed")

func _button_pressed():
	print("Create Server code...")
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(GameManager.SERVER_PORT, GameManager.MAX_PLAYERS)
	get_tree().network_peer = peer
	print("server lisenting on: ", GameManager.SERVER_PORT)
	get_tree().change_scene("res://UI/screens/Lobby/LobbyMenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
