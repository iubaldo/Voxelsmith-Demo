extends Spatial

onready var saveLoad = preload("res://Scripts/SaveLoad.gd")
onready var voxelOutline = preload("res://Scenes/VoxelOutline.tscn")
onready var voxelGrid = get_parent().get_node("VoxelGrid/Voxels")
onready var voxelHandler = get_tree().get_root().get_node("Smithing Scene")

var outlineList = []
var loadPath = "res://Patterns/pattern1.dat"

var voxelCount = 0
var voxelsLeft = 0
	
func _process(delta):
	translation = voxelGrid.translation
	rotation = voxelGrid.rotation
	
	if outlineList != null:
		for n in get_children():
			n.queue_free()
			
		voxelsLeft = 0
		for pos in outlineList:
			var vox = voxelOutline.instance()
			add_child(vox)
			vox.translation = pos
			voxelsLeft += 1
	
	for outline in get_children():
		for vox in voxelGrid.voxelList:
			if outline.translation == vox.translation:
				outline.queue_free()
				voxelsLeft -= 1
				
	
	if Input.is_action_just_pressed("num1"):
		loadPath = "res://Patterns/pattern1.dat"
		loadData()
	if Input.is_action_just_pressed("num2"):
		loadPath = "res://Patterns/pattern2.dat"
		loadData()
	if Input.is_action_just_pressed("num3"):
		loadPath = "res://Patterns/pattern3.dat"
		loadData()
	
func loadData():
	outlineList = saveLoad.loadData(loadPath) # outlineList = patternDict.patternData
	
	if outlineList == null:
		print("failed to load")
		return

	for n in get_children():
		n.queue_free()
	
	voxelsLeft = 0
	voxelCount = 0
	voxelHandler.voxelsCreated = 0
	
	voxelHandler.cameraForward = Vector3.FORWARD
	voxelHandler.cameraBack =  Vector3.BACK
	voxelHandler.cameraLeft = Vector3.LEFT
	voxelHandler.cameraRight = Vector3.RIGHT
	
	for pos in outlineList:
		var vox = voxelOutline.instance()
		add_child(vox)
		vox.translation = pos
		voxelsLeft += 1
		voxelCount += 1
		
	for n in voxelGrid.get_children():
		n.queue_free()
		
	voxelHandler.voxelsLeftLabel.visible = true
		
	voxelHandler.doneForging = false
	voxelHandler.active = true
	print("loaded")
