extends Node2D

signal hitted (health: float)
signal dead ()

@export var health_max := 100.0
@export var health := 100.0
@export var is_alive := true

func hit (damage: float) -> void:
	health = max(health - damage, 0)
	hitted.emit(damage)
	
	if health <= 0:
		is_alive = false
		dead.emit()

