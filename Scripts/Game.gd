extends Node

func _ready():
	global.main = self
	global.main_menu = load("res://Scenes/TitleScreen.tscn").instance()
	reload_game()
	add_child(global.main_menu)

func reload_game():
	for c in get_children():
		c.queue_free()

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_game()
		get_tree().quit()

func start_game():
	global.map = load("res://Maps/World1-1.tscn").instance()
	global.player = load("res://Scenes/Player.tscn").instance()
	global.player.init()
	add_child(global.map)
	add_child(global.player)
	global.player.set_position(global.map.get_node(global.last_checkpoint).get_position())

func load_game():
	var savegame = File.new()
	if(!savegame.file_exists("user://savegame.save")):
		global.player = load("res://Scenes/Player.tscn").instance()
		return
#	var savenodes = get_tree().get_nodes_in_group("Persist")
#	for i in savenodes:
#		i.queue_free()
	var currentline = {}
	savegame.open_encrypted_with_pass("user://savegame.save", File.READ, "6b3a55e0261b0304143f805a24924d0c1c44524821305f31d9277843b8a10f4e")
	while (!savegame.eof_reached()):
		currentline.parse_json(savegame.get_line())
		var newobject = load(currentline["filename"]).instance()
		newobject.set_pos(Vector2(currentline["posx"],currentline["posy"]))
		for i in currentline.keys():
			if (i == "filename" or i == "parent" or i == "posx" or i == "posy"):
				continue
			newobject.set(i, currentline[i])
	savegame.close()

func save_game():
	var savegame = File.new()
	savegame.open_encrypted_with_pass("user://savegame.save", File.WRITE, "6b3a55e0261b0304143f805a24924d0c1c44524821305f31d9277843b8a10f4e")
	var savenodes = get_tree().get_nodes_in_group("Persist")
	for i in savenodes:
		var nodedata = i.save()
		savegame.store_line(nodedata.to_json())
#	var nodedate = global.player.save()
	savegame.close()
