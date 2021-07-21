extends Spatial

# params
export var rot_v_min := -55
export var rot_v_max := 75
export var sensitivity := Vector2(0.1, 0.1)
export var acceleration := Vector2(10, 10)


# state
var rot_h = 0
var rot_v = 0

func _ready():
  # ClippedCamera.add_exception(Node) : 特定のNodeの子要素のCollisionShapeを衝突しないようにする
  $h/v/ClippedCamera.add_exception(get_parent())

func _input(event):
  if event is InputEventMouseMotion:
    rot_h += -event.relative.x * sensitivity.x
    rot_v += event.relative.y * sensitivity.y


func _physics_process(delta):
  rot_v = clamp(rot_v, rot_v_min, rot_v_max)
  $h.rotation_degrees.y = lerp($h.rotation_degrees.y, rot_h, acceleration.x * delta)
  $h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, rot_v, acceleration.y * delta)
