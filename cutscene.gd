extends Node2D

@export_multiline var text: String
@export var text_speed: float = .1
@export var start_delay: float = 3
@export var end_delay: float = 3
@export var play_scene: PackedScene

var _splash: AnimatedSprite2D
var _text_box: Label
var _time_since_start: float = 0

func _ready() -> void:
    _splash = $Splash
    _splash.play()
    
    _text_box = $Label

func _process(delta: float) -> void:
    _time_since_start += delta
    
    if _time_since_start < start_delay:
        pass
    elif _time_since_start < start_delay + text_speed * text.length()+1:
        _text_box.text = text.substr(0, (_time_since_start-start_delay)/text_speed)
    elif _time_since_start < start_delay + text_speed * text.length()+1 + end_delay:
        get_tree().change_scene_to_packed(play_scene)
