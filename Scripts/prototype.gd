extends Node3D

@onready var player: CharacterBody3D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.in_cinematique = false
	Ui.in_dialog = false
	Ui.in_menu_principal = false
	
	
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
			obj.add_to_group("interacteble")
