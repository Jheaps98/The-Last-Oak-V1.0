extends StaticBody2D

signal health_depleted

@export var max_health = 500
var health = 500

const DAMAGE_RATE = 5.0

@onready var hurtbox = %TreeHurtBox
@onready var health_bar = %ProgressBar


func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health


func _process(delta):

	var overlapping_bodies = hurtbox.get_overlapping_bodies()
	var enemy_count = 0
	
	for body in overlapping_bodies:
		if body.is_in_group("enemy"):
			enemy_count += 1
	
	if enemy_count > 0:
		var damage = DAMAGE_RATE * enemy_count * delta
		health -= damage
		health_bar.value = health
		
		if health <= 0:
			TreeHealthDepleted()
			
func TreeHealthDepleted():
	%GameOverScreen.visible = true
	get_tree().paused = true
	
@onready var leaves = $TreeLifeLeaves

func _on_leaves_area_body_entered(body):

	if body.name == "GeneralSqueek":
		leaves.modulate.a = 0.4


func _on_leaves_area_body_exited(body):

	if body.name == "GeneralSqueek":
		leaves.modulate.a = 1.0

func heal(amount):

	health = min(health + amount, max_health)
	health_bar.value = health
