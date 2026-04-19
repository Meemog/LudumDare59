extends Control

@export var play_scene: PackedScene

func _on_play_button_pressed() -> void:
    get_tree().change_scene_to_packed(play_scene)
