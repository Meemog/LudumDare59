extends Sprite2D

@export var camera: Node2D

func _process(delta: float) -> void:
    position = camera.position
