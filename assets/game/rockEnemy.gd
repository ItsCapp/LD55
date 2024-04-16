extends Sprite2D

var rng = RandomNumberGenerator.new()
@onready var game_scene = get_node("/root/game_scene/TransparentWindow")

var health = 3
var path = null
var pathFollow = null
var pathTime = 0
@onready var speed = rng.randf_range(10, 20)

func damage(damage):
	health -= damage

# Called when the node enters the scene tree for the first time.
func _ready():
	path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(position.x, position.y), Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30)))
	path.curve.add_point(Vector2(0, 0))
	
	pathFollow = PathFollow2D.new()
	pathFollow.loop = false
	
	pathTime = 0
	pathFollow.progress = 0
	
	add_child(path)
	path.add_child(pathFollow)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pathTime += delta
	pathFollow.progress = pathTime * speed
	
	position = lerp(position, pathFollow.position, 0.2)
	rotation = lerp(rotation, pathFollow.rotation, 0.2)
	
	if health <= 0:
		queue_free()
	
	if pathFollow.progress_ratio > 0.99:
		get_tree().reload_current_scene()
