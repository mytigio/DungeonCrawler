extends KinematicBody2D

const DeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

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

onready var sprite = $Sprite
onready var stats = $Stats
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var detectionArea: Area2D = $DetectionBox
onready var blinkPlayer = $BlinkAnimationPlayer

func _ready():
	stats.level = level
	stats.max_health = stats.max_health+log(level+1)
	stats.health = stats.max_health

func _physics_process(delta):
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
	
func move(velocity):
	sprite.flip_h = velocity.x < 0
	return move_and_slide(velocity)
	
func setLevel(level: int):
	if (level < 1):
		level = 1
	self.level = level
	

func _on_HurtBox_area_entered(area):
	if (hurtBox.invincible == false):
		knockback = area.knockback_vector * 130
		stats.health -= area.current_damage
		hurtBox.start_invicibility(0.5)
		hurtBox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = DeathEffect.instance()
	enemyDeathEffect.position = position
	GameManager.add_points(stats.point_value)
	get_parent().add_child(enemyDeathEffect)

func _on_DetectionBox_body_entered(body):
	target = body
	state = CHASE

func _on_DetectionBox_body_exited(body):	
	state = WANDER
	target = null


func _on_HurtBox_invincibility_ended():
	print("invincibility stopped")
	blinkPlayer.play("Stop")


func _on_HurtBox_invincibility_started():
	print("invincibility started")
	blinkPlayer.play("Start")
