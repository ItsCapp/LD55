extends Camera2D

@onready var ResourceBar = get_node("ResourceBar")

@onready var TotalAnts = get_node("ResourceBar/TotalAnts")
@onready var TotalAntsText = get_node("ResourceBar/TotalAnts/Counter")

#@onready var TotalIdle = get_node("TotalIdle")
#@onready var TotalIdleText = get_node("TotalIdle/Counter")

@onready var TotalScavs = get_node("ResourceBar/TotalScavs")
@onready var TotalScavsText = get_node("ResourceBar/TotalScavs/Counter")

@onready var TotalFood = get_node("ResourceBar/TotalFood")
@onready var TotalFoodText = get_node("ResourceBar/TotalFood/Counter")

@onready var TotalStone = get_node("ResourceBar/TotalStone")
@onready var TotalStoneText = get_node("ResourceBar/TotalStone/Counter")

@onready var game_scene = get_node("/root/game_scene/TransparentWindow")

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceBar.scale = Vector2(float(game_scene.primaryScreen.size.x) / 1920, float(game_scene.primaryScreen.size.y) / 1080)
	ResourceBar.position.y = -(game_scene.primaryScreen.size.y / 2) - ((ResourceBar.texture.height * scale.y) * 2)
	
	await get_tree().create_timer(8).timeout
	var tween = create_tween()
	tween.tween_property(ResourceBar, "position", Vector2(0, -(game_scene.primaryScreen.size.y / 2) + ((ResourceBar.texture.height * scale.y) / 2)), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TotalAntsText.text = str(game_scene.totalAnts)
	#TotalIdleText.text = "Jobless Ants: " + str(game_scene.totalIdle)
	TotalScavsText.text = str(game_scene.totalScavs)
	TotalFoodText.text = str(game_scene.food)
	TotalStoneText.text = str(game_scene.stone)
