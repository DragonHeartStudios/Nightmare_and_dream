extends StaticBody3D

@export var nom: String = "basename"
@export var value: Color
@export var world_state_path : String = "res://data/world_state.tres"

var world_state : WorldState
var look_object 
@onready var label_pnj: Label3D = %Label_pnj
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
var in_dialog := false

@export var current_anim_index : int = 0
@export var current_dialog_title : String = ""

# Ton chemin exact d'AnimationPlayer
@onready var anim_player : AnimationPlayer = $"../character/AnimationPlayer"

const DIALOG_RESOURCES = {
	"sire": preload("uid://bfod64dtuoyw5"),
	"inspecter_gaga": preload("uid://cy3iu2xvhdnjl"),
	"agnes": preload("uid://cv14t4tbnlehs"),
	"Alphonse": preload("uid://du6qegsvxlxvx"),
	"Bière-nard_Bush": preload("uid://bdc3lyev8cf1w"),
	"garde_dechild": preload("uid://c6m6545hwsj7g"),
	"Jénny": preload("uid://bxr6a8jsoy6c7"),
	"Lenny": preload("uid://c7w01ncxdhlbw")
}

func _ready():
	if ResourceLoader.exists(world_state_path):
		world_state = load(world_state_path)
	
	# Connexion au signal du Singleton [cite: 10, 14]
	StoryStates.state_changed.connect(_on_story_state_changed)
	
	DialogueManager.dialogue_ended.connect(_on_dialog_ended)
	add_to_group("interacteble")
	label_pnj.text = nom
	label_pnj.set_modulate(value)
	look_object = get_tree().get_first_node_in_group("head_player")
	
	# Forcer la mise à jour initiale au chargement [cite: 11]
	_update_visual_state(StoryStates.states)

func _on_story_state_changed(new_state: int):
	_update_visual_state(new_state)

func _update_visual_state(target_state: int):
	if not world_state: return
	
	var pnj_id = get_parent().name 
	
	for data in world_state.pnj_states:
		if data.npc_id == pnj_id and data.story_state == target_state:
			# Téléportation du parent [cite: 11]
			get_parent().global_position = data.position
			get_parent().global_rotation_degrees = data.rotation
			
			# Mise à jour des index [cite: 11]
			current_anim_index = data.anim
			current_dialog_title = data.dialog_title
			
			# Jouer l'animation correspondante
			_play_current_anim()
			
			print("[PNJ] %s mis à jour (State %d)" % [pnj_id, target_state])
			break
			
func _play_current_anim():
	if not anim_player:
		print("PAS D ANIMPLYER TROUVER")
		return
	
	var anim_list = anim_player.get_animation_list() 
	
	if current_anim_index >= 0 and current_anim_index < anim_list.size():
		var anim_name = anim_list[current_anim_index] 
		anim_player.play(anim_name) 
		print("[PNJ] %s joue l'anim : %s" % [nom, anim_name])
	else:
		print("[PNJ] Erreur : Index d'anim %d invalide" % current_anim_index) 

# Dans pnj_base.gd

func interact():
	if in_dialog: return
	
	var pnj_key = get_parent().name
	if not DIALOG_RESOURCES.has(pnj_key): 
		print("[PNJ] Erreur : Pas de ressource de dialogue pour ", pnj_key)
		return
	
	var resource = DIALOG_RESOURCES[pnj_key]
	
	# --- CHOIX DU DIALOGUE ---
	# On utilise directement le titre sauvegardé par l'outil (ex: "state_3") 
	var title_to_play = current_dialog_title
	
	# Sécurité : Si pour une raison X le titre n'existe plus dans le fichier .dialogue
	if not resource.titles.has(title_to_play):
		print("[PNJ] Titre ", title_to_play, " non trouvé. Repli sur 'start'.")
		title_to_play = "start"
	
	print("[StoryFlow] Lancement du dialogue : ", title_to_play)

	# --- LANCEMENT ---
	audio.play()
	Ui.in_dialog = true
	Ui.menu_visible()
	Ui.in_cinematique = true
	in_dialog = true
	
	# Affiche le dialogue avec le titre correct 
	DialogueManager.show_dialogue_balloon(resource, title_to_play)
	
	# Lance l'animation et configure la caméra [cite: 9, 10]
	_play_current_anim()
	CinematiqueCamera.pnj_talking_pos = %neck.global_position
	CinematiqueCamera.couleur_du_pnj = value

func _on_dialog_ended(_resource):
	Ui.in_dialog = false
	Ui.menu_visible()
	Ui.in_cinematique = false
	in_dialog = false

# --- Logique de regard ---
@onready var skeleton = $"../character/Skeleton3D"
var bonesmoothrot = 0.0
func look_at_object(delta):
	if get_tree().paused or not look_object: return 
	if global_position.distance_to(look_object.global_position) < 3:
		var neck_bone = skeleton.find_bone("Neck")
		%neck.look_at(look_object.global_position, Vector3.UP ,true)
		var marker_rot = %neck.rotation_degrees
		marker_rot.x = clamp(marker_rot.x, -20, 20)
		marker_rot.y = clamp(marker_rot.y, -90, 90)
		bonesmoothrot = lerp_angle(bonesmoothrot, deg_to_rad(marker_rot.y), 2 * delta)
		var new_rot = Quaternion.from_euler(Vector3(deg_to_rad(marker_rot.x), bonesmoothrot, 0))
		skeleton.set_bone_pose_rotation(neck_bone, new_rot)
	else:
		var neck_bone = skeleton.find_bone("Neck")
		bonesmoothrot = lerp_angle(bonesmoothrot, 0.0, 5 * delta)
		var reset_rot = Quaternion.from_euler(Vector3(0.0, bonesmoothrot, 0))
		skeleton.set_bone_pose_rotation(neck_bone, reset_rot)

func _process(delta: float) -> void:
	look_at_object(delta) 
