extends Node2D

signal warning_started(target_y: float)
signal sweep_triggered(target_y: float)

@export var interval_sec: float = 2.8
@export var warning_sec: float = 0.8
@export var band_half_height: float = 44.0
@export var target_jitter: float = 36.0
@export var threat_probability: float = 0.62
@export var safe_offset: float = 130.0
@export var warning_color: Color = Color(1.0, 0.25, 0.2, 0.25)
@export var sweep_color: Color = Color(1.0, 0.45, 0.35, 0.7)
@export var warning_line_count: int = 9
@export var stripe_spacing: float = 42.0

var _timer: float = 0.0
var _warning_active: bool = false
var _warning_y: float = 640.0
var _flash_time_left: float = 0.0
var _forced_warning_pending: bool = false
var _target_center_y: float = 640.0
var _target_min_y: float = 140.0
var _target_max_y: float = 1140.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

func reset_sweep(view_size: Vector2) -> void:
	_timer = 0.0
	_warning_active = false
	_forced_warning_pending = false
	_warning_y = view_size.y * 0.5
	_target_center_y = _warning_y
	_target_min_y = 140.0
	_target_max_y = view_size.y - 140.0
	_flash_time_left = 0.0
	queue_redraw()

func set_target_window(center_y: float, min_y: float, max_y: float) -> void:
	_target_center_y = center_y
	_target_min_y = minf(min_y, max_y)
	_target_max_y = maxf(min_y, max_y)

func tick_sweep(delta: float, view_size: Vector2, running: bool) -> void:
	if not running:
		if _flash_time_left > 0.0:
			_flash_time_left = maxf(_flash_time_left - delta, 0.0)
			queue_redraw()
		return

	_timer += delta
	if not _warning_active and _timer >= interval_sec - warning_sec:
		_warning_active = true
		var margin := band_half_height + 12.0
		var clamped_min := maxf(_target_min_y, margin)
		var clamped_max := minf(_target_max_y, view_size.y - margin)
		var centered := _target_center_y + _rng.randf_range(-target_jitter, target_jitter)
		if _rng.randf() > threat_probability:
			var dir := -1.0 if _rng.randf() < 0.5 else 1.0
			centered = _target_center_y + dir * safe_offset + _rng.randf_range(-target_jitter, target_jitter)
		_warning_y = clampf(centered, clamped_min, clamped_max)
		emit_signal("warning_started", _warning_y)
		queue_redraw()

	if _warning_active and not _forced_warning_pending and _timer >= interval_sec:
		_warning_active = false
		_timer = 0.0
		_flash_time_left = 0.12
		emit_signal("sweep_triggered", _warning_y)
		queue_redraw()

	if _flash_time_left > 0.0:
		_flash_time_left = maxf(_flash_time_left - delta, 0.0)
		queue_redraw()

func overlaps_y(y: float) -> bool:
	return absf(y - _warning_y) <= band_half_height

func distance_to_band(y: float) -> float:
	return absf(y - _warning_y) - band_half_height

func is_warning_active() -> bool:
	return _warning_active

func time_until_sweep() -> float:
	return maxf(interval_sec - _timer, 0.0)

func force_sweep_at(target_y: float, view_size: Vector2) -> void:
	var margin := band_half_height + 12.0
	_warning_y = clampf(target_y, margin, view_size.y - margin)
	_warning_active = false
	_forced_warning_pending = false
	_timer = 0.0
	_flash_time_left = 0.12
	emit_signal("sweep_triggered", _warning_y)
	queue_redraw()

func force_warning_at(target_y: float, view_size: Vector2) -> void:
	var margin := band_half_height + 12.0
	_warning_y = clampf(target_y, margin, view_size.y - margin)
	_warning_active = true
	_forced_warning_pending = true
	emit_signal("warning_started", _warning_y)
	queue_redraw()

func _draw() -> void:
	var width := get_viewport_rect().size.x
	if _warning_active:
		_draw_warning_band(width)
	if _flash_time_left > 0.0:
		_draw_sweep_flash(width)

