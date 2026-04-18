extends CharacterBody2D

@export_category("Movement")
@export var soft_max_velocity: float = 300 ## Horizontal velocity at which accelleration will no longer apply.
@export var hard_max_velocity: float = 600 ## Horizontal velocity that player cannot exceed.
@export var acceleration: float = 50 ## Step at which velocity is increased each tick while accelerating.
@export var dampening = 20 ## Step at which velocity is decreased each tick when not accelerating.

# Misc Physics
var _tps_adjustment: float ## Physics adjustment to ensure forces are calculated correctly when physics ticks are inconsistant

# Sprites
var _vision_cone: Node2D
var _y_start: float

# Gameplay
var _checkpoint_pos: Vector2

func _ready() -> void:
    _vision_cone = $VisionCone
    _y_start = position.y
    _checkpoint_pos = position

func _process(delta: float) -> void:
    _process_vision()

func _physics_process(delta: float) -> void:
    _tps_adjustment = Engine.physics_ticks_per_second * delta
    
    _process_movement()
    
    move_and_slide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("kill"):
        kill()

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

func trigger_checkpoint() -> void:
    _checkpoint_pos = position

func kill() -> void:
    velocity = Vector2.ZERO
    position = _checkpoint_pos
