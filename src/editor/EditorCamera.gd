extends Camera2D

const CAMERA_MOVE_SPEED := 10
const CAMERA_ZOOM_SPEED := 0.01

func _physics_process(_delta : float) -> void:
	if Flow.is_in_editor_mode:
		# move
		var move_direction := Vector2.ZERO
		if Input.is_action_pressed("move_left"): move_direction.x -= 1
		if Input.is_action_pressed("move_right"): move_direction.x += 1
		if Input.is_action_pressed("move_up"): move_direction.y -= 1
		if Input.is_action_pressed("move_down"): move_direction.y += 1
		_move(move_direction.normalized())
		# zoom
		var zoom_direction := 0.0
		if Input.is_action_pressed("zoom_camera_out"): zoom_direction += 1
		if Input.is_action_pressed("zoom_camera_in"): zoom_direction -= 1
		_zoom(zoom_direction)

func _move(direction : Vector2) -> void:
	position.x += zoom.x * direction.x * CAMERA_MOVE_SPEED
	position.y += zoom.y * direction.y * CAMERA_MOVE_SPEED

func _zoom(direction : float) -> void:
	zoom += Vector2.ONE * direction * CAMERA_ZOOM_SPEED
