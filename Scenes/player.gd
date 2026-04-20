extends CharacterBody2D

@export_category("Movement")
@export var soft_max_velocity: float = 300 ## Horizontal velocity at which accelleration will no longer apply.
@export var hard_max_velocity: float = 600 ## Horizontal velocity that player cannot exceed.
@export var acceleration: float = 50 ## Step at which velocity is increased each tick while accelerating.
@export var dampening = 20 ## Step at which velocity is decreased each tick when not accelerating.

@export_category("Sonar")
@export var growth_speed: float = .15 ## The speed at which the personal sonar grows
@export var fade_time: float = 1 ## The time it takes for the sonar to fully fade
@export var max_alpha: float = 1 ## Alpha value of the darkness
@export var sonar_refresh_time: float = 4 ## Amount of time to reload a sonar
@export var sonar_cooldown: float = 1 ## Amount of time between sonar pings to prevent spamming
@export var ui: Node

@export_category("Death")
@export var death_time: float = 3 ## Time after dying before respawn
@export var light_shrink_speed = 0.05

# Misc Physics
var _tps_adjustment: float ## Physics adjustment to ensure forces are calculated correctly when physics ticks are inconsistant

# Sprites
var _vision_cone: Node2D
var _scale_start: float
var _y_start: float

# Sonar
var _sonar_cone: Node2D
var _sonar_sprite: Sprite2D
var _sonar_dark: Sprite2D
var _sonar_active: bool
var _time_since_sonar: float = 100
var _time_since_sonar_refresh: float = 0
var _MAX_SONARS: int = 4
var _num_sonars: int
var _sonar_sfx: AudioStreamPlayer

# Animation
var _player_sprite: AnimatedSprite2D
var _is_stopping: bool = false
var _facing_right: bool = true

# Dying
var _particles: GPUParticles2D
var _is_dying: bool = false
var _time_since_died: float = 0
var _can_move: bool = true
var _death_sfx: AudioStreamPlayer

# Gameplay
var _checkpoint_pos: Vector2

func _ready() -> void:
    _vision_cone = $VisionCone
    _scale_start = _vision_cone.scale.x
    _y_start = position.y
    
    _player_sprite = $AnimatedSprite2D
    _particles = $GPUParticles2D
    
    _player_sprite.play("swim")
    
    _sonar_cone = $PersonalSonar
    _sonar_sprite = $PersonalSonar/mask
    _sonar_dark = $PersonalSonar/dark
    _sonar_cone.scale = Vector2.ZERO
    _num_sonars = _MAX_SONARS
    _sonar_sfx = $SonarPing
    _death_sfx = $DeathBubbles
    
    _checkpoint_pos = position
    
func _process(delta: float) -> void:
    _process_respawn(delta)
    
    _process_vision()
    
    _process_sonar(delta)

func _physics_process(delta: float) -> void:
    _tps_adjustment = Engine.physics_ticks_per_second * delta
    
    if _can_move:
        _process_movement()
        move_and_slide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("personal_sonar") and _can_move:
        _sonar()

func _process_respawn(delta: float) -> void:
    if _is_dying:
        _time_since_died += delta
        if _time_since_died > death_time:
            # respawn player
            velocity = Vector2.ZERO
            position = _checkpoint_pos
            _is_dying = false
            _player_sprite.visible = true
            _can_move = true

func _process_movement() -> void:
    var x_scalar = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
    var y_scalar = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
    var movement_direction = Vector2(x_scalar, y_scalar).normalized()
    if x_scalar != 0 and y_scalar != 0:
        movement_direction *= 1/sqrt(2) # WHYY does this work??
    velocity.x = _process_velocity_component(velocity.x, movement_direction.x)
    velocity.y = _process_velocity_component(velocity.y, movement_direction.y)
    
    if x_scalar == 0 and y_scalar == 0 and _is_stopping == false and velocity.length() != 0:
        _player_sprite.play("stopping")
        _is_stopping = true
    elif _is_stopping and (velocity.length() == 0 or x_scalar != 0 or y_scalar != 0):
        _player_sprite.play("swim")
        _is_stopping = false
    
    if x_scalar > 0 and not _facing_right:
        _player_sprite.scale.x = abs(_player_sprite.scale.x)
        _facing_right = true
    elif x_scalar < 0 and _facing_right:
        _player_sprite.scale.x = abs(_player_sprite.scale.x) * -1
        _facing_right = false

func _process_velocity_component(velocity_component, scalar) -> float:
    var component = velocity_component
    var direction = component / abs(component)
    var scalar_direction = scalar / abs(scalar)
    
    # Stop acceleration past soft speed cap
    if scalar_direction == direction and abs(component) > soft_max_velocity:
        scalar = 0
    
    # If a movememnt key is pressed, apply acceleration
    if scalar != 0:
        component += scalar * acceleration * _tps_adjustment
    # Otherwise apply dampening
    elif component != 0:
        var current_vel = abs(component)
        current_vel -= dampening * _tps_adjustment
        if current_vel < 0:
            current_vel = 0
        component = current_vel * direction
    
    # Prevent velocity from exceeding max velocity
    if abs(component) > hard_max_velocity:
        component = hard_max_velocity * direction
    return component

func _process_vision() -> void:
    if _is_dying:
        var temp_scale = _vision_cone.scale.x
        temp_scale -= light_shrink_speed*0.01
        if temp_scale < 0: temp_scale = 0
        _vision_cone.scale = temp_scale * Vector2.ONE
    else:
        var y_offset = position.y - _y_start
        var new_scale = -0.000185 * y_offset + _scale_start
        _vision_cone.scale = Vector2(new_scale, new_scale)

func _sonar() -> void:
    if _time_since_sonar > sonar_cooldown and _num_sonars != 0:
        _num_sonars -= 1
        ui.set_sonars(_num_sonars)
        _sonar_active = true
        _time_since_sonar = 0
        _sonar_dark.self_modulate.a = 0
        _sonar_cone.scale = Vector2.ZERO
        _sonar_cone.visible = true
        _sonar_sfx.play()

func _process_sonar(delta: float) -> void:
    _time_since_sonar += delta
    if _sonar_active:
        _sonar_cone.scale += Vector2(growth_speed, growth_speed)
        var alpha = (_time_since_sonar/fade_time) * max_alpha
        _sonar_dark.self_modulate.a = alpha
        if _time_since_sonar > fade_time:
            _sonar_cone.visible = false
            _sonar_active = false
    if _num_sonars < _MAX_SONARS:
        _time_since_sonar_refresh += delta
        if _time_since_sonar_refresh > sonar_refresh_time:
            _time_since_sonar_refresh = 0
            _num_sonars += 1
            ui.set_sonars(_num_sonars)

func trigger_checkpoint() -> void:
    _checkpoint_pos = position

func kill() -> void:
    _player_sprite.visible = false
    _particles.emitting = true
    _death_sfx.play()
    _can_move = false
    _time_since_died = 0
    _is_dying = true
