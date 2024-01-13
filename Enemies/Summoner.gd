extends "res://Enemies/Enemy.gd"

const SummonEffect = preload("res://Effects/SummoningCircle.tscn")

export(Array, int) var summoningLevel
export(Array, Resource) var summonOptions

var summoning = false;
var summonPosition;
onready var attackController = $AttackController


func _on_AttackController_attack_recharged():
	attackReady = true

func chaseState(delta):
	if target != null:
		sightCheck()
		if target_in_sight == true:
			print(name + " has target is in sight")
			if (!summoning && attackReady):
				summoning = true
				attackReady = false
				start_summoning()
			elif (!summoning):
					var direction = -global_position.direction_to(target.global_position)
					velocity = velocity.move_toward(MAX_SPEED*direction, ACCELERATION*delta)
			

func start_summoning():
	if (is_network_master()):
		rpc("summon_effects", target.position, position)
	else:
		pass

puppetsync func summon_effects(target_pos, source_pos):
	var summonEffectPlayer = SummonEffect.instance()
	var summonEffectSummoner = SummonEffect.instance()
	summonPosition = target_pos
	summonEffectPlayer.position = summonPosition
	summonEffectSummoner.position = source_pos
	get_parent().add_child(summonEffectPlayer)
	get_parent().add_child(summonEffectSummoner)
	if (is_network_master()):
		summonEffectPlayer.connect("animation_finished", self, "_on_summon_animation_finished")
	
func _on_summon_animation_finished():
	if (is_network_master()):
		var validOptions = getValidArrayIndexes()
		var enemyType = summonOptions[validOptions[randi() % validOptions.size()]]
		var summonedEnemy = enemyType.instance()
		summonedEnemy.name = "summon_" + summonedEnemy.name + "_" + str(summonedEnemy.get_instance_id())
		summonedEnemy.position = summonPosition
		get_parent().add_child(summonedEnemy)
		var parent = get_parent()
		var fileName = enemyType.get_path()
		
		rpc("summon_monster", fileName, summonedEnemy.name, summonedEnemy.position)
		summoning = false
		attackController.start_attack_timer(0)

puppet func summon_monster(type, name, position):
	var monster_scene = load(type)
	var monster = monster_scene.instance()
	monster.name = name
	monster.position = position
	monster.set_network_master(1)	
	get_parent().add_child(monster)
	
func getValidArrayIndexes():
	var validIndex = []
	for n in range(0, summoningLevel.size()):
		var summoningLvl = summoningLevel[n]
		print(str(summoningLvl) +" <= "+str(stats.level) +" = "+str(summoningLvl <= stats.level))
		if (summoningLvl <= stats.level):
			validIndex.push_back(n)	
	return validIndex
