extends KinematicBody

# consts
export var walk_speed := 100
export var run_speed := 200
const gravity = Globals.gravity

# states
var direction := Vector3.FORWARD
var velocity = Vector3.ZERO
var vertical_vel = 0
var acceleration = 6

# ColorRect + Label で、キー入力を可視化するUIを作る
func _input(event):
  if event is InputEventKey:
    var text = event.as_text()
    if text in ["W", "A", "S", "D", "Space"]:
      var color_rect : ColorRect = get_node("Status/" + text)
      if event.pressed:
        color_rect.color = Color("ff6666")
      else:
        color_rect.color = Color.white

# CameraRoot/h のy軸回転量に応じて、入力方向をカメラの向いてる方に修正
func _get_direction_input(h_rot: float):
  var x := Input.get_action_strength("left") - Input.get_action_strength("right")
  var z := Input.get_action_strength("forward") - Input.get_action_strength("backward")
  return Vector3(x, 0, z).rotated(Vector3.UP, h_rot).normalized()

func _physics_process(delta):
  var h_rot = $CameraRoot/h.global_transform.basis.get_euler().y
  var direction = _get_direction_input(h_rot)
  var speed = run_speed if Input.is_action_pressed("sprint") else walk_speed
  self.move_and_slide(direction * speed * delta, Vector3.UP)

  if !self.is_on_floor():
    vertical_vel += gravity * delta
  else:
    vertical_vel = 0
