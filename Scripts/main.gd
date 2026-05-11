extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SimpleGrass.set_interactive(true)
	
	# On attend une image pour être sûr que tous les objets sont chargés
	await get_tree().process_frame
	
	# On récupère tous les objets du groupe
	var objects = get_tree().get_nodes_in_group("object_grab")
	
	for obj in objects:
		if obj is RigidBody3D:
			# On lui attache le script audio dynamiquement
			obj.set_script(preload("res://Scripts/ObjectAudio.gd"))
			# On force l'appel de _ready() pour initialiser le son
			obj._ready()

	
#func _input(_event: InputEvent) -> void:
	#if Input.is_action_pressed("space"):
		#Engine.time_scale = 5.0
	#else:
		#Engine.time_scale = 1.0
