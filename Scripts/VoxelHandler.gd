extends Spatial

onready var voxel = preload("res://Scenes/Voxel.tscn")
onready var voxelGrid = get_node("VoxelGrid")
onready var powerLabel = get_node("PowerLabel").get_node("Label")
onready var strikeTimer = get_node("StrikeTimer")

var voxelArray = []
var voxelList = []
var targetVoxel = null
var areaWidth = 32
var areaHeight = 16
var anvilWidth = 16
var anvilHeight = 8
var offsetX = areaWidth / 2
var offsetY = areaHeight / 2

var maxPower = 500
var strikePower = 0
var powerIncreaseRate = 250

var cameraForward = Vector3.RIGHT
var cameraBack =  Vector3.BACK
var cameraLeft = Vector3.LEFT
var cameraRight = Vector3.FORWARD

var mousecastLength = 50

func _ready():
	for x in range(areaWidth):
		voxelArray.append([])
		voxelArray[x] = []
		for y in range(areaHeight):
			voxelArray[x].append([])
			voxelArray[x][y] = null

func _process(delta):
	if strikePower != 0:
		powerLabel.text = "Power: " + var2str(int(strikePower))
	else:
		powerLabel.text = ""
		
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
	for vox in voxelList:
		if vox.isTargeted:
			targetVoxel = vox
			break
		
func Strike(target, power):
	var targetList = []
	
	if power <= 200: # light
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
		if pos != null:
			var vox = voxel.instance()
			voxelGrid.add_child(vox)
			vox.translation = pos
		
func checkExistingVoxel(targetPos):
	for pos in voxelList:
		if pos.translation == targetPos:
			print("voxel found at position: " + var2str(pos.translation))
			return null
	
	print("position added")
	return targetPos

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
			voxelGrid.translation += Vector3.RIGHT
		2: # right
			voxelGrid.translation += Vector3.BACK
		3: # down
			voxelGrid.translation += Vector3.LEFT
		4: # left
			voxelGrid.translation += Vector3.FORWARD

func _on_StrikeTimer_timeout():
	strikePower = 0