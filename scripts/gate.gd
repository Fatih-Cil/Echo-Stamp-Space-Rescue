extends Node2D

signal scored

@export var size := Vector2(72.0, 230.0)
@export var fill_color: Color = Color("#22c55e")
@export var stroke_color: Color = Color("#dcfce7")
@export var burst_duration: float = 0.34

var already_scored: bool = false
var _burst_active: bool = false
var _burst_time: float = 0.0
var _burst_strong: bool = false
var _consumed: bool = false

func tick_move(delta: float, scroll_speed: float) -> void:
	position.x -= scroll_speed * delta
	if _burst_active:
		_burst_time += delta
		if _burst_time >= burst_duration:
			_burst_active = false
			queue_free()
			return
		queue_redraw()

func try_score(player_position: Vector2) -> bool:
	if already_scored:
		return false
	var rect := Rect2(global_position - size * 0.5, size)
	if rect.has_point(player_position):
		already_scored = true
		emit_signal("scored")
		queue_redraw()
		return true
	return false

func play_score_burst(strong: bool) -> void:
	_burst_active = true
	_burst_time = 0.0
	_burst_strong = strong
	_consumed = true
	queue_redraw()

func is_offscreen() -> bool:
	return global_position.x < -size.x

func _draw() -> void:
	var base_color: Color = fill_color if not already_scored else fill_color.darkened(0.45)
	var accent_color: Color = stroke_color if not already_scored else stroke_color.darkened(0.5)
	var alpha_mul: float = 1.0 if not already_scored else 0.72

	if not _consumed:
		_draw_energy_column(base_color, alpha_mul)
		_draw_planet(base_color, accent_color, alpha_mul)

	if _burst_active:
		_draw_burst()

func _draw_energy_column(base_color: Color, alpha_mul: float) -> void:
	var h: float = size.y
	for i: int in range(4):
		var k: float = float(i) / 3.0
		var w: float = lerpf(size.x * 0.34, size.x * 0.96, k)
		var a: float = (0.16 - 0.035 * k) * alpha_mul
		var rect := Rect2(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h))
		draw_rect(rect, Color(base_color.r, base_color.g, base_color.b, a), true)

func _draw_planet(base_color: Color, accent_color: Color, alpha_mul: float) -> void:
	var center := Vector2.ZERO
	var planet_r: float = size.x * 0.36

	# Outer atmospheric halo.
	draw_circle(center, planet_r * 1.45, Color(base_color.r, base_color.g, base_color.b, 0.13 * alpha_mul))
	draw_circle(center, planet_r * 1.16, Color(base_color.r, base_color.g, base_color.b, 0.18 * alpha_mul))

	# Core planet body.
	draw_circle(center, planet_r, base_color)
	draw_circle(center + Vector2(-planet_r * 0.22, -planet_r * 0.18), planet_r * 0.82, base_color.lightened(0.1))

	# Surface features.
	draw_circle(center + Vector2(-planet_r * 0.36, planet_r * 0.08), planet_r * 0.2, Color(0.0, 0.0, 0.0, 0.12 * alpha_mul))
	draw_circle(center + Vector2(planet_r * 0.22, -planet_r * 0.26), planet_r * 0.13, Color(1.0, 1.0, 1.0, 0.14 * alpha_mul))

	# Orbit ring.
	_draw_ellipse_ring(center, planet_r * 1.45, planet_r * 0.55, accent_color, 3.0, alpha_mul)

	# Small moons to make it read as a "space object" at game speed.
	var moon_top := center + Vector2(0.0, -size.y * 0.26)
	var moon_bottom := center + Vector2(0.0, size.y * 0.26)
	draw_circle(moon_top, planet_r * 0.22, Color(accent_color.r, accent_color.g, accent_color.b, 0.78 * alpha_mul))
	draw_circle(moon_bottom, planet_r * 0.18, Color(accent_color.r, accent_color.g, accent_color.b, 0.64 * alpha_mul))

func _draw_ellipse_ring(center: Vector2, rx: float, ry: float, color: Color, width: float, alpha_mul: float) -> void:
	var points := PackedVector2Array()
	var segments: int = 40
	for i: int in range(segments + 1):
		var a: float = TAU * float(i) / float(segments)
		points.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(points, Color(color.r, color.g, color.b, 0.85 * alpha_mul), width, true)

func _draw_burst() -> void:
	var p := clampf(_burst_time / burst_duration, 0.0, 1.0)
	var center := Vector2.ZERO
	var ring_color: Color = Color("#fef08a") if _burst_strong else Color("#a7f3d0")
	var ring_alpha := (1.0 - p) * (0.95 if _burst_strong else 0.75)
	draw_arc(center, lerpf(18.0, 135.0 if _burst_strong else 102.0, p), 0.0, TAU, 42, Color(ring_color.r, ring_color.g, ring_color.b, ring_alpha), 5.0 if _burst_strong else 3.0, true)

	var shard_count := 16 if _burst_strong else 10
	for i: int in range(shard_count):
		var a := TAU * float(i) / float(shard_count) + p * 1.2
		var dist := lerpf(8.0, 140.0 if _burst_strong else 96.0, p)
		var pos := Vector2(cos(a), sin(a)) * dist
		var r := lerpf(7.0, 1.5, p) * (1.15 if _burst_strong else 0.9)
		var c := Color(ring_color.r, ring_color.g, ring_color.b, (1.0 - p) * 0.9)
		draw_circle(pos, r, c)
