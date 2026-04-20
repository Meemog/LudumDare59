extends Control

@export var play_scene: PackedScene
@export var circle_shrink_speed: float = 5
@export var play_delay: float = 2.5

var _mask: Node2D
var _is_shrinking = false
var _time_since_play: float = 0

func _ready() -> void:
	_mask = $BackBufferCopy/mask

func _process(delta: float) -> void:
	_process_play(delta)
	_process_circle()

func _process_circle() -> void:
	if _is_shrinking:
		var temp_scale = _mask.scale.x
		temp_scale -= circle_shrink_speed*0.01
		if temp_scale < 0: temp_scale = 0
		_mask.scale = temp_scale * Vector2.ONE

func _process_play(delta: float) -> void:
	if _is_shrinking:
		_time_since_play += delta
		if _time_since_play > play_delay:
			get_tree().change_scene_to_packed(play_scene)

func _on_play_button_pressed() -> void:
	if not _is_shrinking:
		_is_shrinking = true
	
func _on_credits_button_pressed() -> void:
	if not _is_shrinking:
		pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	if not _is_shrinking:
		pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	if not _is_shrinking:
		get_tree().quit()
