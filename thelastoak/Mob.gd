extends CharacterBody2D

@onready var player = get_node("/root/Game/World/GeneralSqueek")
@onready var tree = get_node("/root/Game/World/TreeOfLife")
@onready var sprite = $Fox

var speed = 150.0
var health = 2

var is_hurt = false
var is_attacking = false
var attack_cooldown = false

var knockback_velocity = Vector2.ZERO


var current_target = null
var target_timer = 0.0
const TARGET_REFRESH_TIME = 2.0


func _physics_process(delta):

	if player == null:
		return

	
	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
		move_and_slide()
		return

	if is_hurt or is_attacking:
		move_and_slide()
		return

	
	target_timer -= delta

	if current_target == null or target_timer <= 0:
		choose_target()
		target_timer = TARGET_REFRESH_TIME

	var direction = global_position.direction_to(current_target.global_position)

	velocity = direction * speed
	move_and_slide()

	check_attack(current_target)

	update_animation(direction)


func choose_target():

	if tree == null:
		current_target = player
		return

	var player_dist = global_position.distance_to(player.global_position)
	var tree_dist = global_position.distance_to(tree.global_position)

	if tree_dist * 0.8< player_dist:
		current_target = tree
	else:
		current_target = player


func check_attack(target):

	if attack_cooldown:
		return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body == target:
			start_attack()
			return


func start_attack():

	is_attacking = true
	attack_cooldown = true
	velocity = Vector2.ZERO

	sprite.play("Attack")

	await sprite.animation_finished

	is_attacking = false

	await get_tree().create_timer(0.8).timeout
	attack_cooldown = false


func update_animation(direction: Vector2):

	if is_hurt or is_attacking:
		return

	sprite.flip_h = direction.x < 0

	if direction == Vector2.ZERO:
		sprite.play("Idle")
	else:
		sprite.play("Walk")


func take_damage():

	if is_hurt:
		return

	health -= 2
	is_hurt = true

	sprite.play("Hurt")

	
	var knock_dir = global_position.direction_to(player.global_position) * -1
	knockback_velocity = knock_dir * 400

	await sprite.animation_finished

	is_hurt = false

	if health <= 0:
		
		if randf() < 0.35:
			get_node("/root/Game").spawn_powerup(global_position)
			
		get_node("/root/Game").add_score(100)

		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

		queue_free()
