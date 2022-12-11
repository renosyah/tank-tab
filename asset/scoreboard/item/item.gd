extends HBoxContainer

export var num :int
export var player_name :String
export var score :int

onready var _num = $num
onready var _player_name = $name
onready var _score = $score

# Called when the node enters the scene tree for the first time.
func _ready():
	_num.text = str(num)
	_player_name.text = player_name
	_score.text = str(score)
