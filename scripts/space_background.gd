extends Node2D

@export var star_count: int = 95
@export var min_speed: float = 10.0
@export var max_speed: float = 42.0
@export var min_size: float = 0.9
@export var max_size: float = 2.8

var _stars: Array[Dictionary] = []
var _nebula_clouds: Array[Dictionary] = []
var _asteroids: Array[Dictionary] = []
var _plasma_arcs: Array[Dictionary] = []
var _solar_bands: Array[Dictionary] = []
var _view_size: Vector2 = Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _biome: int = 0

const BIOME_NEBULA: int = 0
const BIOME_ASTEROID_RAIN: int = 1
const BIOME_PLASMA_FIELD: int = 2
const BIOME_SOLAR_STORM: int = 3

func _ready() -> void:
	_rng.randomize()
	_refresh_if_needed()

func set_biome_from_score(score_value: int) -> void:
	var next_biome: int = BIOME_NEBULA
	if score_value >= 61:
		next_biome = BIOME_SOLAR_STORM
	elif score_value >= 41:
		next_biome = BIOME_PLASMA_FIELD
	elif score_value >= 21:
		next_biome = BIOME_ASTEROID_RAIN

	_set_biome(next_biome)

func set_biome_from_level(level_index: int) -> void:
	var idx: int = clampi(level_index, 0, 3)
	var next_biome: int = BIOME_NEBULA
	if idx == 1:
		next_biome = BIOME_ASTEROID_RAIN
	elif idx == 2:
		next_biome = BIOME_PLASMA_FIELD
	elif idx >= 3:
		next_biome = BIOME_SOLAR_STORM

	_set_biome(next_biome)

func _set_biome(next_biome: int) -> void:
	if next_biome == _biome:
		return
	_biome = next_biome
	_regenerate_biome_fx()
	queue_redraw()

func _process(delta: float) -> void:
	_refresh_if_needed()
	if _stars.is_empty():
		return

	var biome_speed_mul: float = 1.0
	if _biome == BIOME_ASTEROID_RAIN:
		biome_speed_mul = 1.18
	elif _biome == BIOME_PLASMA_FIELD:
		biome_speed_mul = 1.1
	elif _biome == BIOME_SOLAR_STORM:
		biome_speed_mul = 1.08

	for i: int in range(_stars.size()):
		var s: Dictionary = _stars[i]
		var pos: Vector2 = s["pos"] as Vector2
		pos.x -= float(s["speed"]) * biome_speed_mul * delta
		if pos.x < -8.0:
			pos.x = _view_size.x + _rng.randf_range(0.0, 18.0)
			pos.y = _rng.randf_range(0.0, _view_size.y)
		s["pos"] = pos
		_stars[i] = s

	_tick_biome_fx(delta)
	queue_redraw()

func _refresh_if_needed() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size != _view_size or _stars.is_empty():
		_view_size = size
		_generate_stars()
		_regenerate_biome_fx()

func _generate_stars() -> void:
	_stars.clear()
	for _i: int in range(star_count):
		var depth: float = _rng.randf_range(0.2, 1.0)
		_stars.append({
			"pos": Vector2(_rng.randf_range(0.0, _view_size.x), _rng.randf_range(0.0, _view_size.y)),
			"speed": lerpf(min_speed, max_speed, depth),
			"size": lerpf(min_size, max_size, depth),
			"alpha": lerpf(0.25, 0.92, depth),
			"twinkle": _rng.randf_range(0.0, TAU)
		})
	queue_redraw()

func _regenerate_biome_fx() -> void:
	_nebula_clouds.clear()
	_asteroids.clear()
	_plasma_arcs.clear()
	_solar_bands.clear()

	for _i: int in range(7):
		_nebula_clouds.append({
			"pos": Vector2(_rng.randf_range(0.0, _view_size.x), _rng.randf_range(0.0, _view_size.y)),
			"r": _rng.randf_range(120.0, 260.0),
			"a": _rng.randf_range(0.03, 0.1),
			"phase": _rng.randf_range(0.0, TAU),
			"drift": _rng.randf_range(3.0, 12.0)
		})

	for _i: int in range(28):
		_asteroids.append({
			"pos": Vector2(_rng.randf_range(-40.0, _view_size.x + 40.0), _rng.randf_range(0.0, _view_size.y)),
			"vel": Vector2(_rng.randf_range(-240.0, -120.0), _rng.randf_range(70.0, 180.0)),
			"size": _rng.randf_range(2.2, 6.2),
			"a": _rng.randf_range(0.25, 0.62)
		})

	for _i: int in range(12):
		_plasma_arcs.append({
			"x": _rng.randf_range(0.0, _view_size.x),
			"y": _rng.randf_range(0.0, _view_size.y),
			"len": _rng.randf_range(40.0, 120.0),
			"amp": _rng.randf_range(8.0, 22.0),
			"phase": _rng.randf_range(0.0, TAU),
			"a": _rng.randf_range(0.2, 0.55),
			"speed": _rng.randf_range(1.2, 2.9)
		})

	for _i: int in range(6):
		_solar_bands.append({
			"y": _rng.randf_range(0.0, _view_size.y),
			"h": _rng.randf_range(46.0, 120.0),
			"phase": _rng.randf_range(0.0, TAU),
			"a": _rng.randf_range(0.05, 0.14),
			"speed": _rng.randf_range(0.5, 1.4)
		})

