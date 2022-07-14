extends KinematicBody2D

export(int) var MAX_SPEED = 70
export(float) var INVINCIBILITY_AFTER_HIT = 5.0
export(int) var ROLL_STAMINA_COST = 1
onready var ROLL_SPEED = MAX_SPEED * 2

var block_stamina_drain = false

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var rolling = false

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sword = $SwingingWeapon
onready var swordHitbox = $SwingingWeapon/Hitbox
onready var hurtBox = $HurtBox
onready var blinkPlayer = $FlashAnimationPlayer

func _ready():
	stats.connect("no_health", self, "queue_free")
	set_weapon_info()
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if is_network_master():
		match state:
			MOVE:
				move_state(delta)
			ROLL:
				role_state(delta)
			ATTACK:
				attack_state(delta)
		
		# set other players
		rset("puppet_motion", velocity)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_motion

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	input_vector.y = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	animationState.travel("Run")
	input_vector = input_vector.normalized()
	if (input_vector != Vector2.ZERO):
		roll_vector = input_vector
		swordHitbox.knockback_vector = roll_vector
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		velocity = input_vector * MAX_SPEED
	else:
		animationState.travel("Idle")
		velocity = Vector2.ZERO

	velocity = move()
	
	if (can_roll() and Input.is_action_just_pressed("roll")):
		state = ROLL
	
	if (Input.is_action_just_pressed("attack")):
		state = ATTACK
	
	if (Input.is_action_just_pressed("escape_menu")):
		var escapeOverlay = $CanvasLayer/PauseMenu/Popup
		print("escape menu triggered")
		if (!escapeOverlay.visible):
			escapeOverlay.show()
		else:
			escapeOverlay.hide()


func set_weapon_info():
	sword.texture = stats.weapon_texture
	swordHitbox.stamina_cost = stats.weapon_stamina_cost
	swordHitbox.damage = stats.weapon_damage
	swordHitbox.current_damage = stats.weapon_damage
	var swordCollision = $SwingingWeapon/Hitbox/CollisionShape2D
	swordCollision.shape = stats.weapon_collision

func can_roll():
	return (state != ROLL and stats.stamina >= ROLL_STAMINA_COST)

func role_state(delta):
	block_stamina_drain = true
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	velocity = move()
	
func move():
	velocity = move_and_slide(velocity)
	return velocity

func attack_state(delta):	
	if (stats.stamina < swordHitbox.stamina_cost):
		swordHitbox.current_damage = (ceil(swordHitbox.damage / 2))
	else:
		block_stamina_drain = true
	animationState.travel("Attack")	
	velocity = Vector2.ZERO

func attack_finish():
	if (block_stamina_drain):
		stats.stamina -= swordHitbox.stamina_cost
		block_stamina_drain = false
	swordHitbox.current_damage = swordHitbox.damage
	state = MOVE
	
func roll_finish():
	if (block_stamina_drain):
		stats.stamina -= ROLL_STAMINA_COST
		block_stamina_drain = false
	state = MOVE

func _on_HurtBox_area_entered(area):
	if (hurtBox.invincible == false):
		stats.health -= area.current_damage
		hurtBox.start_invicibility(INVINCIBILITY_AFTER_HIT)
		hurtBox.create_hit_effect()

func _on_HurtBox_invincibility_started():
	blinkPlayer.play("Start")


func _on_HurtBox_invincibility_ended():
	blinkPlayer.play("Stop")
