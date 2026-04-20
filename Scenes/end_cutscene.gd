extends Node2D

@export var delay: float = 0.5
@export var fadein_time = 2

var _rocky_sprite: AnimatedSprite2D
var _splash_sprite: AnimatedSprite2D

var _time_since_fadein: float = 0
var _faded_in: bool = false
var _fadein_sprite: Sprite2D

func _ready() -> void:
    _rocky_sprite = $characters/Rocky
    _splash_sprite = $characters/Splash
    _fadein_sprite = $fadein
    
    _rocky_sprite.play("happy")
    _splash_sprite.play()

func _process(delta: float) -> void:
    _process_fadein(delta)

func _on_texture_button_pressed() -> void:
    get_tree().quit()

func _process_fadein(delta: float) -> void:
    _time_since_fadein += delta
    if not _faded_in and _time_since_fadein > delay:
        var temp_alpha = 1
        temp_alpha = 1-(_time_since_fadein-delay)/fadein_time
        if temp_alpha < 0:
            temp_alpha = 0
            _faded_in = true
        _fadein_sprite.modulate.a = temp_alpha
