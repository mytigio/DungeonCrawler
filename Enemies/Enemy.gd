extends KinematicBody2D

const DeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var id

var level = 1

var target = null
var target_in_sight = false
var attackReady = true

var state = WANDER

export(int) var MAX_SPEED = 35
export(int) var ACCELERATION = 50
export(int) var FRICTION = 20

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var initialized = false

onready var sprite = $Sprite
onready var stats = $Stats
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var detectionArea: Area2D = $DetectionBox
onready var blinkPlayer = $BlinkAnimationPlayer

func _ready():
	#if (is_network_master()):
	id = hash(get_instance_id())
	#name = name + "_" + str(id)
	stats.level = level
	stats.max_health = stats.max_health+log(level+1)
	stats.health = stats.max_health
	initialized = true
	#else:
		#rpc_id(1, "request_initialization")
		
master func request_initialization():
	rpc_id(get_tree().get_rpc_sender_id(), "initialize", id, name, stats.level, stats.max_health, stats.health)

puppet func initialize(node_id, node_name, level, max_health, health):
	id = node_id
	name = node_name
	stats.level = level
	stats.max_health = max_health
	stats.health = health
	initialized = true

func _physics_process(delta):
	if(is_network_master()):
		if (knockback):
			knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
			knockback = move(knockback)
		
		match state:
			IDLE: 
				idleState(delta)
			WANDER:
				wanderState(delta)
			CHASE:
				chaseState(delta)
				
		if softCollision.is_colliding():
			velocity += (softCollision.get_push_vector() * delta * MAX_SPEED)
		
		move(velocity)
		rpc_unreliable("sync_puppets", velocity, position, state)

func sightCheck():
	var space_state = get_world_2d().direct_space_state
	var combined_mask = collision_mask
	var target_mask = detectionArea.collision_mask
	combined_mask = combined_mask | target_mask
	var sight_check = space_state.intersect_ray(position, target.position, [self], combined_mask)
	if (sight_check and sight_check.collider.collision_layer == target_mask):
		target_in_sight = true
	else:
		target_in_sight = false

func swapState():
	if (wanderController.get_time_left() == 0):
		state = pick_random_state([IDLE, WANDER])
		wanderController.start_wander_timer()

func idleState(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)	
	swapState()

func wanderState(delta):
	var direction = global_position.direction_to(wanderController.target_position)
	velocity = velocity.move_toward(MAX_SPEED*direction, ACCELERATION*delta)
	swapState()

func chaseState(delta):
	if target != null:
		sightCheck()
		if target_in_sight == true:
			var direction = global_position.direction_to(target.global_position)	
			velocity = velocity.move_toward(MAX_SPEED*direction, ACCELERATION*delta)

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func setSpriteOrientation(velocity):
	sprite.flip_h = velocity.x < 0

func move(velocity):
	setSpriteOrientation(velocity)
	move_and_slide(velocity)
	
puppet func sync_puppets(velocity, final_position, master_state):
	if (initialized):
		setSpriteOrientation(velocity)
		move_and_slide(velocity)
		#reset the position to the servers position regardless of the calculated outcome.
		position = final_position
		state = master_state
	
	
func setLevel(level: int):
	if (level < 1):
		level = 1
	self.level = level
	

func _on_HurtBox_area_entered(area):
	if (is_network_master() and hurtBox.invincible == false):
		knockback = area.knockback_vector * 130
		print("area.current_damage: " + str(area.current_damage))
		stats.health -= area.current_damage
		hurtBox.start_invicibility(0.5)
		hurtBox.create_hit_effect()
	else:
		hurtBox.create_hit_effect()

func _on_Stats_no_health():
	if (is_network_master()):
		GameManager.add_points(stats.point_value)
		rpc("process_death")
		
puppetsync func process_death():
	queue_free()
	var enemyDeathEffect = DeathEffect.instance()
	enemyDeathEffect.position = position
	get_parent().add_child(enemyDeathEffect)

func _on_DetectionBox_body_entered(body):
	if (is_network_master()):
		print(name + " set new target: " + body.name)
		target = body
		state = CHASE
	else:
		pass
		
puppet func detectedPuppet(rpc_id):
	pass

func _on_DetectionBox_body_exited(body):
	print(name + " lost target")
	state = WANDER
	target = null


func _on_HurtBox_invincibility_ended():
	print("invincibility stopped")
	blinkPlayer.play("Stop")


func _on_HurtBox_invincibility_started():
	print("invincibility started")
	blinkPlayer.play("Start")
