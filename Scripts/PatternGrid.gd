extends Spatial

onready var saveLoad = preload("res://Scripts/SaveLoad.gd")
onready var voxelOutline = preload("res://Scenes/VoxelOutline.tscn")
onready var voxelGrid = get_parent().get_node("VoxelGrid")

var outlineList = []
var loadPath = "res://Patterns/pattern1.dat"
	
func _process(delta):
	translation = voxelGrid.translation
	rotation = voxelGrid.rotation
	
	for outline in get_children():
		for vox in voxelGrid.voxelList:
			if outline.translation == vox.translation:
				outline.queue_free()	
	
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
		
	for pos in outlineList:
		var vox = voxelOutline.instance()
		add_child(vox)
		vox.translation = pos
		
	print("loaded")
