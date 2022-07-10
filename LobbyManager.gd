# Typical lobby implementation; imagine this being in /root/lobby.

extends Node

# Connect all functions

func _ready():
	print("lobby manager ready ")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Leroy Jenkins", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	print("player connected:", id)
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	print("disconnected", id)
	player_info.erase(id) # Erase player from info.

# Only called on clients, not server. Will go unused; not useful here.
func _connected_ok():
	var peer = get_tree().get_network_peer()
	print("connected!")
	get_tree().change_scene(GameManager.LOBBY_SCENE)

# Server kicked us; show error and abort.
func _server_disconnected():
	print("kicked from server")

 # Could not even connect to server; abort.
func _connected_fail():
	print("unable to connect")
	
remote func register_player(info):
	print("register player:", info)
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info

	# Call function to update lobby UI here
