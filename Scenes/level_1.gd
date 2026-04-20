extends Node2D

@export var fadein_time: float = 1.5
@export var delay: float = .5
@export var music_fadeout_time = 1
@export var music_delay = .5

var _shallow_music: AudioStreamPlayer
var _deep_music: AudioStreamPlayer
var _time_since_fadein: float = 0
var _faded_in: bool = false
var _fadein_sprite: Sprite2D
var _music_fading: bool = false
var _time_since_music_fading = 0
var _music_triggered = false
var _flag = false

func _ready() -> void:
    _shallow_music = $ShallowMusic
    _deep_music = $DeepMusic
    _fadein_sprite = $FadeIn
    
func _process(delta: float) -> void:
    _process_fadein(delta)
    _process_music_fadeout(delta)

func _process_fadein(delta: float) -> void:
    _time_since_fadein += delta
    if not _faded_in and _time_since_fadein > delay:
        var temp_alpha = 1
        temp_alpha = 1-(_time_since_fadein-delay)/fadein_time
        if temp_alpha < 0:
            temp_alpha = 0
            _faded_in = true
            _shallow_music.play()
        _fadein_sprite.modulate.a = temp_alpha
        
func _process_music_fadeout(delta: float):
    if _music_fading:
        _time_since_music_fading += delta
        var tmp_db = _time_since_music_fading/music_fadeout_time * -60
        if tmp_db <= -60 and not _flag:
            tmp_db = -60
            _shallow_music.stop()
            _flag = true
        _shallow_music.volume_db = tmp_db
    if _time_since_music_fading > music_fadeout_time + music_delay and _music_fading:
        _deep_music.play()
        _music_fading = false

func _on_music_trigger_body_entered(body: Node2D) -> void:
    if _music_fading == false:
        _music_fading = true
        _music_triggered = true
