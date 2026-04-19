extends CanvasLayer

var enabled: Array = [true, true, true, true]
var _sonars: Array[TextureRect] 

func _ready() -> void:
    _sonars = [$Control/sonar1, $Control/sonar2, $Control/sonar3, $Control/sonar4]

func reload() -> void:
    for i in range(_sonars.size()):
        _sonars[i].visible = enabled[i]

func set_sonars(count: int):
    for i in range(count):
        enabled[i] = true
    for j in range(4-count):
        enabled[count+j] = false
    reload()
