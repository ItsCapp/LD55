extends Sprite2D

var rng = RandomNumberGenerator.new()
@onready var game_scene = get_node("/root/game_scene/TransparentWindow")
@onready var foodicon = get_node("/root/game_scene/TransparentWindow")
@onready var foodparticle = load("res://assets/game/foodeatparticle.tscn")

var path = null
var pathFollow = null
var pathTime = 0
@onready var speed = rng.randf_range(100, 150)

var health =  3

var targetPos = Vector2(0, 0)
var currentAction = "Idle"
var currentlyCarrying = "Nothing"
@onready var itemSprite = get_node("itemSprite")

@onready var followoffset = rng.randf_range(-100, 100)
var attackCooldown = 2

var hurtSound = AudioStreamPlayer.new()
var eatSound = AudioStreamPlayer.new()
var killSound = AudioStreamPlayer.new()
var collectSound = AudioStreamPlayer.new()

func newPath(startPos, endPos, curve, delta):
	path.curve.set_point_position(0, startPos)
	path.curve.set_point_position(1, endPos)
	path.curve.set_point_out(0, Vector2(rng.randf_range(-curve, curve), rng.randf_range(-curve, curve)))
	
	pathTime = 0 + (delta * 3)
	pathFollow.progress = pathTime * speed

