extends Node3D

@onready var player: CharacterBody3D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.in_cinematique = false
	Ui.in_dialog = false
	Ui.in_menu_principal = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