func _draw_warning_band(width: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var pulse := 0.66 + 0.34 * sin(t * 6.8)
	var warn_start := interval_sec - warning_sec
	var warning_progress := 1.0
	if warning_sec > 0.001:
		warning_progress = clampf((_timer - warn_start) / warning_sec, 0.0, 1.0)
	# Keep warning visible from the start so mid colors are perceivable.
	var ramp := 0.20 + 0.80 * pow(warning_progress, 0.72)
	var start_color: Color = Color("#facc15") # yellow
	var mid_color: Color = Color("#fb923c") # orange
	var end_color: Color = Color("#ef4444") # red
	var body_tint: Color
	# Phase 1: yellow -> orange, Phase 2: hold orange, Phase 3: orange -> red.
	if warning_progress < 0.36:
		var t1: float = warning_progress / 0.36
		body_tint = start_color.lerp(mid_color, t1)
	elif warning_progress < 0.62:
		body_tint = mid_color
	else:
		var t2: float = (warning_progress - 0.62) / 0.38
		body_tint = mid_color.lerp(end_color, t2)
	var core_tint: Color = body_tint.lightened(0.28)
	var orb_tint: Color = body_tint.lightened(0.12)

	_draw_comet_glow_band(
		width,
		_warning_y,
		band_half_height * 1.38,
		body_tint,
		(0.06 + 0.20 * ramp) * (0.75 + 0.25 * pulse),
		t,
		92.0
	)
	_draw_comet_core(
		width,
		_warning_y,
		band_half_height * 0.50,
		Color(core_tint.r, core_tint.g, core_tint.b, (0.05 + 0.26 * ramp) * (0.78 + 0.22 * pulse))
	)
	_draw_comet_orbs(
		width,
		_warning_y,
		band_half_height * 0.62,
		Color(orb_tint.r, orb_tint.g, orb_tint.b, (0.03 + 0.18 * ramp) * (0.8 + 0.2 * pulse)),
		t,
		88.0
	)

func _draw_sweep_flash(width: float) -> void:
	var p := clampf(_flash_time_left / 0.12, 0.0, 1.0)
	var t := Time.get_ticks_msec() / 1000.0
	_draw_comet_glow_band(
		width,
		_warning_y,
		band_half_height * 1.62,
		Color(1.0, 0.24, 0.2, 1.0),
		0.56 * p,
		t,
		140.0
	)
	_draw_comet_core(
		width,
		_warning_y,
		band_half_height * 0.72,
		Color(1.0, 0.92, 0.84, 0.52 * p)
	)
	_draw_comet_orbs(
		width,
		_warning_y,
		band_half_height * 0.8,
		Color(1.0, 0.62, 0.54, 0.34 * p),
		t,
		150.0
	)

func _draw_comet_glow_band(
	width: float,
	center_y: float,
	core_height: float,
	tint: Color,
	alpha: float,
	t_sec: float,
	drift_speed: float
) -> void:
	var layers: int = 7
	for i: int in range(layers):
		var k := float(i) / float(layers - 1)
		var h := lerpf(core_height, core_height * 2.0, k)
		var a := alpha * pow(1.0 - k, 1.35)
		var drift := sin(t_sec * 1.9 + k * 5.2) * (4.0 + 10.0 * k)
		var y := center_y + drift - h * 0.5
		draw_rect(Rect2(Vector2(0.0, y), Vector2(width, h)), Color(tint.r, tint.g, tint.b, a), true)

	# Flow texture: subtle horizontal streaks inside the glow.
	var spacing := maxf(stripe_spacing, 24.0)
	var offset := fmod(t_sec * drift_speed, spacing)
	var x := -spacing + offset
	while x < width + spacing:
		var streak_w := 40.0
		var streak_h := core_height * 0.82
		var streak_y := center_y - streak_h * 0.5 + sin(t_sec * 6.0 + x * 0.02) * 8.0
		draw_rect(
			Rect2(Vector2(x, streak_y), Vector2(streak_w, streak_h)),
			Color(tint.r, tint.g * 1.1, tint.b * 1.1, alpha * 0.22),
			true
		)
		x += spacing

func _draw_comet_core(width: float, center_y: float, core_half_height: float, color: Color) -> void:
	var h := core_half_height * 2.0
	draw_rect(Rect2(Vector2(0.0, center_y - h * 0.5), Vector2(width, h)), color, true)
	draw_line(
		Vector2(0.0, center_y),
		Vector2(width, center_y),
		Color(1.0, 0.96, 0.90, color.a * 0.8),
		2.0,
		true
	)

func _draw_comet_orbs(
	width: float,
	center_y: float,
	radius: float,
	color: Color,
	t_sec: float,
	speed: float
) -> void:
	var spacing := 88.0
	var offset := fmod(t_sec * speed, spacing)
	var x := -spacing + offset
	while x < width + spacing:
		var wave := sin(t_sec * 5.4 + x * 0.015)
		var y := center_y + wave * radius * 0.14
		draw_circle(Vector2(x, y), radius * 0.26, color)
		draw_circle(
			Vector2(x + 8.0, y + 3.0),
			radius * 0.14,
			Color(1.0, 0.84, 0.76, color.a * 0.75)
		)
		x += spacing
