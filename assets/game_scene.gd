extends Window

var debugMode = true

@onready var TransCam = get_node("/root/game_scene/TransparentWindow/TransCam") 
@onready var AntNode = get_node("/root/game_scene/TransparentWindow/TransCam/Ants")
@onready var antScene = load("res://ant.tscn")

var primaryScreen = {screenNum = DisplayServer.get_primary_screen(), size = DisplayServer.screen_get_size(DisplayServer.get_primary_screen()), position = DisplayServer.screen_get_position(DisplayServer.get_primary_screen())}
@onready var game_scene = get_node("/root/game_scene")
@onready var primaryWindow = game_scene.get_window()

var totalAnts = 0
var totalIdle = 0
var totalScavs = 0
var totalFighters = 0

func centerWindow(win:Window, tween:bool = false, duration:float = 0.5, easing:Tween.EaseType = Tween.EASE_IN_OUT, transtype:Tween.TransitionType = Tween.TRANS_LINEAR):
	var targetpos = Vector2i(primaryScreen.position + ((primaryScreen.size / 2) - (win.size / 2)))
	win.position = targetpos

func countAnts():
	totalAnts = 0
	totalIdle = 0
	totalScavs = 0
	totalFighters = 0
	
	for ant in AntNode.get_children():
		totalAnts += 1
		if ant.currentAction == "Idle":
			totalIdle += 1
		elif ant.currentAction == "Scavenging":
			totalScavs += 1
		elif ant.currentAction == "Fighting":
			totalFighters += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	primaryWindow.get_viewport().size = Vector2i(primaryScreen.size.x, primaryScreen.size.y)
	primaryWindow.size = Vector2i(320, 320)

func _input(event):
	if debugMode == true:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
		if event.is_action_pressed("debugSummonAnt"):
			var ant = antScene.instantiate()
			
			AntNode.add_child(ant)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	centerWindow(primaryWindow)
	countAnts()

func _onSummon():
	print("pressed")
	
	var ant = antScene.instantiate()
	AntNode.add_child(ant)
