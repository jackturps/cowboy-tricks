extends Node3D

@export var gun : Node3D

var start_angle = 0
var curr_angle = 0

var curr_spin_dir = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_angle = gun.rotation.z
	curr_angle = start_angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO: Differentiate between finger spins and proper flips. Should only set the flip target when released.
	
	# Every time we change directions we reset the rotation start point.
	var prev_spin_dir = curr_spin_dir
	curr_spin_dir = sign(gun.spin_speed)
	if prev_spin_dir != curr_spin_dir:
		start_angle = gun.rotation.z
	
	var prevAngle = curr_angle
	curr_angle = gun.rotation.z
	
	#print(start_angle, " vs ", prevAngle, " vs ", curr_angle)	
	var target_angle = start_angle + 2 * PI * curr_spin_dir
	if curr_spin_dir == 1 && prevAngle < target_angle && curr_angle > target_angle:
		print("FRONT FLIP!")
		start_angle = target_angle
	elif curr_spin_dir == -1 && prevAngle > target_angle && curr_angle < target_angle:
		print("BACK FLIP!")
		start_angle = target_angle
