extends Camera2D

@onready var TotalAnts = get_node("TotalAnts")
@onready var TotalAntsText = get_node("TotalAnts/Counter")

@onready var TotalIdle = get_node("TotalIdle")
@onready var TotalIdleText = get_node("TotalIdle/Counter")

@onready var TotalScavs = get_node("TotalScavs")
@onready var TotalScavsText = get_node("TotalScavs/Counter")

@onready var game_scene = get_node("/root/game_scene/TransparentWindow")

# Called when the node enters the scene tree for the first time.
func _ready():
	TotalAnts.position = Vector2(-(game_scene.primaryScreen.size.x / 2) - TotalAnts.texture.width, (game_scene.primaryScreen.size.y / 2) - 130)
	TotalIdle.position = Vector2(-(game_scene.primaryScreen.size.x / 2) - TotalIdle.texture.width, (game_scene.primaryScreen.size.y / 2) - 180)
	TotalScavs.position = Vector2(-(game_scene.primaryScreen.size.x / 2) - TotalScavs.texture.width, (game_scene.primaryScreen.size.y / 2) - 230)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(TotalAnts, "position", Vector2(-(game_scene.primaryScreen.size.x / 2) + 30, (game_scene.primaryScreen.size.y / 2) - 130), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1)
	tween.tween_property(TotalAnts, "modulate", Color(1, 1, 1, 0.8), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1)
	tween.tween_property(TotalIdle, "position", Vector2(-(game_scene.primaryScreen.size.x / 2) + 30, (game_scene.primaryScreen.size.y / 2) - 180), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1.1)
	tween.tween_property(TotalIdle, "modulate", Color(1, 1, 1, 0.8), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1.1)
	tween.tween_property(TotalScavs, "position", Vector2(-(game_scene.primaryScreen.size.x / 2) + 30, (game_scene.primaryScreen.size.y / 2) - 230), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1.2)
	tween.tween_property(TotalScavs, "modulate", Color(1, 1, 1, 0.8), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TotalAntsText.text = "Total Ants: " + str(game_scene.totalAnts)
	TotalIdleText.text = "Jobless Ants: " + str(game_scene.totalIdle)
	TotalScavsText.text = "Scavengers: " + str(game_scene.totalScavs)
