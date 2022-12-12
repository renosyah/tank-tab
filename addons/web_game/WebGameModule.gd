extends Node

signal on_update_score(status)
signal on_scores(scores, status)

const SCORE_OK = 0
const SCORE_ERROR = 1

var host_name :String = ""
var host_protocol :String = ""
var host_port :String = ""

var player_id :String
var player_name :String

var game :WebGameGameData
var scores_http_request :HTTPRequest
var update_score_http_request :HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_player()
	_init_module()
	_init_http_requests()
	
func _init_player():
	if OS.has_feature('JavaScript'):
		player_id = JavaScript.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get('player_id');
		""")
		
		player_name = JavaScript.eval("""
				var url_string = window.location.href;
				var url = new URL(url_string);
				url.searchParams.get('player_name');
			""")
	else:
		player_id = "random_" + str(rand_range(1, 1000))
		player_name = "Guest"
	
func _init_module():
	if OS.has_feature('JavaScript'):
		host_name = JavaScript.eval("""
				window.location.hostname;
			""")
			
		host_protocol = JavaScript.eval("""
				window.location.protocol;
			""")
			
		host_port = JavaScript.eval("""
				window.location.port;
			""")
			
	game = WebGameGameData.new()
	game.id = 6
	game.game_name = "Tank-tab"
	
func _get_base_url():
	if host_port.empty():
		return "{host_protocol}//{host_name}".format(
			{"host_protocol" :host_protocol,"host_name" :host_name}
		)
		
	return "{host_protocol}//{host_name}:{host_port}".format(
		{"host_protocol" :host_protocol,"host_name" :host_name, "host_port" :host_port}
	)
	
func _init_http_requests():
	scores_http_request = HTTPRequest.new()
	scores_http_request.connect("request_completed", self ,"_on_scores_http_request_completed")
	scores_http_request.timeout = 5
	add_child(scores_http_request)
	
	update_score_http_request = HTTPRequest.new()
	update_score_http_request.connect("request_completed", self ,"_on_update_score_http_request_completed")
	add_child(update_score_http_request)
	
func get_scoreboard(offset, limit :int):
	var query = JSON.print({
		"search_by": "game_id",
		"search_value": str(game.id),
		"order_by": "score",
		"order_dir": "desc",
		"offset": offset,
		"limit": limit,
	})
	
	scores_http_request.request(
		_get_base_url() + "/api/score/list.php", 
		["Content-Type: application/json"],
		false, HTTPClient.METHOD_POST, query
	)
	
func _on_scores_http_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("on_scores", [], SCORE_ERROR)
		return
		
	var json :JSONParseResult = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		emit_signal("on_scores", [], SCORE_ERROR)
		return
		
	if not json.result is Dictionary:
		emit_signal("on_scores", [], SCORE_ERROR)
		return
		
	var list :Array = []
	
	for i in json.result["data"]:
		var item :WebGameScoreData = WebGameScoreData.new()
		item.from_dictionary(i)
		list.append(item)
		
	emit_signal("on_scores", list, SCORE_OK)
	
	
func update_scoreboard(score :int):
	var score_data :WebGameScoreData = WebGameScoreData.new()
	score_data.id = 0
	score_data.game_id = game.id
	score_data.player_id = player_id
	score_data.player_name = player_name
	score_data.score = score
	
	update_score_http_request.request(
		_get_base_url() + "/api/score/add.php", 
		["Content-Type: application/json"],
		false, HTTPClient.METHOD_POST,
		JSON.print(score_data.to_dictionary())
	)
	
	
func _on_update_score_http_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("on_update_score", SCORE_OK)
		return
		
	emit_signal("on_update_score", SCORE_OK)
	
	
	
	

	
