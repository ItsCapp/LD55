extends Sprite2D

var rng = RandomNumberGenerator.new()

var path = null
var pathFollow = null
var pathLength = 0
var pathTime = 0

var targetPos = Vector2(0, 0)
var currentAction = "Idle"

func newPath(startPos, targetPos):
	path.curve.set_point_position(0, startPos)
	path.curve.set_point_position(1, targetPos)
	path.curve.set_point_out(0, Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10)))
	
	pathLength = path.get_curve().get_baked_length()
	pathTime = 0
	pathFollow.progress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(0, 0))
	path.curve.add_point(Vector2(1, 1))
	
	pathFollow = PathFollow2D.new()
	pathFollow.loop = false
	
	add_child(path)
	path.add_child(pathFollow)

var actioninterval = 0
var actionwait = rng.randf_range(0.5, 5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pathFollow.progress_ratio >= 0.99:
		pathFollow.progress_ratio = 1
		actioninterval += delta
	else:
		pathTime += delta
		pathFollow.progress = pathTime * 100
	
	if actioninterval > actionwait and currentAction == "Idle":
		targetPos = Vector2(rng.randf_range(-1000, 1000), rng.randf_range(-1000, 1000))
		actioninterval = 0
		actionwait = rng.randf_range(0.5, 5)
		
		newPath(position, targetPos)
	elif actioninterval > actionwait and currentAction == "Scavenging":
		targetPos = Vector2(1920, 1080)
		actioninterval = 0
		actionwait = rng.randf_range(5, 10)
		
		newPath(position, targetPos)
	
	position = lerp(position, pathFollow.position, 0.2)
	rotation = lerp(rotation, pathFollow.rotation, 0.2)
