extends Node2D

@export var x_pos: float = 180.0
@export var base_y: float = 640.0
@export var amplitude: float = 210.0
@export var frequency_hz: float = 0.45
@export var radius: float = 22.0
@export var color: Color = Color("#f97316")
@export var explosion_duration: float = 0.45
@export var max_tilt_deg: float = 16.0
@export var tilt_lerp_speed: float = 10.0

var _time_running: float = 0.0
var _exploding: bool = false
var _explode_time: float = 0.0
var _alive_visible: bool = true
var _vertical_velocity: float = 0.0
var _shield_active: bool = false
var _shield_strength: float = 0.0

func reset_player(start_phase_ratio: float = 0.0) -> void:
	var phase := clampf(start_phase_ratio, 0.0, 1.0)
	_time_running = phase / maxf(frequency_hz, 0.0001)
	_exploding = false
	_explode_time = 0.0
	_alive_visible = true
	_vertical_velocity = 0.0
	_shield_active = false
	_shield_strength = 0.0
	position = Vector2(x_pos, base_y + sin(_time_running * TAU * frequency_hz) * amplitude)
	rotation = 0.0
	queue_redraw()

func tick_motion(delta: float) -> void:
	_time_running += delta
	var prev_y := position.y
	position.y = base_y + sin(_time_running * TAU * frequency_hz) * amplitude
	if delta > 0.0:
		_vertical_velocity = (position.y - prev_y) / delta
	var tilt_t := clampf(_vertical_velocity / 520.0, -1.0, 1.0)
	var target_rot := deg_to_rad(max_tilt_deg) * tilt_t
	rotation = lerpf(rotation, target_rot, clampf(tilt_lerp_speed * delta, 0.0, 1.0))

func predict_y(seconds_ahead: float) -> float:
	var t := _time_running + seconds_ahead
	return base_y + sin(t * TAU * frequency_hz) * amplitude

func get_trail_origin_global() -> Vector2:
	var body_len := radius * 2.2
	var tail_x := -body_len * 0.58
	var nozzle_local := Vector2(tail_x - radius * 0.16, 0.0)
	return global_position + nozzle_local.rotated(global_rotation)

func set_shield_active(active: bool, strength: float = 1.0) -> void:
	_shield_active = active
	_shield_strength = clampf(strength, 0.0, 1.0)
	queue_redraw()

func start_death_explosion() -> void:
	_exploding = true
	_explode_time = 0.0
	_alive_visible = false
	queue_redraw()

func tick_explosion(delta: float) -> bool:
	if not _exploding:
		return true
	_explode_time += delta
	if _explode_time >= explosion_duration:
		_exploding = false
		queue_redraw()
		return true
	queue_redraw()
	return false

func _draw() -> void:
	if _alive_visible and _shield_active:
		_draw_shield()
	if _alive_visible:
		_draw_rocket()
	if not _exploding:
		return

	var p := clampf(_explode_time / explosion_duration, 0.0, 1.0)
	var core_alpha := 1.0 - p
	draw_circle(Vector2.ZERO, lerpf(radius * 0.7, radius * 2.4, p), Color(color.r, color.g, color.b, core_alpha * 0.55))

	var shard_count := 10
	for i: int in range(shard_count):
		var angle := TAU * float(i) / float(shard_count) + p * 2.8
		var dist := lerpf(radius * 0.5, radius * 4.8, p)
		var pos := Vector2(cos(angle), sin(angle)) * dist
		var shard_r := lerpf(radius * 0.24, radius * 0.08, p)
		var shard_color := Color(1.0, 0.35, 0.2, (1.0 - p) * 0.9)
		draw_circle(pos, shard_r, shard_color)

func _draw_shield() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var pulse := 0.68 + 0.32 * sin(t * 13.5)
	var a := _shield_strength * (0.34 + 0.28 * pulse)
	var r := radius * (1.52 + 0.11 * pulse)

	# Stronger halo layers.
	draw_circle(Vector2.ZERO, r * 1.34, Color(0.28, 0.78, 1.0, a * 0.44))
	draw_circle(Vector2.ZERO, r * 1.08, Color(0.52, 0.90, 1.0, a * 0.28))
	draw_circle(Vector2.ZERO, r * 0.82, Color(0.65, 0.96, 1.0, a * 0.15))

	# Main ring + inner ring.
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(0.82, 0.98, 1.0, a * 1.35), 3.0, true)
	draw_arc(Vector2.ZERO, r * 0.72, 0.0, TAU, 36, Color(0.72, 0.96, 1.0, a * 0.82), 1.9, true)