func changeCarrying(item):
	if item == "random":
		var possibleItems = ["food", "stone", "mushroom"]
		item = possibleItems[rng.randi_range(0, 2)]
	
	if item == "food":
		itemSprite.texture = load("res://assets/game/food.png")
	elif item == "stone":
		itemSprite.texture = load("res://assets/game/stone.png")
	elif item == "mushroom":
		itemSprite.texture = load("res://assets/game/mushroom.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	path = Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(0, 0))
	path.curve.add_point(Vector2(1, 1))
	
	pathFollow = PathFollow2D.new()
	pathFollow.progress_ratio = 1
	pathFollow.loop = false
	
	actioninterval = 5
	
	add_child(path)
	path.add_child(pathFollow)
	
	add_child(hurtSound)
	hurtSound.stream = load("res://assets/game/sounds/dmg1.ogg")
	hurtSound.volume_db = 20
	
	add_child(eatSound)
	eatSound.stream = load("res://assets/game/sounds/eat.ogg")
	eatSound.volume_db = 20
	
	add_child(killSound)
	killSound.stream = load("res://assets/game/sounds/kill1.ogg")
	killSound.volume_db = 20
	
	add_child(collectSound)
	collectSound.stream = load("res://assets/game/sounds/collect1.ogg")
	collectSound.volume_db = 20

func eat(amount):
	if game_scene.food - amount < 0:
		killSound.pitch_scale = rng.randf_range(0.75, 1.25)
		killSound.play()
		health -= 1
		
		if health == 0:
			queue_free()
	else:
		game_scene.food -= amount
		eatSound.pitch_scale = rng.randf_range(0.75, 1.25)
		eatSound.play()
	
	var particle = foodparticle.instantiate()
	particle.position = Vector2(0, 0)
	particle.amount = amount
	particle.emitting = true
	add_child(particle)
	await get_tree().create_timer(3).timeout
	particle.queue_free()

var actioninterval = 0
var foodinterval = 0
var actionwait = rng.randf_range(0.5, 5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	foodinterval += delta
	
	if currentAction == "Idle":
		if foodinterval > 60:
			foodinterval = 0
			eat(1)
	elif currentAction == "Scavenging" or currentAction == "Collecting":
		if foodinterval > 50:
			foodinterval = 0
			eat(1)
	elif currentAction == "Fighting":
		if foodinterval > 20:
			foodinterval = 0
			eat(1)
	
	if pathFollow.progress_ratio >= 0.99:
		pathFollow.progress_ratio = 1
		actioninterval += delta
		
		if currentlyCarrying == "Resources" and currentAction == "Scavenging":
			currentlyCarrying = "Nothing"
			itemSprite.texture = null
			game_scene.food += rng.randi_range(2, 5)
			game_scene.stone += rng.randi_range(0, 2)
			
			collectSound.pitch_scale = rng.randf_range(0.75, 1.25)
			collectSound.play()
	elif currentAction == "Fighting":
		actioninterval += delta
		pathTime += delta
		pathFollow.progress = pathTime * speed
	else:
		pathTime += delta
		pathFollow.progress = pathTime * speed
	
	if actioninterval > actionwait and currentAction == "Idle":
		targetPos = position + Vector2(rng.randf_range(-100, 100), rng.randf_range(-100, 100))
		if targetPos.x > 400:
			targetPos.x = 400
		if targetPos.x < -400:
			targetPos.x = -400
		if targetPos.y > 400:
			targetPos.y = 400
		if targetPos.y < -400:
			targetPos.y = -400
		
		actioninterval = 0
		actionwait = rng.randf_range(0.5, 2.5)
		
		newPath(position, targetPos, 0, delta)
	elif actioninterval > actionwait and currentAction == "Scavenging":
		var side = rng.randi_range(1, 4)
		if side == 1:
			targetPos = Vector2(rng.randf_range(-1060, 1060), -640)
		elif side == 2:
			targetPos = Vector2(rng.randf_range(-1060, 1060), 640)
		elif side == 3:
			targetPos = Vector2(-1060, rng.randf_range(-640, 640))
		elif side == 4:
			targetPos = Vector2(1060, rng.randf_range(-640, 640))
		actioninterval = 0
		actionwait = rng.randf_range(5, 15)
		
		newPath(position, targetPos, 20, delta)
		currentAction = "Collecting"
	elif actioninterval > actionwait and currentAction == "Collecting":
		targetPos = Vector2(300, -150)
		actioninterval = 0
		actionwait = rng.randf_range(1, 2)
		
		currentlyCarrying = "Resources"
		changeCarrying("random")
		
		newPath(position, targetPos, 20, delta)
		currentAction = "Scavenging"
	elif actioninterval > actionwait and currentAction == "Fighting":
		if texture != load("res://assets/game/archerant.png"):
			texture = load("res://assets/game/archerant.png")
		if game_scene.EnemyNode.get_child_count() == 0:
			actioninterval = 0
			actionwait = 0.5
			
			targetPos = position + Vector2(rng.randf_range(-100, 100), rng.randf_range(-100, 100))
			if targetPos.x > 400:
				targetPos.x = 400
			if targetPos.x < -400:
				targetPos.x = -400
			if targetPos.y > 400:
				targetPos.y = 400
			if targetPos.y < -400:
				targetPos.y = -400
			
			newPath(position, targetPos + Vector2(rng.randf_range(-followoffset, followoffset), rng.randf_range(-followoffset, followoffset)), 0, delta)
		else:
			actioninterval = 0
			actionwait = 0.2
			targetPos = (get_viewport().get_mouse_position() - Vector2(game_scene.primaryScreen.size / 2))
			newPath(position, targetPos + Vector2(rng.randf_range(-followoffset, followoffset), rng.randf_range(-followoffset, followoffset)), 0, delta)
	
	pathFollow.rotates = true
	
	position = lerp(position, pathFollow.position, 0.2)
	rotation = lerp(rotation, pathFollow.rotation, 0.2)
	
	itemSprite.position = Vector2(position.x, position.y - 15)
	
	attackCooldown -= delta
	for enemy in enemyArray:
		if attackCooldown < 0:
			attackCooldown = 2
			enemy.get_parent().damage(1)
			hurtSound.pitch_scale = rng.randf_range(0.75, 1.25)
			hurtSound.play()

var enemyArray = []
func body_entered(body):
	enemyArray.append(body)

func body_exited(body):
	enemyArray.erase(body)
