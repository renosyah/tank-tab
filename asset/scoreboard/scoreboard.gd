extends Node

onready var holder = $VBoxContainer/ScrollContainer/VBoxContainer

onready var scroll_container = $VBoxContainer/ScrollContainer

onready var loading_text = $VBoxContainer/loading_text
onready var error_text = $VBoxContainer/error_text
onready var empty_text = $VBoxContainer/empty_text

onready var page = $VBoxContainer/ui_panel2/MarginContainer4/page

var current_page :int = 1
var offset :int = 0
var limit :int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	WebGameModule.connect("on_scores", self, "_on_scores")
	get_scoreboard(offset, limit)
	
func get_scoreboard(offset, limit :int):
	scroll_container.visible = false
	loading_text.visible = true
	error_text.visible = false
	empty_text.visible = false
	
	WebGameModule.get_scoreboard(offset, limit)

func _on_scores(scores :Array, status :int):
	loading_text.visible = false
	
	if status != WebGameModule.SCORE_OK:
		error_text.visible = true
		return
	
	if scores.empty():
		empty_text.visible = true
		return
	
	scroll_container.visible = true
	
	for i in holder.get_children():
		holder.remove_child(i)
		i.queue_free()
		
	var pos :int = 1
	for i in scores:
		var data :WebGameScoreData = i
		var item = preload("res://asset/scoreboard/item/item.tscn").instance()
		item.num = pos
		item.player_name = data.player_name
		item.score = data.score
		holder.add_child(item)
		pos += 1
	
func _on_back_pressed():
	get_tree().change_scene("res://asset/menu/menu.tscn")

func _on_prev_pressed(): 
	if offset <= 0:
		return
		
	offset -= limit
	current_page -= 1
	get_scoreboard(offset, limit)
	page.text = "Page : " + str(current_page)
	
func _on_next_pressed():
	offset += limit
	current_page +=1
	get_scoreboard(offset, limit)
	page.text = "Page : " + str(current_page)
	
