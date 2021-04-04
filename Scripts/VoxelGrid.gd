extends Spatial

var voxelList = []
var outlineList = []

# grid attributes
var gridHeat = 0 # average of all heat values in grid
var gridStrikePenalty = 0 # determines how much more power is needed to strike any given voxel in the grid
					  # addititive with voxelStrikePenalty
var hardness = 50 # determines max sharpness, range(0 - 100)
var density = 50 # determines base strike power penalty, range(0 - 100)
var weight = 0 # (# of voxels * density), determines attack speed of final product and attack for blunt weapon
var toughness = 0 # determines durability

# weapon attributes
var attack = 0
var attackSpeed = 0
var maxSharpness = 0
var sharpness = 0
var durability = 0

onready var saveLoad = preload("res://Scripts/SaveLoad.gd")

func _process(delta):
	voxelList = get_children()
	
	outlineList.clear()
	for vox in voxelList:
		outlineList.push_back(vox.translation)

	if !voxelList.empty():
		var sum = 0
		for vox in voxelList:
			sum += vox.heat
		gridHeat = sum / voxelList.size()
	else:
		gridHeat = 0
		
	if Input.is_action_just_pressed("debug_save"):
		saveLoad.saveData("user://pattern.dat", outlineList)
	if Input.is_action_just_pressed("debug_load"):
		pass	
	
