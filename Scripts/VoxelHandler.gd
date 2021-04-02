extends Spatial

onready var voxel = preload("res://Scenes/Voxel.tscn")
onready var voxelGrid = get_node("VoxelGrid")
onready var powerLabel = get_node("SmithingUI/PowerLabel")
onready var remainingVoxelsLabel = get_node("SmithingUI/RemainingVoxelsLabel")
onready var heatLabel = get_node("SmithingUI/HeatLabel")
onready var strikeTimer = get_node("StrikeTimer")

var voxelList = []
var pritchelHole = [Vector3(8.5, 0.5, -1.5), Vector3(9.5, 0.5, -1.5), Vector3(8.5, 0.5, -0.5), Vector3(9.5, 0.5, -0.5),
					Vector3(8.5, 0.5, 0.5), Vector3(9.5, 0.5, 0.5), Vector3(8.5, 0.5, 1.5), Vector3(9.5, 0.5, 1.5)]
var targetVoxel = null

var remainingVoxels = 50

var maxPower = 500
var strikePower = 0
var powerIncreaseRate = 250

var lightHeatLoss = 25
var medHeatLoss = 50
var heavyHeatLoss = 100

var cameraForward = Vector3.FORWARD
var cameraBack =  Vector3.BACK
var cameraLeft = Vector3.LEFT
var cameraRight = Vector3.RIGHT

var mousecastLength = 50

func _process(delta):
	if strikePower != 0:
		powerLabel.text = "Power: " + var2str(int(strikePower))
	else:
		powerLabel.text = ""
		
	remainingVoxelsLabel.text = "Remaining Metal: " + var2str(remainingVoxels)
	heatLabel.text = "Heat: " + var2str(int(voxelGrid.heat))
		
		
	voxelList = voxelGrid.get_children()
		
	if Input.is_action_just_pressed("pointer") && !strikeTimer.is_stopped():
		if strikePower <= 100:
			pass #some kind of penalty for too light
		elif strikePower > 100 && strikePower <= 400:
			Strike(targetVoxel, strikePower)
			strikePower = 0
			print("strike")
		else:
			pass #some kind of penality for too hard
		
	if Input.is_action_pressed("pointer") && strikeTimer.is_stopped():
		if strikePower < maxPower:
			strikePower += powerIncreaseRate * delta
			
			if strikePower > maxPower:
				strikePower = maxPower
				
	if Input.is_action_just_released("pointer"):
		strikeTimer.start()
		
	if Input.is_action_pressed("shift"):
		for vox in voxelList:
			vox.setHeat(200, delta)
		
	# add ingot (debug)
	if Input.is_action_just_pressed("1"):
		addIngot(1)
		
	# Move grid commands
	if Input.is_action_just_pressed("rotateCW"):
		rotateCW()
	if Input.is_action_just_pressed("rotateCCW"):
		rotateCCW()
		
	if Input.is_action_just_pressed("ui_up"):
		moveGrid(1)
	if Input.is_action_just_pressed("ui_right"):
		moveGrid(2)
	if Input.is_action_just_pressed("ui_down"):
		moveGrid(3)
	if Input.is_action_just_pressed("ui_left"):
		moveGrid(4)
		
func _physics_process(delta):
	if !voxelList.empty():
		for vox in voxelList:
			if vox != null && vox.isTargeted:
				targetVoxel = vox
				break
		
func Strike(target, power):
	var targetList = []
	
	if power <= 200: # light
		if pritchelHole.has(target.global_transform.origin):
			target.queue_free()
		else:
			targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward))
	elif power <= 300: # medium
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraLeft))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraRight))
	elif power <= 400: # heavy
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraLeft))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraRight))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward + cameraRight))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward + cameraLeft))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack + cameraRight))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack + cameraLeft))
		
	for pos in targetList:
		if pos != null && remainingVoxels > 0:
			var vox = voxel.instance()
			voxelGrid.add_child(vox)
			vox.translation = pos
			vox.heat = voxelGrid.heat
			remainingVoxels -= 1
					
	targetVoxel.heat = clamp(targetVoxel.heat - 50, 0, targetVoxel.heatTol)
		
func checkExistingVoxel(targetPos):
	for vox in voxelList:
		if vox.translation == targetPos:
			print("occupied: " + var2str(vox.translation))
			vox.heat = clamp(targetVoxel.heat - 25, 0, targetVoxel.heatTol)
			return null
	
	print("position added")
	return targetPos
	
func addIngot(size):
	if voxelList.empty():
		match size:
			1:
				for x in range (-4, 3):
					for z in range (-1 ,2):
						var vox = voxel.instance()
						voxelGrid.add_child(vox)
						vox.translation = Vector3(x, 0, z)
						
		voxelGrid.translation = Vector3(0.5, 0.5, -0.5)
	else:
		match size:
			1:
				remainingVoxels += 32
	

func rotateCW():
	voxelGrid.rotate_y(deg2rad(-90.0))
	
	var temp = cameraForward
	cameraForward = cameraLeft;
	cameraLeft = cameraBack;
	cameraBack = cameraRight;
	cameraRight = temp;
	
func rotateCCW():
	voxelGrid.rotate_y(deg2rad(90.0))
	
	var temp = cameraForward
	cameraForward = cameraRight;
	cameraRight = cameraBack;
	cameraBack = cameraLeft;
	cameraLeft = temp;
	
func moveGrid(direction):
	match direction:
		1: # up
			if (voxelGrid.translation.z + Vector3.FORWARD.z >= -7.5):
				voxelGrid.translation += Vector3.FORWARD
		2: # right
			if (voxelGrid.translation.x + Vector3.RIGHT.x <= 15.5):
				voxelGrid.translation += Vector3.RIGHT
		3: # down
			if (voxelGrid.translation.z + Vector3.BACK.z <= 7.5):
				voxelGrid.translation += Vector3.BACK
		4: # left
			if (voxelGrid.translation.x + Vector3.LEFT.x >= -15.5):
				voxelGrid.translation += Vector3.LEFT

func _on_StrikeTimer_timeout():
	strikePower = 0
