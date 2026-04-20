extends Node2D

@export var player: Node2D ## Player reference
@export var distance_threshhold: float = 1500 ## Distance at which sonar switches to close range
@export var growth_speed: float = .15 ## The speed at which the personal sonar grows
@export var fade_time: float = 1 ## The time it takes for the sonar to fully fade
@export var max_alpha: float = 1 ## Alpha value of the darkness
@export var sonar_delay: float = 10 ## Time in seconds between sonar pings
@export var end_cutscene: PackedScene
@export var music_player: AudioStreamPlayer

@export var fadeout_time: float = 3

var _sprite: AnimatedSprite2D
var _time_since_sonar: float = 0
var _sonar_active: bool = false
var _sonar_dark: Sprite2D
var _sonar_cone: Node2D
var _fading_out: bool
var _time_since_fadeout: float = 0
var _fadeout_sprite: Sprite2D

func _ready() -> void:
    _sprite = $AnimatedSprite2D
    _sprite.play("default")
    
    _sonar_dark = $PersonalSonar/dark
    _sonar_cone = $PersonalSonar
    
    _fadeout_sprite = $FadeOut

func _process(delta: float) -> void:
    _process_sonar(delta)
    _process_fadeout(delta)

func make_happy() -> void:
    _sprite.play("happy")

func _on_area_2d_body_entered(body: Node2D) -> void:
    make_happy()
    _fading_out = true

func _process_fadeout(delta: float) -> void:
    if _fading_out:
        _time_since_fadeout += delta
        var tmp_alpha = _time_since_fadeout/fadeout_time
        if tmp_alpha > 1:
            tmp_alpha = 1
            get_tree().change_scene_to_packed(end_cutscene)
        music_player.volume_db = tmp_alpha * -60
        _fadeout_sprite.modulate.a = tmp_alpha


func _start_close_sonar() -> void:
    _sonar_active = true
    _time_since_sonar = 0
    _sonar_dark.self_modulate.a = 0
    _sonar_cone.scale = Vector2.ZERO
    _sonar_cone.visible = true

func _process_sonar(delta: float) -> void:
    _time_since_sonar += delta
    if _sonar_active and not _fading_out:
        _sonar_cone.scale += Vector2(growth_speed, growth_speed)
        var alpha = (_time_since_sonar/fade_time) * max_alpha
        _sonar_dark.self_modulate.a = alpha
        if _time_since_sonar > fade_time:
            _sonar_cone.visible = false
            _sonar_active = false
    if _time_since_sonar > sonar_delay:
        _start_close_sonar()
        _time_since_sonar = 0

func _sonar_ping():
    # If player is too far from rocky, perform wider sonar, otherwise, use normal ping
    var to_player: Vector2 = position - player.position
    
    if to_player.length() < distance_threshhold:
        _start_close_sonar()
        
