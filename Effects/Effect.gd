extends AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "_on_animation_finished")
	play("Animate")
	#add_user_signal("animation_finished")

func _on_animation_finished():
	queue_free()
