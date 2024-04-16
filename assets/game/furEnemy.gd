extends Sprite2D

var rng = RandomNumberGenerator.new()
@onready var game_scene = get_node("/root/game_scene/TransparentWindow")
@onready var itemSprite = get_node("itemSprite")

var health = 1
var path = null
var pathFollow = null
var pathTime = 0
var stolenFood = false
@onready var speed = rng.randf_range(30, 40)
@onready var startPosition = position

func damage(damage):
	health -= damage

# Called when the node enters the scene tree for the first time.
func _ready():
	path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(position.x, position.y), Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30)))
	path.curve.add_point(Vector2(300, -150))
	
	pathFollow = PathFollow2D.new()
	pathFollow.loop = false
	
	pathTime = 0
	pathFollow.progress = 0
	
	add_child(path)
	path.add_child(pathFollow)

func changeCarrying(item):
	if item == "random":
		var possibleItems = ["food", "mushroom"]
		item = possibleItems[rng.randi_range(0, 1)]
	
	if item == "food":
		itemSprite.texture = load("res://assets/game/food.png")
	elif item == "mushroom":
		itemSprite.texture = load("res://assets/game/mushroom.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pathTime += delta
	pathFollow.progress = pathTime * speed
	
	position = lerp(position, pathFollow.position, 0.2)
	rotation = lerp(rotation, pathFollow.rotation, 0.2)
	
	if pathFollow.progress_ratio > 0.99 and stolenFood == false:
		stolenFood = true
		speed *= 3
		pathTime = 0
		pathFollow.progress = 0
		path.curve.set_point_position(0, Vector2(300, -150))
		path.curve.set_point_position(1, startPosition)
		changeCarrying("random")
	elif pathFollow.progress_ratio > 0.99 and stolenFood == true:
		queue_free()
		game_scene.food -= 2
	
	if health <= 0:
		queue_free()
	
	itemSprite.position = Vector2(position.x, position.y - 15)
