extends Spatial

onready var voxel = preload("res://Scenes/Voxel.tscn")
onready var voxelGrid = get_node("VoxelGrid")
onready var voxelGridCollider = get_node("VoxelGrid/Area")
onready var powerLabel = get_node("SmithingUI/PowerLabel")
onready var remainingVoxelsLabel = get_node("SmithingUI/RemainingVoxelsLabel")
onready var heatLabel = get_node("SmithingUI/HeatLabel")
onready var strikeTimer = get_node("StrikeTimer") # amount of time to click again after charging a strike
onready var strikeCDTimer = get_node("StrikeCDTimer")
onready var hammerAnimPlayer = get_node("HammerNode/HammerAnimPlayer")
onready var hammerModel = get_node("HammerNode")
onready var cameraShake = get_node("CameraPath/PathFollow/Camera/ScreenShake")
onready var heatPoint = get_node("Environment/Forge/HeatPoint")

var active = true
var forgeActive = false

var voxelList = []
var pritchelHole = Rect2(8.5, -1.5, 2, 4)
var anvilBounds = Rect2(-11.5, -5.5, 23, 11)
var targetVoxel = null
var removal = false

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
	heatLabel.text = "Heat: " + var2str(int(voxelGrid.gridHeat))
	
	if Input.is_action_just_pressed("move"):
		active = !active
		
	if forgeActive:
		pass
	
	
	if active:
		if strikePower != 0:
			powerLabel.text = "Power: " + var2str(int(strikePower))
		else:
			powerLabel.text = ""
			
		remainingVoxelsLabel.text = "Remaining Metal: " + var2str(remainingVoxels)
	
		voxelList = voxelGrid.get_children()
			
		if strikeCDTimer.is_stopped():	
			if Input.is_action_just_pressed("pointer") && !strikeTimer.is_stopped():
				if strikePower <= 100:
					pass #some kind of penalty for too light
				elif strikePower > 100 && strikePower <= 400:
					hammerModel.visible = true
					hammerModel.translation = targetVoxel.global_transform.origin + Vector3.UP
					hammerAnimPlayer.play("HammerStrike")
					#Strike(targetVoxel, strikePower)
					#strikePower = 0
					#print("strike")
					pass
				else:
					pass #some kind of penality for too hard
				
			if Input.is_action_pressed("pointer") && strikeTimer.is_stopped(): # charge strike
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
		if Input.is_action_just_pressed("2"):
			addIngot(2)
			
		# Move grid commands
		if strikeCDTimer.is_stopped():
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
	else:
		remainingVoxelsLabel.text = ""
	
func _physics_process(delta):
	if !voxelList.empty():
		for vox in voxelList:
			if vox != null && vox.isTargeted:
				targetVoxel = vox
				break
		
func animStrike():
	cameraShake.start(0.05 + 0.1 * (strikePower / 500), 50, 0.5 * ((strikePower) / 100), 0)
	Strike(targetVoxel, strikePower)
	strikeCDTimer.start()
	strikePower = 0
		
func Strike(target, power):
	var targetList = []
	removal = false
	
	if pritchelHole.has_point(Vector2(targetVoxel.global_transform.origin.x, targetVoxel.global_transform.origin.z)):
		removal = true
	
	if power <= 200: # light
		targetList.push_back(checkExistingVoxel(targetVoxel.translation, targetVoxel.global_transform.origin, 1))
		if !removal:
			targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward, targetVoxel.global_transform.origin + cameraForward, 1))
	elif power <= 300: # medium
		targetList.push_back(checkExistingVoxel(targetVoxel.translation, targetVoxel.global_transform.origin, 2))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward, targetVoxel.global_transform.origin + cameraForward, 2))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack, targetVoxel.global_transform.origin + cameraBack, 2))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraLeft, targetVoxel.global_transform.origin + cameraLeft, 2))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraRight, targetVoxel.global_transform.origin + cameraRight, 2))
	elif power <= 400: # heavy
		targetList.push_back(checkExistingVoxel(targetVoxel.translation, targetVoxel.global_transform.origin, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward, targetVoxel.global_transform.origin + cameraForward, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack, targetVoxel.global_transform.origin + cameraBack, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraLeft, targetVoxel.global_transform.origin + cameraLeft, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraRight, targetVoxel.global_transform.origin + cameraRight, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward + cameraRight, targetVoxel.global_transform.origin + cameraForward + cameraRight, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraForward + cameraLeft, targetVoxel.global_transform.origin + cameraForward + cameraLeft, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack + cameraRight, targetVoxel.global_transform.origin + cameraBack + cameraRight, 3))
		targetList.push_back(checkExistingVoxel(targetVoxel.translation + cameraBack + cameraLeft, targetVoxel.global_transform.origin + cameraBack + cameraLeft, 3))
		
	if !removal:
		for pos in targetList:
			if pos != null && remainingVoxels > 0:
				var vox = voxel.instance()
				voxelGrid.add_child(vox)
				vox.translation = pos
				vox.heat = targetVoxel.heat
				remainingVoxels -= 1
		
func checkExistingVoxel(targetPos, globalTargetPos, powerLevel):
	var heatLoss = 0
	match powerLevel:
		1: heatLoss = lightHeatLoss
		2: heatLoss = medHeatLoss
		3: heatLoss = heavyHeatLoss
	
	for vox in voxelList:
		if vox.translation == targetPos:
			if pritchelHole.has_point(Vector2(vox.global_transform.origin.x, vox.global_transform.origin.z)):
				vox.queue_free()
				# print("invalid position: " + var2str(vox.translation))
				return null
				
			vox.heat = clamp(vox.heat - heatLoss, 0, vox.heatTol)
			return null
	if !anvilBounds.has_point(Vector2(globalTargetPos.x, globalTargetPos.z)) \
		|| pritchelHole.has_point(Vector2(globalTargetPos.x, globalTargetPos.z)):
		return null
	
	# print("position added")
	return targetPos
	
func addIngot(size):
	if voxelList.empty():
		match size:
			1:
				for x in range (-4, 3):
					for z in range (-1 , 3):
						var vox = voxel.instance()
						voxelGrid.add_child(vox)
						vox.translation = Vector3(x, 0, z)
			2: 
				for x in range (-1, 3):
					for z in range(-1, 2):
						var vox = voxel.instance()
						voxelGrid.add_child(vox)
						vox.translation = Vector3(x, 0, z)
						
		voxelGrid.translation = Vector3(0.5, 0.5, -0.5)
		voxelGrid.rotation = Vector3(0, 0, 0)
	else:
		match size:
			1:
				remainingVoxels += 32
			2: 
				remainingVoxels += 12
	

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

func _on_StrikeCDTimer_timeout():
	hammerModel.visible = false

func _on_PathTween_tween_completed(object, key):
	forgeActive = !forgeActive
	voxelGridCollider.disabled = !voxelGridCollider.disabled

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if forgeActive:
		pass
