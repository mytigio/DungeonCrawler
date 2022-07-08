extends "res://Enemies/Enemy.gd"

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _onready():
	animationTree.active = true

func idleState(delta):
	animationState.travel("Idle")
	.idleState(delta)
	
func move(velocity):
	var movingLeft = velocity.x < 0	
	if (velocity != Vector2.ZERO):
		var direction = 1
		if (movingLeft):
			direction = -1
		animationTree.set("parameters/Idle/blend_position", direction)
		animationTree.set("parameters/Run/blend_position", direction)
		animationState.travel("Run")
		.move(velocity)
