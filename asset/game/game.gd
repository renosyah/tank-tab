extends Node

const tank_scene = preload("res://asset/tank/tank.tscn")

onready var _y_sort = $YSort
onready var _screen_size = get_viewport().get_visible_rect().size
onready var _score = $CanvasLayer/ui_panel/MarginContainer3/score
onready var _hp = $CanvasLayer/ui_panel/hp
onready var _hurt = $CanvasLayer/hurt

onready var _game_over_panel = $CanvasLayer/game_over_panel
onready var _ui_panel = $CanvasLayer/ui_panel

onready var _tank = $YSort/tank

var score : int = 0
var enemy_pools :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	_game_over_panel.visible = false
	_ui_panel.visible = true
	
	_tank.position = _screen_size / 2
	
	pooling_enemy()
	display_score()

func get_random_y(_spawn_point :Control):
	var x = _spawn_point.rect_global_position.x
	var y = _spawn_point.rect_global_position.y
	var y_size = _spawn_point.rect_size.y
	y = rand_range(y + 50 , y + y_size - 50)
	return Vector2(x , y)
	
func _on_enemy_spawn_timer_timeout():
	spawn_enemy_tank()

func _on_enemy_action_timer_timeout():
	command_enemy_tank()
	
func pooling_enemy():
	for i in range(5):
		var tank = tank_scene.instance()
		tank.color = Color.red
		tank.is_dead = true
		tank.position = Vector2(-500, -500)
		tank.max_hp = 1
		tank.hp = 1
		tank.connect("on_tap", self,"_on_enemy_tank_on_tap")
		tank.connect("destroy", self, "_on_enemy_tank_destroy")
		_y_sort.add_child(tank)
		enemy_pools.append(tank)
	
func spawn_enemy_tank():
	var pos = get_random_y(
		$CanvasLayer/spawn_point_1 if randf() > 0.5 else $CanvasLayer/spawn_point_2
	)
	
	var x = rand_range(40, _screen_size.x - 40)
	var y = rand_range(120, _screen_size.y - 120)
	var to = Vector2(x, y)
	
	for enemy_pool in enemy_pools:
		if enemy_pool.is_dead:
			enemy_pool.make_ready()
			enemy_pool.position = pos
			enemy_pool.move_to = to
			enemy_pool.is_moving = true
			return
	
func command_enemy_tank():
	var alive_enemy_pools = []
	for enemy_pool in enemy_pools:
		if not enemy_pool.is_dead and not enemy_pool.is_aiming:
			alive_enemy_pools.append(enemy_pool)
			
	alive_enemy_pools.shuffle()
	
	for enemy_pool in alive_enemy_pools:
		if randf() > 0.5:
			var x = rand_range(40, _screen_size.x - 40)
			var y = rand_range(120, _screen_size.y - 120)
			enemy_pool.move_to = Vector2(x, y)
			enemy_pool.is_moving = true
			enemy_pool.is_aiming = false
			
		else:
			enemy_pool.target = _tank
			enemy_pool.is_aiming = true
			enemy_pool.is_moving = false
			
func display_score():
	_score.text = "Score : " + str(score)
	_hp.text = "Hp : " + str(_tank.hp)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		_tank.move_to = event.position
		_tank.is_moving = true
		
func _on_enemy_tank_on_tap(tank):
	_tank.target = tank
	_tank.is_moving = false
	_tank.is_aiming = true
	
func _on_enemy_tank_destroy(tank):
	score += 1
	display_score()
	
func _on_pause_pressed():
	get_tree().change_scene("res://asset/menu/menu.tscn")
	
func _on_tank_hit(tank):
	display_score()
	
	if not _game_over_panel.visible:
		_hurt.show_hurt()
		
func _on_tank_destroy(tank):
	if _game_over_panel.visible:
		return
		
	if _tank.is_dead:
		WebGameModule.update_scoreboard(score)
		_game_over_panel.visible = true
		_ui_panel.visible = false
		
	display_score()
	
func _on_play_again_pressed():
	_tank.position = _screen_size / 2
	_tank.make_ready()
	_game_over_panel.visible = false
	_ui_panel.visible = true
	score = 0
	display_score()
	
	
	
	
	
	
	
	
	
	





