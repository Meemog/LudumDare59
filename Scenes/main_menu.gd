extends Control

@export var play_scene: PackedScene

func _on_play_button_pressed() -> void:
    get_tree().change_scene_to_packed(play_scene)
    
func _on_credits_button_pressed() -> void:
    pass # Replace with function body.

func _on_settings_button_pressed() -> void:
    pass # Replace with function body.

func _on_quit_button_pressed() -> void:
    get_tree().quit()
