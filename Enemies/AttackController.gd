extends Node2D

export(int) var attack_range = 32
export(int) var timer_min_time = 2
export(int) var timer_max_time = 6

onready var attack_target = global_position
onready var timer = $Timer

signal attack_recharged

func _ready():
	start_attack_timer(0)

func get_time_left():
	return timer.time_left
	
func start_attack_timer(modifier):
	var timerDuration = rand_range(timer_min_time+modifier,timer_max_time+modifier)
	print(timerDuration)
	timer.start(timerDuration)

func _on_Timer_timeout():
	print("attack timer complete")
	emit_signal("attack_recharged")
