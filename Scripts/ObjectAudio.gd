extends RigidBody3D

var audio_node : AudioStreamPlayer3D
var sound = preload("res://assets/audio/sfx/hurt.wav")

func _ready():
	# Configuration physique pour que le signal fonctionne
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_impact)

	# Création du lecteur audio
	audio_node = AudioStreamPlayer3D.new()
	audio_node.stream = sound
	# On règle la distance max pour ne pas entendre les chocs à l'autre bout du village
	audio_node.max_distance = 20.0 
	add_child(audio_node)

func _on_impact(_body):
	var speed = linear_velocity.length()
	
	if speed > 0.5:
		# Volume proportionnel à la vitesse
		audio_node.unit_size = clamp(speed * 2.0, 1.0, 15.0)
		
		# Variation de hauteur pour casser la répétitivité
		audio_node.pitch_scale = randf_range(0.5, 1.8 )
		audio_node.bus = "effect"
		audio_node.play()
