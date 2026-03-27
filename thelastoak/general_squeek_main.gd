extends CharacterBody2D

signal health_depleted

@export var health = 100.0

@export var base_speed = 250
@export var base_fire_rate = 0.25

var speed = base_speed
var fire_rate = base_fire_rate

var speed_buff_timer = 0.0
var fire_rate_buff_timer = 0.0

@onready var speed_icon = get_node("/root/Game/PowerupHUD/Control/HBoxContainer/SpeedBuffIcon")
@onready var speed_label = speed_icon.get_node("Label")

@onready var fire_icon = get_node("/root/Game/PowerupHUD/Control/HBoxContainer/FireRateBuffIcon")
@onready var fire_label = fire_icon.get_node("Label")

const BULLET = preload("res://bullet.tscn")

var is_shooting = false
var can_shoot = true
var last_direction = 1


func _physics_process(delta):

	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity = direction.normalized() * speed
	move_and_slide()

	update_animation(direction)

	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	
	if speed_buff_timer > 0:
		speed_buff_timer -= delta
		if speed_buff_timer <= 0:
			speed = base_speed

	
	if fire_rate_buff_timer > 0:
		fire_rate_buff_timer -= delta
		if fire_rate_buff_timer <= 0:
			fire_rate = base_fire_rate
			
	
	if speed_buff_timer > 0:
		speed_icon.visible = true
		speed_label.text = str(int(speed_buff_timer) + 1)
	else:
		speed_icon.visible = false

	
	if fire_rate_buff_timer > 0:
		fire_icon.visible = true
		fire_label.text = str(int(fire_rate_buff_timer) + 1)
	else:
		fire_icon.visible = false

	
	const DAMAGE_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()


func update_animation(direction):

	if not is_shooting:

		if velocity.x != 0:
			last_direction = sign(velocity.x)

		$AnimatedSprite2D.flip_h = last_direction < 0

		if direction == Vector2.ZERO:
			if $AnimatedSprite2D.animation != "Idle":
				$AnimatedSprite2D.play("Idle")
		else:
			if $AnimatedSprite2D.animation != "Walk":
				$AnimatedSprite2D.play("Walk")


func shoot():

	can_shoot = false
	is_shooting = true

	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %Muzzle.global_position

	var direction = %Muzzle.global_position.direction_to(get_global_mouse_position())
	new_bullet.rotation = direction.angle()

	new_bullet.set_collision_mask_value(1, false)

	get_tree().current_scene.add_child(new_bullet)

	var mouse_dir = get_global_mouse_position() - global_position
	$AnimatedSprite2D.flip_h = mouse_dir.x < 0

	$AnimatedSprite2D.play("Shoot")

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


func _on_animated_sprite_2d_animation_finished():

	if $AnimatedSprite2D.animation == "Shoot":
		is_shooting = false


func apply_speed_buff(duration):

	speed = base_speed * 1.5
	speed_buff_timer = duration


func apply_fire_rate_buff(duration):

	fire_rate = base_fire_rate * 0.5
	fire_rate_buff_timer = duration
