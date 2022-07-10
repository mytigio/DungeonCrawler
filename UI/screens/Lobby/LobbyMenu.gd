extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var LobbyStatsTextBox = $LobbyStatusTextBox
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	LobbyStatsTextBox.text = "Waiting for players..."

func _player_connected(id):
	LobbyStatsTextBox.text = "connected:" + str(id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
