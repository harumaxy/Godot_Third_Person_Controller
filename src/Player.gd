extends KinematicBody

# consts
export var walk_speed := 100
export var run_speed := 200
const gravity = Globals.gravity
const strafe_dir_key = "parameters/strafe/blend_position"
const aim_transition_key = "parameters/aim_transition/current"

enum AimTransition {
  Aim = 0,
  NoAim
 }

# states
var direction := Vector3.FORWARD
var velocity = Vector3.ZERO
var vertical_vel = 0
var acceleration = 5
var angular_acceleration = 7

# animation param
var strafe_dir := Vector2.ZERO

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

  if Input.is_action_pressed("aim"):
    $Status/Aim.color = Color("ff6666")
  else:
    $Status/Aim.color = Color.white

# CameraRoot/h のy軸回転量に応じて、入力方向をカメラの向いてる方に修正
func _get_direction_input(h_rot: float):
  var x := Input.get_action_strength("left") - Input.get_action_strength("right")
  var z := Input.get_action_strength("forward") - Input.get_action_strength("backward")
  return Vector3(x, 0, z)



func _process(delta):
  if Input.is_action_pressed("aim"):
    $AnimationTree.set(aim_transition_key, AimTransition.Aim)
  else:
    $AnimationTree.set(aim_transition_key, AimTransition.NoAim)


func _physics_process(delta):
  var h_rot = $CameraRoot/h.global_transform.basis.get_euler().y
  var direction = _get_direction_input(h_rot)
  if $AnimationTree.get(aim_transition_key) == AimTransition.Aim:
    direction = $CameraRoot/h.global_transform.basis.z
  var speed = run_speed if Input.is_action_pressed("sprint") else walk_speed
  velocity = lerp(velocity, direction.normalized().rotated(Vector3.UP, h_rot) * speed, delta * acceleration)
  self.move_and_slide(velocity * delta + vertical_vel * Vector3.DOWN , Vector3.UP)

  strafe_dir = lerp(strafe_dir, Vector2(-direction.x, direction.z), acceleration * delta)
  # AnimationTree Params Update
  $AnimationTree.set(strafe_dir_key, strafe_dir)

  # 垂直の速度と水平の速度は別で管理
  if !self.is_on_floor():
    vertical_vel += gravity * delta
  else:
    vertical_vel = 0

  # カメラの回転と、Mesh の回転は別管理
  # lerp_angle : 角度を線形補間
  # atan2() : Vector2(y, x)  を与えその角度を返す
  if $AnimationTree.get(aim_transition_key) == AimTransition.Aim:
    $Mesh.rotation.y = lerp_angle($Mesh.rotation.y, h_rot, angular_acceleration * delta)
  else:
    if direction != Vector3.ZERO:
      $Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(direction.x, direction.z), angular_acceleration * delta)


