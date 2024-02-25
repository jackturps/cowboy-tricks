extends Node3D

var animation_player : AnimationPlayer
@export var gun : Node3D
var hand_is_open : bool
var holding_gun : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Probably needs to be in some global object.
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	animation_player = $AnimationPlayer
	animation_player.speed_scale = 10
	
	hand_is_open = true
	holding_gun = false
	
	# Get the list of animation names
	var animation_names = animation_player.get_animation_list()

	# Print the animation names
	print("Available Animations:")
	for animation_name in animation_names:
		print(animation_name)

func _input(event):
	# Mouse in viewport coordinates.
	var is_left_click = event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT
	if is_left_click:
		if hand_is_open:
			animation_player.play("Close Hand")
			if position.distance_to(gun.position) <= 1:
				holding_gun = true
		else:
			animation_player.play_backwards("Close Hand")
			holding_gun = false
		hand_is_open = !hand_is_open


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var camera = get_viewport().get_camera_3d()
	
	var mouse_camera_pos = get_viewport().get_mouse_position()
	
	# Note: the z-depth here is relative to the position of the camera, we'll need to 
	# find the difference between camera and hand z.
	var mouse_pos = camera.project_position(mouse_camera_pos, 5)
	
	var mouse_dir = (mouse_pos - position)
	var move_velocity = mouse_dir * 0.4 * (delta * 30)
	position += move_velocity
	
	if holding_gun:
		gun.position = position
