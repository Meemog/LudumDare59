extends Node2D

var _sprite: AnimatedSprite2D

func _ready() -> void:
    _sprite = $AnimatedSprite2D
    _sprite.play("default")

func make_happy() -> void:
    _sprite.play("happy")

func _on_area_2d_body_entered(body: Node2D) -> void:
    make_happy()
