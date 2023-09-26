extends Node2D

#Monitors the state of the game
enum GameState {Loading, Running, GameOver}
onready var current_state = GameState.Loading


var enemyObj =  preload("res://EnemeyRoot.tscn")
var Player = null
var cam = null

#Displays the "STAGE" text after every new level thge player reaches
#using the Label and animation properties
func _ready():
	
	var labelText = "Stage" + str(globals.currentStage)
	$Label.set_text(labelText)
	$AnimationPlayer.play("Stage Display")
	
#Called every frame. 'delta' is the elapsed time since the previous frame
#Displays the number of enemies killed by the player
func _process(delta):
	$HUD/Kills.set_text("Kills:"+ str(globals.numberOfKills))
#When the state changes to gameover and user tries to shoot then
#the scene should change to title scene
func _input(event):
	if(current_state==GameState.GameOver):
		if(event.is_action("PLAYER_SHOOT")):
			get_tree().change_scene("res://TitleScene.tscn")

#This handles all the animation and camera functionalities
func startAnimationDone():
	$Label.visible = true
	Player =preload("res://PlayerRoot.tscn").instance()
	Player.position = Vector2(20,20)
	cam = Camera2D.new()
	cam.position.x = 360
	cam.make_current()
	Player.add_child(cam)
	add_child(Player)
	_spawnEnemies()
	current_state = GameState.Running
	
func _on_Area2D_area_entered(area):
		#Checks if we hit the trigger to queue boss fight
		if(area.get_collision_layer_bit(4)):
			if(current_state==GameState.Running):
				Player.speed = 0
				globals.currentStage = globals.currentStage +1
				#get_tree().reload_current_scene()
				get_tree().change_scene("res://GameSceneRoot.tscn")
#Determines  what happens when the player dies 
func _playerDied():
	for i in Player.get_children():
		i.queue_free()
		remove_child(Player)
		current_state = GameState.GameOver
		
		$Label.set_text("Game Over")
		$Label.visible = true
		$Label.set_position(Vector2(1280/2-200,720/2))
		
#Creates an enemy at position (x,y) in the game world by creating an object 
#of the enemy class 
func _spawnEnemy(x,y):
	var enemy = enemyObj.instance()
	enemy.set_position(Vector2(x,y))
	add_child(enemy)

#We randomise the position of the enemy and the for each level we increase the
#number of enemies by 1 until the player dies or we reach the 
#end of the game world
func _spawnEnemies():
	randomize()
	#One extra plane per stage
	for i in range(0,10+globals.currentStage):
		_spawnEnemy(700+ randi()%5000,randi()%int(get_viewport_rect().size.y))

func _spawnBossWave():
	for i in range(0,10):
		_spawnEnemy(3800 + randi()%220, randi()%720)

func _ground_area_entered(area):
	if(current_state == GameState.Running):
		Player._explode()
