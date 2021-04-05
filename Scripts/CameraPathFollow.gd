extends Path

onready var pathFollow = get_node("PathFollow")
onready var voxelHandler = get_parent()
onready var tween = get_node("PathTween")

var direction = 1
var duration = 1

func _process(delta):
	if Input.is_action_just_pressed("move"):
		startFollow()

func startFollow():
	tween = Tween.new()
	add_child(tween)
	if direction > 0:
		tween.interpolate_property(pathFollow, "unit_offset", 0 , 1, duration, tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	else:
		tween.interpolate_property(pathFollow, "unit_offset", 1 , 0, duration, tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.start()
	direction = -direction
	
