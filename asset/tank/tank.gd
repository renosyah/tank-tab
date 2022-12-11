extends KinematicBody2D
class_name Tank

const bullet = preload("res://asset/bullet/bullet.tscn")

const explode = preload("res://asset/tank/explosion.wav")
const firing = preload("res://asset/tank/laserShoot.wav")

signal hit(tank)
signal destroy(tank)
signal on_tap(tank)

export var color :Color = Color.white
export var speed : float = 150
export var margin : float = 5
export var hp :int = 5
export var max_hp :int = 5

var is_dead :bool = false

var target = null
var is_aiming :bool = false

export var move_to :Vector2
export var is_moving :bool = false

onready var turret = $turret
onready var hull = $hull
onready var ray_cast_2d = $turret/RayCast2D
onready var collision_shape = $CollisionShape
onready var bullet_spawn_point = $turret/bullet_spawn_point
onready var bullet_target_point = $turret/bullet_target_point
onready var audio_stream_player = $AudioStreamPlayer
onready var firing_delay = $firing_delay

func _ready():
	modulate = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead:
		return
		
	_aim(delta)
	_moving(delta)
	
func make_ready():
	hp = max_hp
	is_aiming = false
	is_dead = false
	visible = true
	target = null
	
func take_hit():
	if is_dead:
		return
		
	hp -= 1
	
	if hp < 1:
		is_aiming = false
		is_dead = true
		visible = false
		position = Vector2(-500, -500)
		target = null
		audio_stream_player.stream = explode
		audio_stream_player.play()
		emit_signal("destroy", self)
		return
		
		
	emit_signal("hit", self)
	
func _aim(delta):
	if not is_aiming:
		return
		
	if not is_instance_valid(target):
		return
		
	var angle :float = position.angle_to_point(target.global_position)
	turret.global_rotation = lerp_angle(turret.global_rotation, angle, 5 * delta)
	
	if not firing_delay.is_stopped():
		return
	
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider() != target:
			return
		
		var projectile = bullet.instance()
		projectile.move_to = bullet_target_point.global_position
		projectile.position = bullet_spawn_point.global_position
		add_child(projectile)
		is_aiming = false
		target = null
		audio_stream_player.stream = firing
		audio_stream_player.play()
		firing_delay.start()
	
func _moving(delta):
	if not is_moving:
		return
		
	var angle :float = position.angle_to_point(move_to)
	turret.global_rotation = lerp_angle(turret.global_rotation, angle, 5 * delta)
	hull.rotation = lerp_angle(hull.rotation, angle, 5 * delta)
	collision_shape.rotation = hull.rotation
	
	var direction = position.direction_to(move_to)
	var distance = position.distance_to(move_to)
	if distance < margin:
		is_moving = false
		return
		
	move_and_slide(direction * speed)
	
func _on_tank_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("on_tap", self)
