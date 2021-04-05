extends Spatial

onready var voxel = preload("res://Scenes/Voxel.tscn")
onready var voxelGrid = get_node("VoxelGrid/Voxels")
onready var outlineGrid = get_node("OutlineGrid")

onready var powerLabel = get_node("SmithingUI/PowerLabel")
onready var remainingVoxelsLabel = get_node("SmithingUI/RemainingVoxelsLabel")
onready var remainingVoxelsBox = get_node("SmithingUI/RemainingVoxelsBox")
onready var heatLabel = get_node("SmithingUI/HeatLabel")
onready var voxelsLeftLabel = get_node("SmithingUI/VoxelsLeftLabel")
onready var powerBar = get_node("SmithingUI/PowerBar")
onready var completeBox = get_node("SmithingUI/SmithingCompleteBox")
onready var completeText = get_node("SmithingUI/SmithingCompleteLabel")

onready var strikeTimer = get_node("StrikeTimer") # amount of time to click again after charging a strike
onready var strikeCDTimer = get_node("StrikeCDTimer")

onready var hammerAnimPlayer = get_node("HammerNode/HammerAnimPlayer")
onready var hammerModel = get_node("HammerNode")

onready var camera = get_node("CameraPath/PathFollow/Camera")
onready var cameraShake = get_node("CameraPath/PathFollow/Camera/ScreenShake")

onready var heatPoint = get_node("Environment/Forge/HeatPoint")

onready var audioPlayer = get_node("AudioPlayer")
onready var hitSound1 = preload("res://Sounds/anvilHit1.wav")
onready var hitSound2 = preload("res://Sounds/anvilHit2.wav")
onready var hitSound3 = preload("res://Sounds/anvilHit3.wav")
onready var hitSound4 = preload("res://Sounds/anvilHit4.wav")
onready var hitSound5 = preload("res://Sounds/anvilHit5.wav")
var hitSounds = [ hitSound1, hitSound2, hitSound3, hitSound4, hitSound5 ]

onready var guard1 = preload("res://Scenes/SwordComponents/Guard1.tscn")
onready var guard2 = preload("res://Scenes/SwordComponents/Guard2.tscn")
onready var guard3 = preload("res://Scenes/SwordComponents/Guard3.tscn")
onready var handle1 = preload("res://Scenes/SwordComponents/Handle1.tscn")
onready var handle2 = preload("res://Scenes/SwordComponents/Handle2.tscn")
onready var handle3 = preload("res://Scenes/SwordComponents/Handle3.tscn")
onready var pommel1 = preload("res://Scenes/SwordComponents/Pommel1.tscn")
onready var pommel2 = preload("res://Scenes/SwordComponents/Pommel2.tscn")
onready var pommel3 = preload("res://Scenes/SwordComponents/Pommel3.tscn")

var active = true
var forgeActive = false
var doneForging = false
var quitReady = false

var guardSet = false
var handleSet = false
var pommelSet = false

var voxelList = []
var pritchelHole = Rect2(8.5, -1.5, 2, 4)
var anvilBounds = Rect2(-11.5, -5.5, 23, 11)
var targetVoxel = null
var removal = false

var remainingVoxels = 50
var voxelsCreated = 0

var maxPower = 400
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

func _ready():
	addIngot(2)

