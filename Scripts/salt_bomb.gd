extends Area3D
class_name SaltBomb

@onready var explosion_area: Area3D = $ExplosionArea

@export var damage: int = 1
@export var knockback_force: float = 20.0
@export var bomb_gravity: float = 0.6
@export var throw_speed: float = 20.0
@export var explosion_delay: float = 0.5

var velocity: Vector3 = Vector3.ZERO
var landed := false
var exploding := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_target(target_position: Vector3) -> void:
	var direction = target_position - global_position

	if direction.length() > 0.1:
		direction = direction.normalized()

	velocity = direction * throw_speed


func _physics_process(delta: float) -> void:
	if landed or exploding:
		return

	velocity.y -= bomb_gravity * delta
	global_position += velocity * delta


func _on_body_entered(body: Node3D) -> void:
	if landed:
		return

	if body.is_in_group("enemy"):
		return

	land()


func land() -> void:
	if landed:
		return

	landed = true
	velocity = Vector3.ZERO

	print("SALT BOMB LANDED")

	if not is_inside_tree():
		return

	await get_tree().create_timer(explosion_delay).timeout

	if not is_inside_tree():
		return

	explode()


func explode() -> void:
	if exploding:
		return

	exploding = true

	print("SALT BOMB EXPLOSION")

	explosion_area.monitoring = true

	await get_tree().process_frame

	if not is_inside_tree():
		return

	for body in explosion_area.get_overlapping_bodies():

		if body.is_in_group("player"):

			body.take_damage(damage)

			var direction = body.global_position - global_position
			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()

			body.velocity.x = direction.x * knockback_force
			body.velocity.z = direction.z * knockback_force
			body.velocity.y = 6.0

			print("PLAYER HIT BY SALT BOMB")

	explosion_area.monitoring = false

	if not is_inside_tree():
		return

	await get_tree().create_timer(0.1).timeout

	if is_inside_tree():
		queue_free()
