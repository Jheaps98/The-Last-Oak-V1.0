extends Area2D

enum PowerType {
	BANDAGE,
	FERTILISER,
	BEANS,
	PEPSI,
	BOMB
}

@export var power_type : PowerType

@onready var sprite = $Sprite2D

const BANDAGE_TEX = preload("res://Powerup/PowerupBandage.png")
const FERTILISER_TEX = preload("res://Powerup/PowerupFertiliser.png")
const BEANS_TEX = preload("res://Powerup/PowerupBeans.png")
const PEPSI_TEX = preload("res://Powerup/PowerupEnergy.png")
const BOMB_TEX = preload("res://Powerup/PowerupBomb.png")

const EXPLOSION = preload("res://smoke_explosion/smoke_explosion.tscn")

func _ready():

	match power_type:

		PowerType.BANDAGE:
			sprite.texture = BANDAGE_TEX

		PowerType.FERTILISER:
			sprite.texture = FERTILISER_TEX

		PowerType.BEANS:
			sprite.texture = BEANS_TEX

		PowerType.PEPSI:
			sprite.texture = PEPSI_TEX

		PowerType.BOMB:
			sprite.texture = BOMB_TEX


func _on_body_entered(body):

	if body.name != "GeneralSqueek":
		return

	match power_type:

		PowerType.BANDAGE:
			body.health = min(body.health + 25, 100)

		PowerType.FERTILISER:
			var tree = get_node("/root/Game/World/TreeOfLife")
			tree.health = min(tree.health + 50, tree.max_health)
			tree.health_bar.value = tree.health   # update UI

		PowerType.BEANS:
			body.apply_speed_buff(25)

		PowerType.PEPSI:
			body.apply_fire_rate_buff(25)

		PowerType.BOMB:
			explode(body)

	queue_free()


func explode(player):

	var radius = 600

	# Spawn explosion effect
	var fx = EXPLOSION.instantiate()
	fx.global_position = global_position
	fx.scale = Vector2(3.5, 3.5)   # MUCH bigger visual
	get_tree().current_scene.add_child(fx)

	# Camera shake
	var cam = player.get_node("Camera2D")
	shake_camera(cam)

	# Damage enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):

		if global_position.distance_to(enemy.global_position) < radius:
			enemy.health = 0
			enemy.take_damage()


func shake_camera(cam):

	for i in 6:
		cam.position = Vector2(
			randf_range(-15,15),
			randf_range(-15,15)
		)
		await get_tree().create_timer(0.03).timeout

	cam.position = Vector2.ZERO


func _process(delta):

	rotation += delta
	position.y += sin(Time.get_ticks_msec() * 0.005) * 0.2