func _process(delta):
	heatLabel.text = "Heat: " + var2str(int(voxelGrid.gridHeat))
	
	if Input.is_action_just_pressed("move"):
		active = !active
		voxelGrid.rotation = Vector3.ZERO
		cameraForward = Vector3.FORWARD
		cameraBack =  Vector3.BACK
		cameraLeft = Vector3.LEFT
		cameraRight = Vector3.RIGHT
		
	if quitReady && Input.is_action_just_pressed("pointer"):
		get_tree().quit()
		
	if doneForging:
		for vox in voxelList:
			vox.setHeat(-10, delta)
		if Input.is_action_just_pressed("1"):
			if !guardSet:
				guard1.instance()
				guardSet = true
			if !handleSet:
				handle1.instance()
				handleSet = true
			if !pommelSet:
				pommel1.instance()
				pommelSet = true
		if Input.is_action_just_pressed("2"):
			if !guardSet:
				guard2.instance()
				guardSet = true
			if !handleSet:
				handle2.instance()
				handleSet = true
			if !pommelSet:
				pommel2.instance()
				pommelSet = true
		if Input.is_action_just_pressed("3"):
			if !guardSet:
				guard3.instance()
				guardSet = true
			if !handleSet:
				handle3.instance()
				handleSet = true
			if !pommelSet:
				pommel3.instance()
				pommelSet = true
			
	if doneForging:
		completeBox.visible = true
		completeText.visible = true
		quitReady = true
		
	if forgeActive:
		outlineGrid.visible = false
		if Input.is_action_pressed("pointer"):
			var dropPlane = Plane(Vector3(0, 0, 1), -7)
			var mousePos = camera.project_position(get_viewport().get_mouse_position(), 23)
			voxelGrid.global_transform.origin = Vector3(mousePos.x, voxelGrid.global_transform.origin.y, mousePos.z)
			
		if Input.is_action_just_pressed("rotateCW"):
				rotateCW()
		if Input.is_action_just_pressed("rotateCCW"):
			rotateCCW()
	else:
		outlineGrid.visible = true
	
	if active:
		if strikePower != 0:
			powerLabel.text = "Power: " + var2str(int(strikePower))	
		else:
			powerLabel.text = ""
			
		powerBar.value = strikePower
		
		if outlineGrid.voxelsLeft > 0:
			voxelsLeftLabel.text = "Voxels left: " + var2str(voxelsCreated) + "/" + var2str(outlineGrid.voxelCount)
			remainingVoxelsBox.visible = true
		else: 
			voxelsLeftLabel.text = ""
			remainingVoxelsBox.visible = false
			
		if voxelsCreated == outlineGrid.voxelCount && outlineGrid.voxelCount != 0 && !doneForging:
			doneForging = true
			active = false		
			
			var tween = Tween.new()
			tween.interpolate_property(voxelGrid, "translation", voxelGrid.translation, Vector3(0.5, 3, -0.5), 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
			
			print ("done")
			
		
			
#		remainingVoxelsLabel.text = "Remaining Metal: " + var2str(remainingVoxels)
	
		voxelList = voxelGrid.get_children()
			
		if strikeCDTimer.is_stopped():	
			if Input.is_action_just_pressed("pointer") && !strikeTimer.is_stopped():
				if strikePower <= 100:
					pass #some kind of penalty for too light
				elif strikePower > 100 && strikePower <= 400:
					hammerModel.visible = true
					hammerModel.translation = targetVoxel.global_transform.origin + Vector3.UP
					hammerAnimPlayer.play("HammerStrike")
					pass
				
			if Input.is_action_pressed("pointer") && strikeTimer.is_stopped(): # charge strike
				if strikePower < maxPower:
					strikePower += powerIncreaseRate * delta
					
					if strikePower > maxPower:
						strikePower = maxPower
						
			if Input.is_action_just_released("pointer"):
				strikeTimer.start()
			
		if Input.is_action_pressed("shift"):
			# for vox in voxelList:
			# 	vox.setHeat(200, delta)
			print(var2str(targetVoxel.translation))

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
				
	if forgeActive:
		for vox in voxelList:
			if vox != null && vox.global_transform.origin.distance_to(heatPoint.global_transform.origin) < 20:
				vox.setHeat(10 * (20 - vox.global_transform.origin.distance_to(heatPoint.global_transform.origin) / 20), delta)
				pass
		
func animStrike():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range(1, 4)
	
	var audio_file = "res://Sounds/anvilHit" + var2str(index) + ".wav"
	if File.new().file_exists(audio_file):
		var sfx = load(audio_file)
		# sfx.set_loop(false)
		audioPlayer.stream = sfx
		audioPlayer.play()
	
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
		
	if !removal && targetVoxel.heat >= targetVoxel.minForgeTemp:
		for pos in targetList:
			if pos != null: #&& remainingVoxels > 0:
				var vox = voxel.instance()
				voxelGrid.add_child(vox)
				vox.translation = pos
				vox.heat = targetVoxel.heat
				remainingVoxels -= 1
				voxelsCreated += 1
		
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
				voxelsCreated -= 1
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
						for n in outlineGrid.outlineList:
							if n.global_transform.origin == vox.global_transform.origin:
								voxelsCreated += 1
			2: 
				for x in range (-2, 4):
					for z in range(-1, 2):
						var vox = voxel.instance()
						voxelGrid.add_child(vox)
						vox.translation = Vector3(x, 0, z)
						for n in outlineGrid.outlineList:
							if n == vox.translation:
								voxelsCreated += 1
						
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
	
	if !forgeActive:
		voxelGrid.global_transform.origin = Vector3(0.5, 0.5, -0.5)
		voxelGrid.rotation = Vector3(0, 0, 0)
		print("moved to anvil")
	else:
		voxelGrid.global_transform.origin = Vector3(85, -8, 78)
		voxelGrid.rotation = Vector3(0, PI / 2, 0)
		print("moved to forge")

