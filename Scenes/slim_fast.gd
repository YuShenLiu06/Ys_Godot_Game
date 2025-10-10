extends Area2D

@export var slime_speed : float = -200
@export var exp : int = 3
@export var Health : int = 2
@export var bullet_damage : int = 1

var is_dead : bool = false

func _ready() -> void:
	
	SignalBus.Get_bullet_damage.connect(On_change_damage)
		
	await get_tree().create_timer(15).timeout
	queue_free()

func On_change_damage(New_damage):
	bullet_damage=New_damage

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	position += Vector2(slime_speed,0) * delta #delta意味着每个帧花费了多少秒 这句话意味着在1s移动100个像素点


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && !is_dead:
		body.Gameover()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bullet") && !is_dead:
		Health-=bullet_damage
	if Health<=0:
		$AnimatedSprite2D.play("Death")
		is_dead = true
		area.queue_free()
		get_tree().current_scene.Score += 1
		get_tree().current_scene.Exp += exp
		$Death_Sound.play()
		await  get_tree().create_timer(0.6).timeout
		queue_free()
		
