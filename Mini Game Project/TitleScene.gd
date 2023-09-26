extends Control


func _ready():
	
	globals.currentStage = 0
	globals.numberOfKills = 0
	
	

#Changes to the main game scene and starts the game
func _on_NewGame_pressed():
	get_tree().change_scene("res://GameSceneRoot.tscn")

#Exits the game
func _on_QuitGame_pressed():
	get_tree().quit()
