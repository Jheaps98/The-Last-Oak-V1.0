extends AnimatedSprite2D

var health = 3

func update_animation(direction: Vector2):
	flip_h = direction.x < 0
	
	if direction == Vector2.ZERO:
		play("Idle")
	else:
		play("Walk")
		
func take_damage():
	health -= 1
	
	if health == 0:
		queue_free()
	
