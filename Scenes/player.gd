extends CharacterBody2D

@export_category("Movement")
@export var soft_max_velocity: float = 300 ## Horizontal velocity at which accelleration will no longer apply.
@export var hard_max_velocity: float = 600 ## Horizontal velocity that player cannot exceed.
@export var acceleration: float = 50 ## Step at which velocity is increased each tick while accelerating.
@export var dampening = 20 ## Step at which velocity is decreased each tick when not accelerating.

@export_category("Sonar")
@export var growth_speed: float = .15 ## The speed at which the personal sonar grows
@export var fade_time: float = 1 ## The time it takes for the sonar to fully fade

# Misc Physics
var _tps_adjustment: float ## Physics adjustment to ensure forces are calculated correctly when physics ticks are inconsistant

# Sprites
var _vision_cone: Node2D
var _y_start: float
var _sonar_cone: Node2D
var _sonar_sprite: Sprite2D
var _current_alpha: float
var _start_alpha: float
var _sonar_active: bool
var _time_since_sonar: float

# Gameplay
var _checkpoint_pos: Vector2

func _ready() -> void:
    _vision_cone = $VisionCone
    _y_start = position.y
    
    _sonar_cone = $PersonalSonar
    _sonar_sprite = $PersonalSonar/Sprite2D
    _sonar_cone.scale = Vector2.ZERO
    _start_alpha = _sonar_sprite.self_modulate.a
    _current_alpha = _start_alpha
    
    _checkpoint_pos = position
    
func _process(delta: float) -> void:
    _process_vision()
    
    _process_sonar(delta)

func _physics_process(delta: float) -> void:
    _tps_adjustment = Engine.physics_ticks_per_second * delta
    
    _process_movement()
    
    move_and_slide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("kill"):
        kill()
    elif event.is_action_pressed("personal_sonar"):
        _sonar()

func _process_movement() -> void:
    var x_scalar = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
    var y_scalar = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
    var movement_direction = Vector2(x_scalar, y_scalar).normalized()
    if x_scalar != 0 and y_scalar != 0:
        movement_direction *= 1/sqrt(2) # WHYY does this work??
    velocity.x = _process_velocity_component(velocity.x, movement_direction.x)
    velocity.y = _process_velocity_component(velocity.y, movement_direction.y)

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
    var y_offset = position.y - _y_start
    var new_scale = -0.001 * y_offset + 1
    _vision_cone.scale = Vector2(new_scale, new_scale)

func _sonar() -> void:
    _sonar_active = true
    _time_since_sonar = 0
    _sonar_sprite.self_modulate.a = _start_alpha
    _sonar_cone.scale = Vector2.ZERO
    _sonar_cone.visible = true

func _process_sonar(delta: float) -> void:
    if _sonar_active:
        _time_since_sonar += delta
        _sonar_cone.scale += Vector2(growth_speed, growth_speed)
        var alpha = (1 - _time_since_sonar/fade_time) * _start_alpha
        if alpha < 0:
            alpha = 0
        _sonar_sprite.self_modulate.a = alpha
        if _time_since_sonar > fade_time:
            _sonar_cone.visible = false
            _sonar_active = false

func trigger_checkpoint() -> void:
    _checkpoint_pos = position

func kill() -> void:
    velocity = Vector2.ZERO
    position = _checkpoint_pos
