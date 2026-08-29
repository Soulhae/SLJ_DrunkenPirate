extends MeshInstance3D

const MAX_RIPPLES := 32

var ripple_positions: Array[Vector2] = []
var ripple_times: Array[float] = []


func _ready():
	for i in MAX_RIPPLES:
		ripple_positions.append(Vector2.ZERO)
		ripple_times.append(0.0)

	update_shader()


func _process(delta):
	var changed := false

	for i in MAX_RIPPLES:
		if ripple_times[i] > 0.0:
			ripple_times[i] += delta
			changed = true

			if ripple_times[i] > 5.0:
				ripple_times[i] = 0.0

	if changed:
		update_shader()


func create_ripple(position: Vector3):
	var slot := find_free_ripple()

	ripple_positions[slot] = Vector2(
		position.x,
		position.z
	)

	ripple_times[slot] = 0.001

	update_shader()


func find_free_ripple() -> int:
	for i in MAX_RIPPLES:
		if ripple_times[i] <= 0.0:
			return i

	# If all slots are occupied,
	# reuse the oldest one.
	var oldest := 0

	for i in MAX_RIPPLES:
		if ripple_times[i] > ripple_times[oldest]:
			oldest = i

	return oldest


func update_shader():
	var shader_material := get_active_material(0) as ShaderMaterial

	if shader_material == null:
		push_error("Water: No ShaderMaterial found on the water MeshInstance3D.")
		return

	shader_material.set_shader_parameter(
		"ripple_positions",
		PackedVector2Array(ripple_positions)
	)

	shader_material.set_shader_parameter(
		"ripple_times",
		PackedFloat32Array(ripple_times)
	)
