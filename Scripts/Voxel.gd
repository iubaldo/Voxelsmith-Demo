extends Spatial

onready var mesh = get_node("MeshInstance")
onready var defaultMat = mesh.get_surface_material(0)
onready var outlineMesh = get_node("OutlineMesh")
onready var heatGradient = preload("res://Shaders/Gradients/HeatGradient2.tres")

# metal attributes
var voxelStrikePenalty = 0 # determines how much more power is needed to strike this voxel
var heatResist = 5 # determines heat increase rate, range(0 - 10)
var heatTol = 2000 # determines max heat before voxel melts and is removed from the grid
var minForgeTemp = 1000 # min heat required to forge, applies strike power penalty
var optForgeTemp = 1200 # optimal heat to forge, no strike penalty

var heat = 0.0 # range(0, heatTol)

var isTargeted = false

func _physics_process(delta):
	outlineMesh.visible = true if isTargeted else false
		
	var mat = SpatialMaterial.new()
	mat.albedo_color = getMaterialColor()
	mesh.set_surface_material(0, mat)
	
	heat = clamp(heat + 5, 0, heatTol)
	print(var2str(heat / heatTol))
		
func getMaterialColor():
	var scaledHeat = heat / heatTol
	return heatGradient.interpolate(scaledHeat)

func _on_Area_mouse_entered():
	isTargeted = true

func _on_Area_mouse_exited():
	isTargeted = false
