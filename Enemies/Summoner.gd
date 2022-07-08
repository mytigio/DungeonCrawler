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
			if (!summoning && attackReady):
				summoning = true
				attackReady = false
				start_summoning()
			elif (!summoning):
					var direction = -global_position.direction_to(target.global_position)
					velocity = velocity.move_toward(MAX_SPEED*direction, ACCELERATION*delta)
			

func start_summoning():
	var summonEffectPlayer = SummonEffect.instance()
	var summonEffectSummoner = SummonEffect.instance()
	summonPosition = target.position	
	summonEffectPlayer.position = summonPosition
	summonEffectSummoner.position = position
	get_parent().add_child(summonEffectPlayer)
	get_parent().add_child(summonEffectSummoner)
	summonEffectPlayer.connect("animation_finished", self, "_on_summon_animation_finished")
	
func _on_summon_animation_finished():
	var validOptions = getValidArrayIndexes()
	var summonedEnemy = summonOptions[validOptions[randi() % validOptions.size()]].instance()
	summonedEnemy.position = summonPosition
	get_parent().add_child(summonedEnemy)
	summoning = false
	attackController.start_attack_timer(0)
	
func getValidArrayIndexes():
	var validIndex = []
	for n in range(0, summoningLevel.size()):
		var summoningLvl = summoningLevel[n]
		print(str(summoningLvl) +" <= "+str(stats.level) +" = "+str(summoningLvl <= stats.level))
		if (summoningLvl <= stats.level):
			validIndex.push_back(n)	
	return validIndex
