extends Node2D

@export var unlocked_color: Color = Color("#60a5fa")
@export var locked_color: Color = Color("#f8fafc")
@export var unlocked_width: float = 4.0
@export var locked_width: float = 8.0
@export var min_distance: float = 6.0
@export var comet_tail: bool = true
@export var smoke_glow: bool = true

var _points: Array[Dictionary] = []

func reset_trail(start_position: Vector2) -> void:
	_points.clear()
	_add_point(start_position)
	queue_redraw()

func tick_trail(delta: float, player_position: Vector2, scroll_speed: float) -> void:
	for i: int in range(_points.size()):
		var p: Dictionary = _points[i]
		p["pos"] = p["pos"] + Vector2.LEFT * scroll_speed * delta
		_points[i] = p
	if _points.is_empty() or (_points[_points.size() - 1]["pos"] as Vector2).distance_to(player_position) >= min_distance:
		_add_point(player_position)
	_prune_points()
	queue_redraw()

func stamp_last_window(window_sec: float, now_sec: float) -> bool:
	if _points.is_empty():
		return false
	var changed := false
	for i: int in range(_points.size()):
		var p: Dictionary = _points[i]
		if now_sec - float(p["t"]) <= window_sec:
			if not bool(p["locked"]):
				p["locked"] = true
				_points[i] = p
				changed = true
	if changed:
		queue_redraw()
	return changed

func clear_unlocked() -> void:
	var filtered: Array[Dictionary] = []
	for p: Dictionary in _points:
		if bool(p["locked"]):
			filtered.append(p)
	_points = filtered
	queue_redraw()

func _add_point(pos: Vector2) -> void:
	_points.append({
		"pos": pos,
		"t": Time.get_ticks_msec() / 1000.0,
		"locked": false
	})

func _prune_points() -> void:
	var min_x := -200.0
	while _points.size() > 2 and float((_points[1]["pos"] as Vector2).x) < min_x:
		_points.remove_at(0)

func _draw() -> void:
	if _points.size() < 2:
		return

	var segment_count: int = _points.size() - 1
	for i: int in range(segment_count):
		var a: Dictionary = _points[i]
		var b: Dictionary = _points[i + 1]
		var is_locked := bool(a["locked"]) and bool(b["locked"])
		var t := float(i) / maxf(1.0, float(segment_count - 1))
		var width_scale := 1.0
		var alpha_scale := 1.0
		if comet_tail:
			# Older trail gets thinner/fainter; near player is brighter and thicker.
			width_scale = 0.35 + 0.95 * t
			alpha_scale = 0.22 + 0.78 * t
		var base_color: Color = locked_color if is_locked else unlocked_color
		var draw_color := Color(base_color.r, base_color.g, base_color.b, base_color.a * alpha_scale)
		var draw_width: float = (locked_width if is_locked else unlocked_width) * width_scale
		draw_line(
			a["pos"],
			b["pos"],
			draw_color,
			draw_width,
			true
		)

	if smoke_glow:
		_draw_smoke_glow()

func _draw_smoke_glow() -> void:
	var count: int = mini(_points.size(), 20)
	if count <= 0:
		return
	for i: int in range(count):
		var idx := _points.size() - 1 - i
		var p: Dictionary = _points[idx]
		if bool(p["locked"]):
			continue
		var pos: Vector2 = p["pos"]
		var t := 1.0 - float(i) / maxf(1.0, float(count - 1))
		var radius := 4.0 + 18.0 * t
		var a := 0.02 + 0.12 * t
		var c := Color(unlocked_color.r, unlocked_color.g, unlocked_color.b, a)
		draw_circle(pos, radius, c)
