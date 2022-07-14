# Typical lobby implementation; imagine this being in /root/lobby.

extends Node

# Connect all functions
signal game_ended()

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
var my_info = { name = str(randf()), favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	print("player connected:", id)
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	print("disconnected", id)
	player_info.erase(id) # Erase player from info.

# Only called on clients, not server. Will go unused; not useful here.
func _connected_ok():
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
	

remote func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	# Load world
	var world = load("res://World/OverWorld.tscn").instance()
	get_node("/root").add_child(world)
	var players_node = Node.new()
	players_node.name = "players"
	get_node("/root").add_child(players_node)
	
	# Load my player
	var my_player = preload("res://Player/Player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later
	get_node("/root/players").add_child(my_player)

	# Load other players
	for p in player_info:
		var player = preload("res://Player/Player.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p) # Will be explained later
		get_node("/root/players").add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "post_configure_game", get_tree().get_network_unique_id())
	elif player_info.size() == 0:
		post_configure_game()


	
remote func post_configure_game():
	# Only the server is allowed to tell a client to unpause
	get_node("/root/LobbyMenu").queue_free()
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		# Game starts now!

func startGame():
	
	for player in LobbyManager.player_info:
		rpc_id(player, "pre_configure_game")
	pre_configure_game()
	
	
	# remove the player from the overworld scene - check
	# refactor overworld for players node - check...
	# Fire off the pre_config_here
	# remove player node from overworld and programtically add all
	# ensure pre_config fires on all clients and game starts
	#get_tree().change_scene(GameManager.OVERWORLD_SCENE)
	
func joinGame(ip, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer



	
func quitGame():
	get_tree().network_peer = null
	GameManager.reset()
	if has_node("/root/OverWorld"): # Game is in progress.
		# End it
		get_node("/root/OverWorld").queue_free()
	get_node("/root/players").queue_free()
	
	get_tree().change_scene(GameManager.MULTIPLAYER_MENU)
