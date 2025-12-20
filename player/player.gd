extends CharacterBody2D
@export var gravity = 600
@export var run_speed = 150
@export var jump_speed = -350
@export var double_jump_factor = 1
@export var climb_speed = 50
@export var dash_speed = 500
@export var dash_time = 0.2
@export var dash_cooldown = 0.5
var spawn_point
var dash_timer: Timer
var is_on_ladder = false
var invincible = false
var can_dash = true
var is_dashing = false
signal life_changed
signal died
var life = 3: set = set_life
enum {IDLE, RUN, JUMP, HURT, DEAD, CLIMB, DASH}
var state = IDLE

func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(DEAD)

func _ready():
	spawn_point = position
	change_state(IDLE)
	dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_finished)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.stop()
			run_speed = 150
		RUN:
			$AnimationPlayer.play("run")
			run_speed = 150
		HURT:
			velocity.y = -200
			velocity.x = -300 * sign(velocity.x)
			life -= 1
			if life <= 0:
				get_tree().quit()
				return;
			await get_tree().create_timer(0.75).timeout
			change_state(IDLE)
		JUMP:
			run_speed = 150
		DASH:
			is_dashing = true
			dash_timer.start(dash_time)
			
		DEAD:
			died.emit()
			hide()
			
func get_input(delta: float):
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_pressed("jump")
	var dash = Input.is_action_just_pressed("dash")
	velocity.x = 0
	if state == HURT:
		run_speed = 50
	if right and not state == DASH:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left and not state == DASH:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	if dash and $dashCd.is_stopped():
		change_state(DASH)
		$DashSound.play()
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)

func _physics_process(delta: float) -> void:
	if abs(position.y) > 1000:
		respawn()
	var input_dir = Vector2.RIGHT if $Sprite2D.flip_h == false else Vector2.LEFT
	velocity.y += gravity * delta
	get_input(delta)
	move_and_slide()
	if state == HURT:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("enemies"):
			if is_dashing:
				collision.get_collider().take_damage()
				$enemyDeathSound.play()
			else:
				hurt()
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	if state == DASH and dash_timer.time_left > 0:
		gravity = 0
		is_dashing = true
		velocity = input_dir * dash_speed
		move_and_slide()
	if state != CLIMB:
		velocity.y += gravity * delta

func reset(_position):
	position = _position
	show()
	change_state(IDLE)
	life = 3
	
func respawn():
	position = spawn_point
	show()
	change_state(IDLE)
	hurt()

func hurt():
	if state != HURT and !invincible:
		change_state(HURT)

func _on_dash_finished():
	is_dashing = false
	gravity = 600
	change_state(IDLE)
	$dashCd.start()
