extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SERVER_PORT = 444
const MAX_PLAYERS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#self._createServer()
	#print("IsServer: ",get_tree().is_network_server())
	#print("ServerId:", get_tree().get_network_unique_id())
	#print("Connected Peers:", get_tree().get_network_connected_peers())
	
func createServer():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	print("server lisenting on: ", SERVER_PORT)
	
func connectToServer(ip, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer
	
func networkDisconnect():
	get_tree().network_peer = null

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
