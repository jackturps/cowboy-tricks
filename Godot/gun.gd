extends Node3D

enum GunState { HELD, PIVOT, FREE }

var cog : Vector2
# var pivot : Vector2
var cog_distance = 1.8
var spin_speed = 0

var gun_state = GunState.FREE
var move_force = Vector2(0, 0)
var move_velocity = Vector2(0, 0)


func update_cog():
	var cog_x_offset = cog_distance * sin(rotation.z)
	var cog_y_offset = cog_distance * cos(rotation.z)
	cog = Vector2(cog_x_offset, cog_y_offset)


func rotate_around_cog(theta):
	var curr_pos = Vector2(position.x, position.y)
	var temp_origin = curr_pos - (curr_pos - cog)
	var rotated_vector = temp_origin.rotated(theta) + (curr_pos - cog)
	rotation.z += theta
	position = Vector3(rotated_vector.x, rotated_vector.y, position.z)
	

func set_move_velocity(new_move_velocity : Vector2):
	move_velocity = new_move_velocity


# Used to apply forces while pivoting so gun can spin from hand movement.
func set_pivot_force(new_move_force : Vector2):
	move_force = new_move_force


# Called when the node enters the scene tree for the first time.
func _ready():
	# cog: Center of Gravity.
	update_cog()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	const spin_friction = 0.995
	
	# TODO: When we go from FREE to PIVOT we want to transfer the movement into some kind of spin force,
	# at the minute you catch it and all of that speed dies.
	if gun_state == GunState.PIVOT:
		const grav_spin_force = Vector2(0, -0.08)
		
		# We invert the move force because equal and opposite reaction BITCH.
		var total_force = -move_force + grav_spin_force
		
		# Vector cog points from our pivot to our center of gravity.
		# Total force points in the direction of all the forces we are subject to(gravity, hand). 
		# We find the angle between these two vectors and use that to find the force being applied 
		# in the direction we can actually swing in. We use that swing force to calculate how 
		# much to accelerate around the pivot.
		var force_theta = total_force.angle_to(cog)
		var swing_magnitude = total_force.length() * sin(force_theta)
		var spin_theta = (2 * PI * swing_magnitude) / 1.8
		
		# TODO: Apply delta to friction? Apply delta to speed?	
		spin_speed += spin_theta
		spin_speed *= spin_friction
		rotation.z += (spin_speed * delta)
		
		
	elif gun_state == GunState.HELD:
		rotation.z = deg_to_rad(90)
		spin_speed = 0
	
	else:
		# Separate gravity for movement is useful for tuning game feel.
		const grav_move_force = Vector2(0, -0.015)
		
		# Don't really need friction for the y-axis.
		const move_friction = Vector2(0.98, 1)
		const reflect_friction = Vector2(1, 0.7)
		
		move_velocity += (grav_move_force)
		move_velocity *= move_friction
		
		position.x += (move_velocity.x)
		position.y += (move_velocity.y)
		
		# TODO: More robust boundary checking.		
		if position.y < -10:
			position.y = -10
			move_velocity = move_velocity.reflect(Vector2.RIGHT)
			move_velocity *= reflect_friction
		
		spin_speed *= spin_friction
		rotate_around_cog(spin_speed * delta)
	
	# Always keep the COG up to date.
	update_cog()
