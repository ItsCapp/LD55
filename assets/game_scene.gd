extends Window

var debugMode = false
var rng = RandomNumberGenerator.new()

@onready var TransCam = get_node("/root/game_scene/TransparentWindow/TransCam") 
@onready var AntNode = get_node("/root/game_scene/TransparentWindow/TransCam/Ants")
@onready var antScene = load("res://ant.tscn")
@onready var spawnParticle = load("res://assets/game/spawnParticle.tscn")

var primaryScreen = {screenNum = DisplayServer.get_primary_screen(), size = DisplayServer.screen_get_size(DisplayServer.get_primary_screen()), position = DisplayServer.screen_get_position(DisplayServer.get_primary_screen())}
@onready var game_scene = get_node("/root/game_scene")
@onready var primaryWindow = game_scene.get_window()
var centerWin = false

var totalAnts = 0
var totalIdle = 0
var totalScavs = 0
var totalFighters = 0

var food = rng.randi_range(2, 4)
var stone = 0

func centerWindow(win:Window):
	var targetpos = Vector2i(primaryScreen.position + ((primaryScreen.size / 2) - (win.size / 2)))
	win.position = targetpos

func resizeWindow(win:Window, xScale:int, yScale:int, tween:bool = false, duration:float = 0.5, easing:Tween.EaseType = Tween.EASE_IN_OUT, transtype:Tween.TransitionType = Tween.TRANS_LINEAR):
	if xScale < 64:
		xScale = 64
	if yScale < 64:
		yScale = 64
	
	var targetpos = Vector2i(((win.size.x - xScale) / 2), ((win.size.y - yScale) / 2))
	var targetsize = Vector2i(xScale, yScale)
	
	if tween:
		var tween_window = create_tween()
		tween_window.set_parallel(true)
		tween_window.tween_property(win, "position", win.position + targetpos, duration).set_ease(easing).set_trans(transtype)
		tween_window.tween_property(win, "size", targetsize, duration).set_ease(easing).set_trans(transtype)
	else:
		win.position += targetpos
		win.size = targetsize

func countAnts():
	totalAnts = 0
	totalIdle = 0
	totalScavs = 0
	totalFighters = 0
	
	for ant in AntNode.get_children():
		totalAnts += 1
		if ant.currentAction == "Idle":
			totalIdle += 1
		elif ant.currentAction == "Scavenging" or ant.currentAction == "Collecting":
			totalScavs += 1
		elif ant.currentAction == "Fighting":
			totalFighters += 1

func addAnts(default = false):
	if food >= 5 or default:
		var ant = antScene.instantiate()
		AntNode.add_child(ant)
		
		if not default:
			food -= 5
		
		var particle = spawnParticle.instantiate()
		particle.emitting = true
		if not default:
			particle.position = Vector2(0, 0)
		TransCam.add_child(particle)
		
		await get_tree().create_timer(3).timeout
		particle.queue_free()

func changeRole(from, to):
	for ant in AntNode.get_children():
		if ant.currentAction == from:
			ant.currentAction = to
			break

# Called when the node enters the scene tree for the first time.
func _ready():
	primaryWindow.get_viewport().size = Vector2i(primaryScreen.size.x, primaryScreen.size.y)
	primaryWindow.borderless = false
	primaryWindow.size = Vector2i(64, 64)
	primaryWindow.position = Vector2i(primaryScreen.position + ((primaryScreen.size / 2) - (primaryWindow.size / 2)))
	resizeWindow(primaryWindow, 320, 320, true, 2, Tween.EASE_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(2).timeout
	centerWin = true
	
	for i in range(5):
		await get_tree().create_timer(1).timeout
		addAnts(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
	
	if event.is_action_pressed("enableDebugMode"):
		debugMode = true
	
	if debugMode == true:
		if event.is_action_pressed("debugSummonAnt"):
			var ant = antScene.instantiate()
			AntNode.add_child(ant)
		if event.is_action_pressed("debugGiveFood"):
			food += 1
		if event.is_action_pressed("debugGiveStone"):
			stone += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if centerWin:
		centerWindow(primaryWindow)
	countAnts()
