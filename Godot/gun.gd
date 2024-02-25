extends Node3D

var cog : Vector2
var pivot : Vector2

var cog_distance = 1.8
var spin_speed = 0

func update_cog():
	var cog_x_offset = cog_distance * sin(rotation.z)
	var cog_y_offset = cog_distance * cos(rotation.z)
	cog = Vector2(cog_x_offset, cog_y_offset)

# Called when the node enters the scene tree for the first time.
func _ready():
	# cog = center of gravity.
	pivot = Vector2(position.x, position.y)
	update_cog()
	
	print("z(", rad_to_deg(rotation.z), ") cog", cog)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	const grav_force = Vector2(0, -0.08)
	
	var grav_theta = grav_force.angle_to(cog)
	var swing_magnitude = grav_force.length() * sin(grav_theta)	
	var spin_theta = (2 * PI * swing_magnitude) / 1.8
	
	# TODO: Find a way to apply friction spin should eventually stop?
	spin_speed += spin_theta
	rotation.z += (spin_speed * delta)
	update_cog()
