extends Node

# Signal pour prévenir les PNJ du changement de state
signal state_changed(new_state: int)

var states : int = 0 :
	set(value):
		states = value
		state_changed.emit(states) # On diffuse l'information
"""
	0 dois sortire de la maison
	1 dois trouver la clef et sortire puis allez dans la taverne
	2 il entre dans la taverne
	3 le joueur a parler a tout les pnj et a vue l'affiche de dispariton et gaga pare donc enquieter chez le sire
	4

"""

func _ready() -> void:
	state_changed.emit(states)

#variable pour savoir si on a bien parler a tout les pnj dans la taverne pour apres pouvoir regarder l'affiche
var inspecer_dialog1 : bool = false
var inspecer_dialog2 : bool = false
var inspecer_dialog3 : bool = false
var sire_dialog1 : bool = false
var sire_dialog2 : bool = false
var garde_dialog1 : bool = false
var garde_dialog2 : bool = false
var bierenard_dialog1 : bool = false
var jenny_dialog1 : bool = false
var lenny_dialog1 : bool = false

var all_dialog_finished = false
	
func _input(event: InputEvent) -> void:#CHEAT TEMPORAIRE A MODIFIER
	if Input.is_action_just_pressed("crouch"):
		all_dialog_finished = true	

func verifier_progression():#on verrifie si les dialog on bien ete tous faite
	if inspecer_dialog1 and inspecer_dialog2 and inspecer_dialog3 and sire_dialog1 and sire_dialog2 and bierenard_dialog1 and jenny_dialog1 and lenny_dialog1:
		all_dialog_finished = true
		print("all dialog in the taverne are finished")
