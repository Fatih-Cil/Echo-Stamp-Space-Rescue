extends Node2D

@export var base_lifetime: float = 0.55
@export var min_speed: float = 110.0
@export var max_speed: float = 240.0
@export var spread_degrees: float = 28.0

var _particles: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	z_index = 30

func clear_sparkles() -> void:
	_particles.clear()
	queue_redraw()

func emit_burst(global_origin: Vector2, rocket_rotation: float, count: int = 14) -> void:
	var origin_local: Vector2 = to_local(global_origin)
	var base_dir: Vector2 = Vector2.LEFT.rotated(rocket_rotation)
	for _i: int in range(count):
		var spread: float = deg_to_rad(_rng.randf_range(-spread_degrees, spread_degrees))
		var dir: Vector2 = base_dir.rotated(spread).normalized()
		var speed: float = _rng.randf_range(min_speed, max_speed)
		var life: float = _rng.randf_range(base_lifetime * 0.72, base_lifetime * 1.2)
		var size: float = _rng.randf_range(8.0, 14.0)
		var tint_mix: float = _rng.randf()
		_particles.append({
			"pos": origin_local + dir * _rng.randf_range(1.0, 7.0),
			"vel": dir * speed + Vector2(0.0, _rng.randf_range(-28.0, 28.0)),
			"life": life,
			"max_life": life,
			"size": size,
			"rot": _rng.randf() * TAU,
			"tint_mix": tint_mix
		})
	queue_redraw()

func tick_sparkles(delta: float, scroll_speed: float) -> void:
	if _particles.is_empty():
		return
	for i: int in range(_particles.size() - 1, -1, -1):
		var p: Dictionary = _particles[i]
		var life: float = float(p["life"]) - delta
		if life <= 0.0:
			_particles.remove_at(i)
			continue

		var vel: Vector2 = p["vel"] as Vector2
		vel *= 0.95
		var pos: Vector2 = p["pos"] as Vector2
		pos += (vel + Vector2.LEFT * scroll_speed * 0.28) * delta

		p["life"] = life
		p["vel"] = vel
		p["pos"] = pos
		p["rot"] = float(p["rot"]) + delta * 6.2
		_particles[i] = p
	queue_redraw()

func _draw() -> void:
	for p: Dictionary in _particles:
		var life: float = float(p["life"])
		var max_life: float = float(p["max_life"])
		var t: float = clampf(life / max_life, 0.0, 1.0)
		var size: float = float(p["size"]) * (0.75 + 0.95 * t)
		var pos: Vector2 = p["pos"] as Vector2
		var rot: float = float(p["rot"])
		var tint_mix: float = float(p["tint_mix"])

		var warm := Color(1.0, 0.86, 0.44, 0.98 * t)
		var cool := Color(0.64, 0.86, 1.0, 0.88 * t)
		var c: Color = warm.lerp(cool, tint_mix)

		draw_circle(pos, size * 1.55, Color(c.r, c.g, c.b, c.a * 0.32))
		_draw_star(pos, size, size * 0.42, 5, rot, c)
		draw_line(pos + Vector2(-size * 0.7, 0.0), pos + Vector2(size * 0.7, 0.0), Color(1.0, 0.98, 0.84, c.a * 0.7), 2.0, true)
		draw_line(pos + Vector2(0.0, -size * 0.7), pos + Vector2(0.0, size * 0.7), Color(1.0, 0.98, 0.84, c.a * 0.7), 2.0, true)

func _draw_star(center: Vector2, outer_r: float, inner_r: float, points: int, rot: float, color: Color) -> void:
	var verts := PackedVector2Array()
	var total: int = points * 2
	for i: int in range(total):
		var a: float = rot + TAU * float(i) / float(total)
		var r: float = outer_r if i % 2 == 0 else inner_r
		verts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_polygon(verts, PackedColorArray([color]))
