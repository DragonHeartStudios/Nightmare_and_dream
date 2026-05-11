extends Node3D

@onready var raycast = %InteractionRaycast
@onready var hold_pos = %HoldPos

@export var sfx_pickup : AudioStreamPlayer3D
@export var sfx_release : AudioStreamPlayer3D

@export var ik : TwoBoneIK3D
@export var speed_ik : float = 0.2

@onready var look_at_modifier_3d: LookAtModifier3D = %LookAtModifier3D


var picked_object: RigidBody3D = null

func _ready() -> void:
	ik.influence = 0.0
	look_at_modifier_3d.active = false

func _input(event):
	if event.is_action_pressed("interact"):
		if picked_object: release_object()
		else: attempt_pickup()

func attempt_pickup():
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target is RigidBody3D and target.is_in_group("object_grab"):
			picked_object = target
			picked_object.gravity_scale = 0
			picked_object.linear_damp = 10
			picked_object.angular_damp = 10
			sfx_pickup.play()
			
			look_at_modifier_3d.active = true
			
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(ik, "influence", 1.0, speed_ik)


func release_object():
	if picked_object:
		picked_object.gravity_scale = 1
		picked_object.linear_damp = 0
		picked_object.angular_damp = 0
		picked_object = null
		sfx_release.play()
		
		look_at_modifier_3d.active = false
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ik, "influence", 0.0, speed_ik)

func _physics_process(_delta):
	if picked_object:
		var target_pos = hold_pos.global_transform.origin
		var current_pos = picked_object.global_transform.origin
		var direction = target_pos - current_pos
		picked_object.linear_velocity = direction * 20.0
		
		# Rotation
		var target_rotation = hold_pos.global_transform.basis.get_rotation_quaternion()
		var current_rotation = picked_object.global_transform.basis.get_rotation_quaternion()
		var rotation_difference = target_rotation * current_rotation.inverse()
		
		var axis = rotation_difference.get_axis()
		var angle = rotation_difference.get_angle()
		if angle > PI: angle -= 2.0 * PI
		elif angle < -PI: angle += 2.0 * PI

		picked_object.angular_velocity = axis * angle * 15.0
		
		if direction.length() > 2.0: release_object()
