extends CharacterBody2D

@export var impulse_strength: float = 300
@export var impulse_frequency: float = 3
@export var dampening: float = 4
@export var monch_proximity: float = 200
@export var player: Node2D

var _tps_adjustment: float
var _time_since_impulse: float = 0
var _sprite: AnimatedSprite2D
var _is_swimming: bool = true
var _can_move: bool = true
var _time_since_killed: float = 0
var _original_pos: Vector2

func _ready() -> void:
    _sprite = $AnimatedSprite2D
    _original_pos = position
    _sprite.play()

func _process(delta: float) -> void:
    _process_player_proximity()

func _physics_process(delta: float) -> void:
    _tps_adjustment = Engine.physics_ticks_per_second * delta
       
    if _can_move: 
        _process_impulse(delta)
        
        _process_dampening()

        move_and_slide()
    else:
        _time_since_killed += delta
        if _time_since_killed > 3:
            position = _original_pos
            _time_since_killed = 0
            _can_move = true

func _process_dampening():
    var magnetude = velocity.length() - dampening
    if magnetude < 0: magnetude = 0
    velocity = velocity.normalized()*magnetude*_tps_adjustment
    
func _process_impulse(delta: float) -> void:
    _time_since_impulse += delta
    if _time_since_impulse > impulse_frequency:
        _random_impulse()
        _time_since_impulse = 0

func _random_impulse() -> void:
    var direction: Vector2 = Vector2(randf()*2-1, randf()*2-1).normalized()
    
    if direction.x < 0:
        _sprite.scale.x = abs(_sprite.scale.x)
    elif direction.x > 0:
        _sprite.scale.x = abs(_sprite.scale.x) * -1
    
    velocity = impulse_strength * direction

func _process_player_proximity() -> void:
    var distance_to_player = (global_position - player.global_position).length()
    if distance_to_player < monch_proximity and _is_swimming:
        _is_swimming = false
        _sprite.play("open_mouth")
    elif distance_to_player > monch_proximity and not _is_swimming:
        _is_swimming = true
        _sprite.play("default")


func _on_hit_detection_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        body.kill()
        _sprite.play("default")
        _can_move = false
    
