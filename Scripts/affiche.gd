extends StaticBody3D
@onready var crossair: TextureRect = get_tree().get_first_node_in_group("crossair")

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim_cinematique: AnimationPlayer = %AnimationPlayer

#OUTLINE DE L'AFFICHE
func you_are_collide():
	var mat = mesh.get_active_material(0).duplicate()
	mat.albedo_texture = preload("res://assets/textures/new affiche_outline.png")
	mesh.set_surface_override_material(0, mat)

func you_are_not_collide():
	var mat = mesh.get_active_material(0).duplicate()
	mat.albedo_texture = preload("res://assets/textures/new affiche.png")
	mesh.set_surface_override_material(0, mat)

#INTERACTION AVEC L'AFFICHE
var dejavue = false
func interact():
	if dejavue:
		Soutitre.show_thought("j'ai déjà vue cette affiche", 3)
		return
	if StoryStates.all_dialog_finished:
		dejavue = true
		anim_cinematique.play("affiche")
		if StoryStates.states == 2:
			StoryStates.states = 3
		CinematiqueCamera.day()
		%simple_door_sire.locked = false
	else:
		Soutitre.show_thought("humm... je devrais d'abord parler au villagois", 5)
