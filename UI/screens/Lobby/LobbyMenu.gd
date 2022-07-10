extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var LobbyStatsTextBox = $LobbyStatusTextBox
onready var startButton = $StartButton
# Called when the node enters the scene tree for the first time.
func _ready():
	startButton.hide()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	LobbyStatsTextBox.text = "Waiting for Server..."
	if (get_tree().is_network_server()):
		LobbyStatsTextBox.text = "Waiting for Players..."
		startButton.show()
		

func _player_connected(id):
	LobbyStatsTextBox.text = LobbyStatsTextBox.text + "\n" + str(id) + " connected"

func _player_disconnected(id):
	LobbyStatsTextBox.text = LobbyStatsTextBox.text + "\n" + str(id) + " disconnected"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
