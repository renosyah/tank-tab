extends Sprite

export var color :Color = Color.white

onready var animation_player = $AnimationPlayer

func click():
	modulate = color
	animation_player.play("click")
