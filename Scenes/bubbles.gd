extends Node2D

@export var bubble_force: float = 70

var _area: Area2D
var _sprite: AnimatedSprite2D

var player: CharacterBody2D

# Misc physics
var _tps_adjustment: float

func _ready() -> void:
    _area = $Area2D
    _sprite = $Sprite
    _sprite.play()
    
func _physics_process(delta: float) -> void:
    _tps_adjustment = Engine.physics_ticks_per_second * delta

    if _area.get_overlapping_bodies().size() != 0:
        player = _area.get_overlapping_bodies()[0]
        player.velocity += (Vector2.RIGHT * bubble_force).rotated(rotation)
