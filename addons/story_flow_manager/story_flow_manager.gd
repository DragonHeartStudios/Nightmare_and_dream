@tool
extends EditorPlugin

var UI_TOOL
var world_state : WorldState
var save_path = "res://data/world_state.tres"

func _enter_tree() -> void:
	# Chargement de la ressource [cite: 3]
	if ResourceLoader.exists(save_path):
		world_state = load(save_path)
	else:
		world_state = WorldState.new()

	# Instance de l'UI [cite: 3]
	UI_TOOL = preload("res://addons/story_flow_manager/UI-tool.tscn").instantiate()
	UI_TOOL.world_state = world_state
	UI_TOOL.save_path = save_path
	UI_TOOL.plugin_reference = self # Permet à l'UI d'appeler ce script

	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, UI_TOOL)
	print("[StoryFlow] Plugin chargé.")

	# Connexion de la sélection [cite: 3]
	var selection = get_editor_interface().get_selection()
	selection.selection_changed.connect(_on_selection_changed)

# Dans story_flow_manager.gd

func apply_world_state(state_index: int) -> void:
	if not world_state: return
	
	var scene_root = get_tree().edited_scene_root
	if not scene_root: return

	for pnj_data in world_state.pnj_states:
		if pnj_data.story_state == state_index:
			var pnj_container = scene_root.find_child(pnj_data.npc_id, true, false)
			if pnj_container and pnj_container is Node3D:
				# 1. Position et Rotation
				pnj_container.position = pnj_data.position
				pnj_container.rotation_degrees = pnj_data.rotation
				
				# 2. Injection des données dans le script PNJ_BASE [cite: 9]
				var logic_node = pnj_container.find_child("PNJ_BASE", true, false)
				if logic_node:
					logic_node.current_anim_index = pnj_data.anim
					logic_node.current_dialog_title = pnj_data.dialog_title
				
				# 3. PRÉVISUALISATION DE L'ANIMATION DANS L'ÉDITEUR
				# On utilise le chemin que tu as confirmé : character/AnimationPlayer
				var anim_player = pnj_container.get_node_or_null("character/AnimationPlayer")
				if anim_player and anim_player is AnimationPlayer:
					var anim_list = anim_player.get_animation_list()
					if pnj_data.anim >= 0 and pnj_data.anim < anim_list.size():
						var anim_name = anim_list[pnj_data.anim]
						
						# Dans l'éditeur, on change l'animation actuelle
						anim_player.assigned_animation = anim_name
						# On force la mise à jour de la pose (frame 0)
						anim_player.seek(0, true) 
						# On s'assure que l'éditeur affiche le changement
						anim_player.advance(0)

func _on_selection_changed():
	var nodes = get_editor_interface().get_selection().get_selected_nodes()
	if not nodes.is_empty():
		UI_TOOL.selected_node(nodes[0])

func _exit_tree() -> void:
	remove_control_from_docks(UI_TOOL)
	if UI_TOOL: UI_TOOL.queue_free()