func _draw_rocket() -> void:
	var body_len := radius * 2.2
	var body_half_h := radius * 0.58
	var nose_x := body_len * 0.72
	var tail_x := -body_len * 0.58

	# Soft body glow for readability at speed.
	draw_circle(Vector2(0.0, 0.0), radius * 1.28, Color(color.r, color.g, color.b, 0.14))

	# Main hull.
	var body := PackedVector2Array([
		Vector2(tail_x, -body_half_h),
		Vector2(body_len * 0.32, -body_half_h),
		Vector2(nose_x, 0.0),
		Vector2(body_len * 0.32, body_half_h),
		Vector2(tail_x, body_half_h)
	])
	draw_polygon(body, PackedColorArray([color]))

	# Upper highlight strip.
	var highlight := PackedVector2Array([
		Vector2(tail_x + radius * 0.22, -body_half_h * 0.72),
		Vector2(body_len * 0.34, -body_half_h * 0.72),
		Vector2(nose_x - radius * 0.24, -body_half_h * 0.14),
		Vector2(body_len * 0.34, -body_half_h * 0.28),
		Vector2(tail_x + radius * 0.22, -body_half_h * 0.28)
	])
	draw_polygon(highlight, PackedColorArray([color.lightened(0.24)]))

	# Nose cap.
	var nose := PackedVector2Array([
		Vector2(body_len * 0.30, -body_half_h * 0.76),
		Vector2(nose_x, 0.0),
		Vector2(body_len * 0.30, body_half_h * 0.76)
	])
	draw_polygon(nose, PackedColorArray([color.lightened(0.08)]))

	var fin_color := color.darkened(0.28)
	var fin_top := PackedVector2Array([
		Vector2(tail_x + radius * 0.1, -body_half_h * 0.25),
		Vector2(tail_x - radius * 0.75, -body_half_h * 1.05),
		Vector2(tail_x + radius * 0.38, -body_half_h * 0.95)
	])
	var fin_bottom := PackedVector2Array([
		Vector2(tail_x + radius * 0.1, body_half_h * 0.25),
		Vector2(tail_x - radius * 0.75, body_half_h * 1.05),
		Vector2(tail_x + radius * 0.38, body_half_h * 0.95)
	])
	draw_polygon(fin_top, PackedColorArray([fin_color]))
	draw_polygon(fin_bottom, PackedColorArray([fin_color]))

	# Engine cap.
	draw_rect(
		Rect2(Vector2(tail_x - radius * 0.05, -body_half_h * 0.42), Vector2(radius * 0.18, body_half_h * 0.84)),
		Color(0.26, 0.34, 0.48, 0.95),
		true
	)

	var window_color := Color(0.75, 0.92, 1.0, 0.95)
	var window_center := Vector2(radius * 0.16, 0.0)
	draw_circle(window_center, radius * 0.36, Color(0.10, 0.20, 0.34, 0.9))
	draw_circle(window_center, radius * 0.30, window_color)
	draw_circle(window_center + Vector2(radius * 0.04, radius * 0.03), radius * 0.22, Color(0.34, 0.68, 0.96, 0.4))
	draw_circle(window_center + Vector2(radius * 0.06, -radius * 0.08), radius * 0.10, Color(1.0, 1.0, 1.0, 0.8))

	var flame_phase := sin(Time.get_ticks_msec() / 1000.0 * 16.0) * 0.5 + 0.5
	var flame_len := lerpf(radius * 0.55, radius * 1.05, flame_phase)
	var flame_outer := PackedVector2Array([
		Vector2(tail_x - radius * 0.06, -radius * 0.30),
		Vector2(tail_x - flame_len * 1.08, 0.0),
		Vector2(tail_x - radius * 0.06, radius * 0.30)
	])
	var flame := PackedVector2Array([
		Vector2(tail_x - radius * 0.02, -radius * 0.22),
		Vector2(tail_x - flame_len, 0.0),
		Vector2(tail_x - radius * 0.02, radius * 0.22)
	])
	var flame_core := PackedVector2Array([
		Vector2(tail_x + radius * 0.02, -radius * 0.10),
		Vector2(tail_x - flame_len * 0.62, 0.0),
		Vector2(tail_x + radius * 0.02, radius * 0.10)
	])
	draw_polygon(flame_outer, PackedColorArray([Color(1.0, 0.46, 0.18, 0.74)]))
	draw_polygon(flame, PackedColorArray([Color(1.0, 0.74, 0.24, 0.92)]))
	draw_polygon(flame_core, PackedColorArray([Color(1.0, 0.97, 0.76, 0.94)]))
