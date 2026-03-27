extends Node2D

@onready var tree = $World/TreeOfLife
@onready var spawn_timer = $Timer
@onready var wave_label = $WaveHUD/WaveLabel
var score = 0
var difficulty_timer = 0.0
var difficulty_level = 1
var max_enemies = 20
var spawn_time = 2.0

func spawn_mob():

	if get_tree().get_nodes_in_group("enemy").size() >= max_enemies:
		return

	var new_mob = preload("res://FiendishFox.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	
	new_mob.speed += difficulty_level * 3
	new_mob.health += difficulty_level * 0.3

	add_child(new_mob)

func add_score(amount):
	score += amount
	$GameOverScreen/ScoreLabel.text = "Score: " + str(score)


func _on_timer_timeout() -> void:
	spawn_mob()


func _on_general_squeek_health_depleted() -> void:
	%GameOverScreen.visible = true
	get_tree().paused = true
	
const POWERUP = preload("res://PowerupBandage.tscn")

func spawn_powerup(pos):

	var p = POWERUP.instantiate()
	p.global_position = pos
	p.power_type = randi() % 5
	
	add_child(p)
	
func _process(delta):

	difficulty_timer += delta

	if difficulty_timer > 30:
		increase_difficulty()
		difficulty_timer = 0

func increase_difficulty():

	difficulty_level += 1
	
	spawn_time = max(spawn_time * 0.95, 0.7)
	spawn_timer.wait_time = spawn_time
	
	tree.heal(125)
	
	show_wave()
	
func show_wave():

	wave_label.text = "WAVE " + str(difficulty_level)
	wave_label.visible = true

	await get_tree().create_timer(2).timeout

	wave_label.visible = false

@onready var pause_menu = $CanvasLayer/PauseMenu


func _input(event):

	if event.is_action_pressed("ui_cancel"):

		if get_tree().paused:
			get_tree().paused = false
			pause_menu.visible = false
		else:
			get_tree().paused = true
			pause_menu.visible = true
			
func restart_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_restart_button_pressed() -> void:
	restart_to_menu()
