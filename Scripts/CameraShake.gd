extends Spatial

onready var cam = get_parent()

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT
var amplitude = 0
var priority = 0

var origin = Vector3.ZERO

func start(duration, frequency, amplitude, priority):
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude
		
		$ShakeDuration.wait_time = duration
		$ShakeFreq.wait_time = 1 / float(frequency)
		$ShakeDuration.start()
		$ShakeFreq.start()

func screenShake():
	var rand = Vector3()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = 0 # global_transform.origin.y
	rand.z = rand_range(-amplitude, amplitude)
	
	$ShakeTween.interpolate_property(cam, "translation", cam.translation, origin + rand, $ShakeFreq.wait_time, TRANS, EASE)
	$ShakeTween.start()
	
func reset():
	$ShakeTween.interpolate_property(cam, "translation", cam.translation, origin, $ShakeFreq.wait_time, TRANS, EASE)
	$ShakeTween.start()
	
	priority = 0

func _on_ShakeFreq_timeout():
	screenShake()

func _on_ShakeDuration_timeout():
	reset()
	$ShakeFreq.stop()
