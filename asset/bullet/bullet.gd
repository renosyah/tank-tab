extends Area2D

const MAX_DISTANCE = 1200.0

export var speed :float = 250
export var move_to :Vector2

var travel_distance = 0.0
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	velocity = position.direction_to(move_to)
	look_at(move_to)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var _distance = speed * delta
	position += velocity * _distance
	travel_distance += _distance
	
	if travel_distance > MAX_DISTANCE:
		stop_projectile()
		return
		
func stop_projectile():
	queue_free()
	
func _on_bullet_body_entered(body):
	if body.has_method("take_hit"):
		body.take_hit()
		stop_projectile()
