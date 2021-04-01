extends Spatial

onready var mesh = get_node("MeshInstance")
onready var mat
onready var defaultMat = mesh.get_surface_material(0)

var heat = 0
var isTargeted = false

func _physics_process(delta):
	if isTargeted:
		mat = SpatialMaterial.new()
		mat.albedo_color = Color(1, 0, 0)
		mesh.set_surface_material(0, mat)
	else:
		mesh.set_surface_material(0, defaultMat)

func _on_Area_mouse_entered():
	isTargeted = true

func _on_Area_mouse_exited():
	isTargeted = false
