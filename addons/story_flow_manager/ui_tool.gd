@tool
extends Control

# Data for keyframe
var selected_state : int
var pnj_selectioner : Node
var position_pnj := Vector3.ZERO
var direction_pnj := Vector3.ZERO
var anim_selected : int
var dialog_selected : int
var dialog_title_selected : String = "start" # Stocke le nom du titre [cite: 1]

# Storage
var world_state : WorldState
var save_path : String
var plugin_reference : EditorPlugin

@onready var label_state: Label = %label_state
@onready var label_pnj_selected: RichTextLabel = %Label_pnj_selected
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func selected_node(node):    
	label_pnj_selected.bbcode_enabled = true

	pnj_selectioner = node
	
	var color_hex = "#ffdd00" 
	
	if not node.is_in_group("pnj"):
		color_hex = "#ff4d4d" 
		label_pnj_selected.text = "Selected (NON-PNJ) : [color=" + color_hex + "][b]" + node.name + "[/b][/color]"
	else:
		label_pnj_selected.text = "Pnj Selected : [color=" + color_hex + "][b]" + node.name + "[/b][/color]"
	
	# --- RÉCUPÉRATION DES ANIMATIONS ---
	var menu_anim = %menu_animation
	menu_anim.clear()
	var anim_player = node.find_child("AnimationPlayer", true, false)
	if anim_player:
		for anim_name in anim_player.get_animation_list():
			menu_anim.add_item(anim_name)
	
	# --- RÉCUPÉRATION DES DIALOGUES FILTRÉS ---
	var menu_dialog = %menu_dialog
	menu_dialog.clear()
	
	var logic_node = node.find_child("PNJ_BASE", true, false)
	if logic_node and "DIALOG_RESOURCES" in logic_node:
		var pnj_id = node.name
		if logic_node.DIALOG_RESOURCES.has(pnj_id):
			var resource = logic_node.DIALOG_RESOURCES[pnj_id]
			var titles = resource.titles.keys() 
			
			for title in titles:
				if title == "start" or title.begins_with("state_"):
					menu_dialog.add_item(title)
			
			if menu_dialog.get_item_count() == 0:
				menu_dialog.add_item("Aucun titre valide trouvé")
		else:
			menu_dialog.add_item("Pas de ressource .dialogue")

func _on_state_slider_value_changed(value: float) -> void:
	selected_state = int(value)
	label_state.text = "Selected State : " + str(selected_state)

func _on_apply_current_direction_pressed() -> void:
	if pnj_selectioner:
		direction_pnj = pnj_selectioner.rotation_degrees
		update_transforme_slider()

func _on_apply_current_position_pressed() -> void:
	if pnj_selectioner:
		position_pnj = pnj_selectioner.position
		update_transforme_slider()
	
func update_transforme_slider():
	%position_x.value = position_pnj.x
	%position_y.value = position_pnj.y
	%position_z.value = position_pnj.z
	%direction_x.value = direction_pnj.x
	%direction_y.value = direction_pnj.y
	%direction_z.value = direction_pnj.z

func _on_accepte_pressed() -> void:
	if not pnj_selectioner or not pnj_selectioner.is_in_group("pnj"):
		animation_player.play("not pnj")
		return
	
	update_var_transform()
	update_var_optionbutton()
	
	var new_state = PNJState.new()
	new_state.npc_id = pnj_selectioner.name
	new_state.position = position_pnj
	new_state.rotation = direction_pnj
	new_state.story_state = selected_state
	new_state.anim = anim_selected
	
	# ON SAUVEGARDE LE NOM DU TITRE ET NON L'INDEX [cite: 4]
	new_state.dialog_title = dialog_title_selected 
	
	if not world_state: return

	var index_doublon = -1
	for i in range(world_state.pnj_states.size()):
		var s = world_state.pnj_states[i]
		if s.npc_id == new_state.npc_id and s.story_state == new_state.story_state:
			index_doublon = i
			break
			
	if index_doublon != -1:
		world_state.pnj_states[index_doublon] = new_state
	else:
		world_state.pnj_states.append(new_state)
	
	ResourceSaver.save(world_state, save_path)
	animation_player.play("add keyframe")

func update_var_transform():
	position_pnj = Vector3(%position_x.value, %position_y.value, %position_z.value)
	direction_pnj = Vector3(%direction_x.value, %direction_y.value, %direction_z.value)

func update_var_optionbutton():
	anim_selected = %menu_animation.selected
	# On récupère le TEXTE sélectionné (ex: "state_3") [cite: 1]
	dialog_title_selected = %menu_dialog.get_item_text(%menu_dialog.selected)

func _on_timeline_slider_value_changed(value: float) -> void:
	%SpinBox_timeline.value = value
	if plugin_reference:
		plugin_reference.apply_world_state(int(value))
	
func _on_spin_box_timeline_value_changed(value: float) -> void:
	%timeline_slider.value = value
	if plugin_reference:
		plugin_reference.apply_world_state(int(value))
		
func _on_button_before_pressed() -> void:
	%timeline_slider.value -= 1
	
func _on_button_after_pressed() -> void:
	%timeline_slider.value += 1

func _on_button_delete_pressed() -> void:
	if not pnj_selectioner or not world_state: return
	var pnj_id = pnj_selectioner.name
	var target_state = selected_state
	var found = false

	for i in range(world_state.pnj_states.size()):
		var s = world_state.pnj_states[i]
		if s.npc_id == pnj_id and s.story_state == target_state:
			world_state.pnj_states.remove_at(i)
			found = true
			break
			
	if found:
		ResourceSaver.save(world_state, save_path)
		animation_player.play("del_keyframe") 

func _on_menu_animation_item_selected(index: int) -> void:
	anim_selected = index
	if pnj_selectioner and plugin_reference:
		var anim_player = pnj_selectioner.find_child("AnimationPlayer", true, false)
		if anim_player:
			var anim_name = anim_player.get_animation_list()[index]
			anim_player.assigned_animation = anim_name
			anim_player.seek(0, true)
			anim_player.advance(0)
