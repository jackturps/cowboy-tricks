extends Node3D

var animation_player : AnimationPlayer
@export var gun : Node3D
var hand_is_open : bool
var holding_gun : bool

var prev_pos : Vector2
var frame_velocity : Vector2
	

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
	pass
	## Mouse in viewport coordinates.
	#var is_left_click = event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT
	#if is_left_click:
		#if hand_is_open:
			#animation_player.play("Close Hand")
			#if position.distance_to(gun.position) <= 2:
				#holding_gun = true
				#gun.gun_state = gun.GunState.PIVOT
			#
		#else:
			#animation_player.play_backwards("Close Hand")
			#holding_gun = false
			#
			## Only set the gun velocity if we were actually holding it.
			#if gun.gun_state != gun.GunState.FREE:
				#gun.set_move_velocity(frame_velocity)
			#gun.gun_state = gun.GunState.FREE
			#
		#hand_is_open = !hand_is_open


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# TODO: Animation for just bottom fingers.
		if hand_is_open:
			animation_player.play("Close Hand")		
		hand_is_open = false
		
		# TODO: This could do with being cleaned up, I don't know why it needs to be in relation to the down vector.
		var angle_to_right = rad_to_deg(Vector2.DOWN.angle_to(Vector2.from_angle(gun.rotation.z)))
		if position.distance_to(gun.position) <= 2 && angle_to_right < 20:
			gun.gun_state = gun.GunState.HELD
	
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# TODO: Animation for just index finger.
		if hand_is_open:
			animation_player.play("Close Hand")		
		hand_is_open = false
		
		if position.distance_to(gun.position) <= 2:
			gun.gun_state = gun.GunState.PIVOT
		
	else:
		if !hand_is_open:
			animation_player.play_backwards("Close Hand")
		hand_is_open = true
		
		if gun.gun_state != gun.GunState.FREE:
			gun.set_move_velocity(frame_velocity)
		gun.gun_state = gun.GunState.FREE
	
	var curr_pos = Vector2(position.x, position.y)
	frame_velocity = curr_pos - prev_pos
	prev_pos = curr_pos
	
	var camera = get_viewport().get_camera_3d()
	
	var mouse_camera_pos = get_viewport().get_mouse_position()
	
	# Note: the z-depth here is relative to the position of the camera, we'll need to 
	# find the difference between camera and hand z.
	var mouse_pos = camera.project_position(mouse_camera_pos, camera.position.z)
	
	var mouse_dir = (mouse_pos - position)
	var move_velocity = mouse_dir * 0.4 * (delta * 30)
	position += move_velocity
	
	if gun.gun_state == gun.GunState.PIVOT || gun.gun_state == gun.GunState.HELD:
		gun.position = position
		
		# While we're holding the gun we need to apply our movement forces to enable spinning.
		const force_factor = 0.3
		var move_force = frame_velocity * force_factor
		gun.set_pivot_force(move_force)
