extends Node2D

var speed= 50
var verticalMovement = 0
var MAX_VERTICAL_MOVEMENT = 200
var bulletObj = null
const RATE_OF_FIRE = 3.0
var dying = false

onready var shootCooldown = $Timer
onready var explode = preload("res://ExplosionRoot.tscn").instance()

#Handles user inputs and the player movement
func _userInput():
	
	if Input.is_action_just_pressed("PLAYER_UP"):
		if(verticalMovement >= -MAX_VERTICAL_MOVEMENT):
			verticalMovement-=150
	if Input.is_action_just_pressed("PLAYER_DOWN"):
		if(verticalMovement <= MAX_VERTICAL_MOVEMENT):
			verticalMovement+=150
	"""
	This creates the bullet at the same location as the player.
	After the bullet is created it is added to the current scene 
	"""
	if Input.is_action_just_pressed("PLAYER_SHOOT"):
		if(shootCooldown.time_left==0):
			var bullet = bulletObj.instance()
			bullet.position = self.get_position()
			bullet.position.y = bullet.position.y +20
			get_node("/root/GameSceneRoot").add_child(bullet)
			shootCooldown.start()
			
			
func _process(delta):
	_userInput()
	move_local_x(speed*delta)

	if(self.position.y>1 && self.position.y<=get_viewport_rect().size.y):
		move_local_y(verticalMovement*delta)
	else:
		if(self.position.y < 1): 
			move_local_y(10) #Bounce off top
			verticalMovement = 0
	if(self.position.y > get_viewport_rect().size.y):
		move_local_y(-10) #Bounce off bottom
		verticalMovement = 0
	if dying==true:
		if shootCooldown.time_left==0:
			get_node("/root/GameSceneRoot")._playerDied()
			queue_free()
			print("DEAD")
	

#Creates a bullet object by using the path
#
func _ready():
	bulletObj = preload("res://BulletRoot.tscn")
	shootCooldown.wait_time = 1.0/RATE_OF_FIRE
	shootCooldown.one_shot = true

func stop():
	speed = 0

func _explode():
	explode = set_position(self.get_position())
	get_parent().add_child(explode)
	globals.numberOfKills = globals.numberOfKills+1
	shootCooldown.wait_time = 2.5
	shootCooldown.start() 
	$PlayerSprite.visible = false
	dying = true
		
func dead():
	get_node("/root/GameSceneRoot").PlayerDied()
	
func _on_Area2D_area_entered(area):
	if(area.get_collision_layer_bit(2)):
		_explode()
