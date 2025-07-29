extends Area2D

@export var active_duration := 1.0
@export var inactive_duration := 2.0
@export var damage := 10

var is_active := false

func _ready():
	$Timer.wait_time = inactive_duration
	$Timer.start()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_timer_timeout():
	is_active = !is_active

	if is_active:
		activate_spikes()
		$Timer.wait_time = active_duration


	$Timer.start()

func activate_spikes():
	$AnimatedSprite2D.play("spike_up")

func _on_body_entered(body):
	if is_active and body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage)
