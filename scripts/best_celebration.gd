extends Node2D
class_name BestCelebration

@export var in_run_duration_sec: float = 1.35
@export var post_death_duration_sec: float = 3.8

var _active: bool = false
var _time_left: float = 0.0
var _rockets: Array[Dictionary] = []
var _sparks: Array[Dictionary] = []
var _scheduled_bursts: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

func trigger_celebration() -> void:
	_active = true
	_time_left = in_run_duration_sec
	_rockets.clear()
	_sparks.clear()
	_scheduled_bursts.clear()

	var view := get_viewport_rect().size
	for i: int in range(8):
		_rockets.append({
			"delay": float(i) * 0.11,
			"pos": Vector2(_rng.randf_range(80.0, view.x - 80.0), view.y + _rng.randf_range(20.0, 130.0)),
			"vel": Vector2(_rng.randf_range(-24.0, 24.0), _rng.randf_range(-470.0, -350.0)),
			"age": 0.0,
			"explode_at": _rng.randf_range(0.55, 0.92),
			"color": _pick_firework_color(),
			"exploded": false
		})
	queue_redraw()

func trigger_fullscreen_celebration() -> void:
	_active = true
	_time_left = post_death_duration_sec
	_rockets.clear()
	_sparks.clear()
	_scheduled_bursts.clear()

	var view: Vector2 = get_viewport_rect().size
	for _i: int in range(14):
		var p := Vector2(
			_rng.randf_range(70.0, view.x - 70.0),
			_rng.randf_range(90.0, view.y - 110.0)
		)
		_spawn_explosion(p, _pick_firework_color(), true)

	# Timed full-screen burst waves over the whole celebration duration.
	for i: int in range(22):
		_scheduled_bursts.append({
			"delay": 0.24 + float(i) * 0.16,
			"pos": Vector2(
				_rng.randf_range(70.0, view.x - 70.0),
				_rng.randf_range(90.0, view.y - 110.0)
			),
			"color": _pick_firework_color(),
			"strong": _rng.randf() > 0.45
		})
	queue_redraw()

func clear_effect() -> void:
	_active = false
	_time_left = 0.0
	_rockets.clear()
	_sparks.clear()
	_scheduled_bursts.clear()
	queue_redraw()

func _process(delta: float) -> void:
	if not _active and _rockets.is_empty() and _sparks.is_empty():
		return

	for i: int in range(_rockets.size() - 1, -1, -1):
		var r: Dictionary = _rockets[i]
		var delay: float = float(r["delay"])
		if delay > 0.0:
			r["delay"] = delay - delta
			_rockets[i] = r
			continue

		var age: float = float(r["age"]) + delta
		var pos: Vector2 = r["pos"] as Vector2
		var vel: Vector2 = r["vel"] as Vector2
		vel.y += 180.0 * delta
		pos += vel * delta
		r["age"] = age
		r["pos"] = pos
		r["vel"] = vel
		_rockets[i] = r

		if not bool(r["exploded"]) and age >= float(r["explode_at"]):
			_spawn_explosion(pos, r["color"] as Color, true)
			r["exploded"] = true
			_rockets[i] = r
			_rockets.remove_at(i)
			continue

		if pos.y < -60.0:
			_rockets.remove_at(i)

	for i: int in range(_sparks.size() - 1, -1, -1):
		var s: Dictionary = _sparks[i]
		var life: float = float(s["life"]) - delta
		if life <= 0.0:
			_sparks.remove_at(i)
			continue

		var pos: Vector2 = s["pos"] as Vector2
		var vel: Vector2 = s["vel"] as Vector2
		vel *= 0.985
		vel.y += 110.0 * delta
		pos += vel * delta
		s["life"] = life
		s["pos"] = pos
		s["vel"] = vel
		_sparks[i] = s

	for i: int in range(_scheduled_bursts.size() - 1, -1, -1):
		var b: Dictionary = _scheduled_bursts[i]
		var delay: float = float(b["delay"]) - delta
		if delay > 0.0:
			b["delay"] = delay
			_scheduled_bursts[i] = b
			continue
		_spawn_explosion(b["pos"] as Vector2, b["color"] as Color, bool(b["strong"]))
		_scheduled_bursts.remove_at(i)

	if _active:
		_time_left = maxf(_time_left - delta, 0.0)
		if _time_left <= 0.0 and _rockets.is_empty() and _sparks.is_empty() and _scheduled_bursts.is_empty():
			_active = false

	queue_redraw()

func _draw() -> void:
	for r: Dictionary in _rockets:
		var delay: float = float(r["delay"])
		if delay > 0.0:
			continue
		var pos: Vector2 = r["pos"] as Vector2
		var c: Color = r["color"] as Color
		draw_circle(pos, 4.2, Color(c.r, c.g, c.b, 0.95))
		draw_circle(pos, 10.0, Color(c.r, c.g, c.b, 0.22))

	for s: Dictionary in _sparks:
		var life: float = float(s["life"])
		var max_life: float = float(s["max_life"])
		var t: float = clampf(life / max_life, 0.0, 1.0)
		var pos: Vector2 = s["pos"] as Vector2
		var vel: Vector2 = s["vel"] as Vector2
		var c: Color = s["color"] as Color
		var alpha: float = t * t
		var r: float = float(s["r"]) * (0.55 + 0.65 * t)
		draw_circle(pos, r * 1.45, Color(c.r, c.g, c.b, alpha * 0.16))
		draw_circle(pos, r, Color(c.r, c.g, c.b, alpha * 0.92))
		var n := vel.normalized()
		draw_line(pos - n * (r * 1.4), pos + n * (r * 1.4), Color(1.0, 1.0, 1.0, alpha * 0.56), 1.5, true)

func _spawn_explosion(origin: Vector2, base_color: Color, strong: bool) -> void:
	var count: int = 30 if strong else 20
	for i: int in range(count):
		var a: float = TAU * float(i) / float(count) + _rng.randf_range(-0.12, 0.12)
		var speed: float = _rng.randf_range(110.0, 280.0 if strong else 220.0)
		var vel := Vector2(cos(a), sin(a)) * speed
		var life: float = _rng.randf_range(0.45, 0.95)
		var color_jitter: float = _rng.randf_range(-0.08, 0.08)
		var c := Color(
			clampf(base_color.r + color_jitter, 0.0, 1.0),
			clampf(base_color.g + color_jitter, 0.0, 1.0),
			clampf(base_color.b + color_jitter, 0.0, 1.0),
			1.0
		)
		_sparks.append({
			"pos": origin + Vector2(_rng.randf_range(-6.0, 6.0), _rng.randf_range(-6.0, 6.0)),
			"vel": vel,
			"life": life,
			"max_life": life,
			"r": _rng.randf_range(2.2, 5.4),
			"color": c
		})

func _pick_firework_color() -> Color:
	var palette: Array[Color] = [
		Color("#fbbf24"),
		Color("#f472b6"),
		Color("#60a5fa"),
		Color("#34d399"),
		Color("#f87171")
	]
	return palette[_rng.randi_range(0, palette.size() - 1)]
