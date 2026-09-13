class_name PlayerAttack
extends State

@onready var player: CharacterBody3D = get_owner()
@onready var anim_player: AnimationPlayer = $"../../player/AnimationPlayer"

@onready var attack_hitbox: Area3D = player.get_node("AttackHitbox")
@onready var damage_dealt_label: Label = player.get_node("../UI/DamageDealtLabel")
@onready var hit: AudioStreamPlayer = $"../../attck"

@onready var effect_hit = $"../../HitEffect"
@onready var hurt = $"../../Hurt"
@onready var swing: AudioStreamPlayer = $"../../swing"


# ================================================================
# DAMAGE
# ================================================================

@export var attack_damage_1: int = 10
@export var attack_damage_2: int = 15
@export var attack_damage_3: int = 20


# ================================================================
# HIT TIMING
# ================================================================

@export var hit_time_1: float = 0.25
@export var hit_time_2: float = 0.25
@export var hit_time_3: float = 1.30


# ================================================================
# COMBO VARIABLES
# ================================================================

var combo_step: int = 1
var can_chain: bool = false
var attack_has_hit: bool = false
var attack_id: int = 0


# ================================================================
# ENTER
# ================================================================

func enter():

	combo_step = 1
	can_chain = false
	attack_has_hit = false

	# Stop movement
	player.velocity.x = 0
	player.velocity.z = 0

	# Play first attack
	anim_player.play("combo_001")

	# Swing sound
	play_swing_sound()

	# Start hit timer
	attack_id += 1

	start_attack_hit_timer(
		attack_id
	)


# ================================================================
# PHYSICS
# ================================================================

func physics_process(delta: float):

	# ============================================================
	# AIR
	# ============================================================

	if not player.is_on_floor():

		player.velocity += player.get_gravity() * delta

		Transitioned.emit(
			self,
			"PlayerAir"
		)

		return


	# ============================================================
	# STOP PLAYER MOVEMENT
	# ============================================================

	player.velocity.x = 0
	player.velocity.z = 0

	player.update_visuals_rotation(
		Vector3.ZERO,
		delta
	)

	player.move_and_slide()


	# ============================================================
	# CONTINUE COMBO
	# ============================================================

	if Input.is_action_just_pressed("attack") and can_chain:

		can_chain = false

		combo_step += 1

		attack_has_hit = false

		attack_id += 1


		# ========================================================
		# COMBO 2
		# ========================================================

		if combo_step == 2:

			anim_player.play(
				"combo_002"
			)

			play_swing_sound()

			start_attack_hit_timer(
				attack_id
			)


		# ========================================================
		# COMBO 3
		# ========================================================

		elif combo_step == 3:

			anim_player.play(
				"combo_003"
			)

			play_swing_sound()

			start_attack_hit_timer(
				attack_id
			)


# ================================================================
# ATTACK HIT TIMER
# ================================================================

func start_attack_hit_timer(
	my_attack_id: int
):

	var current_step = combo_step
	var wait_time: float = 0.25


	match current_step:

		1:
			wait_time = hit_time_1

		2:
			wait_time = hit_time_2

		3:
			wait_time = hit_time_3


	await get_tree().create_timer(
		wait_time
	).timeout


	# Make sure this is still the current attack
	if my_attack_id != attack_id:
		return

	# Make sure this state is still active
	if not is_inside_tree():
		return

	attack_hit()


# ================================================================
# ATTACK HIT
# ================================================================

func attack_hit():

	if attack_has_hit:
		return

	attack_has_hit = true

	deal_attack_damage()


# ================================================================
# READY
# ================================================================

func _ready():

	anim_player.animation_finished.connect(
		_on_animation_finished
	)


# ================================================================
# ANIMATION FINISHED
# ================================================================

func _on_animation_finished(
	animation_name: StringName
):

	# ============================================================
	# COMBO 1
	# ============================================================

	if animation_name == "combo_001":

		can_chain = true

		# Give player time to decide
		await get_tree().create_timer(
			0.35
		).timeout

		# Player didn't continue
		if combo_step == 1 and can_chain:

			can_chain = false

			Transitioned.emit(
				self,
				"PlayerIdle"
			)


	# ============================================================
	# COMBO 2
	# ============================================================

	elif animation_name == "combo_002":

		can_chain = true

		# Give player time to decide
		await get_tree().create_timer(
			0.35
		).timeout

		# Player didn't continue
		if combo_step == 2 and can_chain:

			can_chain = false

			Transitioned.emit(
				self,
				"PlayerIdle"
			)


	# ============================================================
	# COMBO 3
	# ============================================================

	elif animation_name == "combo_003":

		can_chain = false

		Transitioned.emit(
			self,
			"PlayerIdle"
		)


# ================================================================
# DEAL ATTACK DAMAGE
# ================================================================

func deal_attack_damage():

	var damage := 0


	# ============================================================
	# DAMAGE BASED ON COMBO
	# ============================================================

	match combo_step:

		1:
			damage = attack_damage_1

		2:
			damage = attack_damage_2

		3:
			damage = attack_damage_3


	# ============================================================
	# CHECK HITBOX
	# ============================================================

	for body in attack_hitbox.get_overlapping_bodies():

		if not is_instance_valid(body):
			continue

		if not body.is_in_group("enemy"):
			continue

		if not body.has_method("take_damage"):
			continue


		# ========================================================
		# DEAL DAMAGE
		# ========================================================

		body.take_damage(
			damage
		)


		if not is_instance_valid(body):
			continue


		# ========================================================
		# HIT EFFECT
		# ========================================================

		effect_hit.global_position = (
			body.global_position
		)

		effect_hit.restart()


		# ========================================================
		# COMBO 3 STAGGER
		# ========================================================

		if (
			combo_step == 3
			and body.has_method("stagger")
		):

			body.stagger()


		# ========================================================
		# HIT STOP
		# ========================================================

		if combo_step == 3:

			player.hit_stop(
				0.10
			)

		else:

			player.hit_stop(
				0.07
			)


		# ========================================================
		# CAMERA SHAKE
		# ========================================================

		match combo_step:

			1:

				player.shake_camera(
					0.035,
					0.06
				)

			2:

				player.shake_camera(
					0.045,
					0.07
				)

			3:

				player.shake_camera(
					0.08,
					0.12
				)


		# ========================================================
		# HIT SOUND
		# ========================================================

		play_hit_sound()


		# ========================================================
		# DAMAGE LABEL
		# ========================================================

		damage_dealt_label.text = str(
			damage
		)

		damage_dealt_label.visible = true


		print(
			"PLAYER HIT: ",
			body.name,
			" DAMAGE: ",
			damage
		)


		await get_tree().create_timer(
			0.5
		).timeout


		if is_instance_valid(
			damage_dealt_label
		):

			damage_dealt_label.visible = false
			
func play_swing_sound():
	swing.play()
	await get_tree().create_timer(0.5).timeout
	
	if is_instance_valid(swing):
		swing.stop()

func play_hurt_sound():
	hurt.play()
	await get_tree().create_timer(0.69).timeout
	
	if is_instance_valid(hurt):
		hurt.stop()

func play_hit_sound():
	hit.play()
	await get_tree().create_timer(0.74).timeout
	
	if is_instance_valid(hit):
		hit.stop()
