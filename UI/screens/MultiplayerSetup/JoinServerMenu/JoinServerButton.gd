extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	self.connect("pressed", self, "_button_pressed")

func _button_pressed():
	var ip = get_node("../IPTextBox").text
	var port = int(get_node("../PortTextBox").text)
	var status = get_node("../StatusTextBox")
	
	var peer = NetworkedMultiplayerENet.new()
	var connectionStatus = peer.create_client(ip, port)
	#NetworkManager.connectToServer(ip, port)
	status.text = "connecting..." + str(connectionStatus)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