func _tick_biome_fx(delta: float) -> void:
	if _biome == BIOME_NEBULA:
		for i: int in range(_nebula_clouds.size()):
			var c: Dictionary = _nebula_clouds[i]
			var p: Vector2 = c["pos"] as Vector2
			p.x -= float(c["drift"]) * delta
			if p.x < -260.0:
				p.x = _view_size.x + 260.0
				p.y = _rng.randf_range(0.0, _view_size.y)
			c["pos"] = p
			c["phase"] = float(c["phase"]) + delta * 0.45
			_nebula_clouds[i] = c
	elif _biome == BIOME_ASTEROID_RAIN:
		for i: int in range(_asteroids.size()):
			var a: Dictionary = _asteroids[i]
			var p: Vector2 = a["pos"] as Vector2
			var v: Vector2 = a["vel"] as Vector2
			p += v * delta
			if p.x < -80.0 or p.y > _view_size.y + 80.0:
				p = Vector2(_view_size.x + _rng.randf_range(20.0, 220.0), _rng.randf_range(-120.0, _view_size.y * 0.4))
			a["pos"] = p
			_asteroids[i] = a
	elif _biome == BIOME_PLASMA_FIELD:
		for i: int in range(_plasma_arcs.size()):
			var p: Dictionary = _plasma_arcs[i]
			var x: float = float(p["x"]) - 80.0 * delta
			if x < -180.0:
				x = _view_size.x + _rng.randf_range(0.0, 120.0)
				p["y"] = _rng.randf_range(0.0, _view_size.y)
			p["x"] = x
			p["phase"] = float(p["phase"]) + delta * float(p["speed"]) * 4.0
			_plasma_arcs[i] = p
	elif _biome == BIOME_SOLAR_STORM:
		for i: int in range(_solar_bands.size()):
			var b: Dictionary = _solar_bands[i]
			b["phase"] = float(b["phase"]) + delta * float(b["speed"]) * 2.2
			_solar_bands[i] = b

func _draw() -> void:
	_draw_biome_bg()

	for s: Dictionary in _stars:
		var pos: Vector2 = s["pos"] as Vector2
		var size: float = float(s["size"])
		var alpha: float = float(s["alpha"])
		var twinkle: float = 0.75 + 0.25 * sin(Time.get_ticks_msec() / 1000.0 * 1.8 + float(s["twinkle"]))
		var c := _star_color(alpha * twinkle)
		draw_circle(pos, size, c)

func _draw_biome_bg() -> void:
	if _biome == BIOME_NEBULA:
		for c: Dictionary in _nebula_clouds:
			var pos: Vector2 = c["pos"] as Vector2
			var r: float = float(c["r"])
			var phase: float = float(c["phase"])
			var alpha: float = float(c["a"]) * (0.74 + 0.26 * sin(phase))
			draw_circle(pos, r, Color(0.68, 0.34, 0.86, alpha))
			draw_circle(pos + Vector2(r * 0.22, -r * 0.12), r * 0.64, Color(0.45, 0.56, 0.98, alpha * 0.9))
	elif _biome == BIOME_ASTEROID_RAIN:
		for a: Dictionary in _asteroids:
			var pos: Vector2 = a["pos"] as Vector2
			var size: float = float(a["size"])
			var alpha: float = float(a["a"])
			draw_line(pos + Vector2(10.0, -6.0), pos + Vector2(-14.0, 10.0), Color(0.74, 0.78, 0.86, alpha * 0.35), 2.0, true)
			draw_circle(pos, size, Color(0.82, 0.86, 0.94, alpha))
	elif _biome == BIOME_PLASMA_FIELD:
		for p: Dictionary in _plasma_arcs:
			var x: float = float(p["x"])
			var y: float = float(p["y"])
			var len: float = float(p["len"])
			var amp: float = float(p["amp"])
			var phase: float = float(p["phase"])
			var alpha: float = float(p["a"])
			var pts := PackedVector2Array()
			var segments: int = 12
			for i: int in range(segments + 1):
				var t: float = float(i) / float(segments)
				var px: float = x + len * (t - 0.5)
				var py: float = y + sin(phase + t * TAU * 1.6) * amp
				pts.append(Vector2(px, py))
			draw_polyline(pts, Color(0.55, 0.86, 1.0, alpha), 2.6, true)
			draw_polyline(pts, Color(0.80, 0.56, 1.0, alpha * 0.55), 5.0, true)
	elif _biome == BIOME_SOLAR_STORM:
		var width: float = _view_size.x
		for b: Dictionary in _solar_bands:
			var y: float = float(b["y"])
			var h: float = float(b["h"])
			var phase: float = float(b["phase"])
			var alpha: float = float(b["a"]) * (0.66 + 0.34 * sin(phase))
			draw_rect(Rect2(Vector2(0.0, y - h * 0.5), Vector2(width, h)), Color(0.95, 0.46, 0.2, alpha), true)
			draw_line(Vector2(0.0, y), Vector2(width, y), Color(1.0, 0.86, 0.64, alpha * 1.5), 1.2, true)

func _star_color(alpha: float) -> Color:
	if _biome == BIOME_NEBULA:
		return Color(0.86, 0.92, 1.0, alpha)
	if _biome == BIOME_ASTEROID_RAIN:
		return Color(0.90, 0.93, 0.98, alpha)
	if _biome == BIOME_PLASMA_FIELD:
		return Color(0.72, 0.88, 1.0, alpha)
	return Color(1.0, 0.92, 0.78, alpha)
