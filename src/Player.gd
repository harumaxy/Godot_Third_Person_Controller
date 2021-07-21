extends KinematicBody

# consts
export var walk_speed := 100
export var run_speed := 200
const gravity = Globals.gravity

# states
var direction := Vector3.FORWARD
var velocity = Vector3.ZERO
var vertical_vel = 0
var acceleration = 5
var angular_acceleration = 7

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
  velocity = lerp(velocity, direction * speed, delta * acceleration)
  self.move_and_slide(velocity * delta + vertical_vel * Vector3.DOWN , Vector3.UP)

  # 垂直の速度と水平の速度は別で管理
  if !self.is_on_floor():
    vertical_vel += gravity * delta
  else:
    vertical_vel = 0

  # カメラの回転と、Mesh の回転は別管理
  # lerp_angle : 角度を線形補間
  # atan2() : Vector2(y, x)  を与えその角度を返す
  if direction != Vector3.ZERO:
    $Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(direction.x, direction.z), angular_acceleration * delta)

