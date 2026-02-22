extends Node2D
class_name HeartPickup

@export var radius: float = 24.0
@export var suit_color: Color = Color("#dbeafe")
@export var visor_color: Color = Color("#60a5fa")
@export var glow_color: Color = Color("#93c5fd")
@export var attract_x: float = 430.0
@export var attract_range_x: float = 520.0
@export var attract_far_lerp_speed: float = 1.2
@export var attract_near_lerp_speed: float = 7.2
@export var attract_curve: float = 1.6
@export var spin_max_deg: float = 14.0
@export var spin_speed: float = 1.5

enum PickupType {
	STAMP,
	SCORE,
	LIFE,
	BOOST
}

@export var pickup_type: int = PickupType.STAMP

var collected: bool = false
var _pulse_t: float = 0.0
var _spin_phase: float = 0.0
var _spin_phase2: float = 0.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_spin_phase = rng.randf_range(0.0, TAU)
	_spin_phase2 = rng.randf_range(0.0, TAU)
	_apply_type_colors()

func set_pickup_type(next_type: int) -> void:
	pickup_type = clampi(next_type, 0, 3)
	_apply_type_colors()
	queue_redraw()

func get_pickup_type() -> int:
	return pickup_type

func tick_move(delta: float, scroll_speed: float, target_position: Vector2) -> void:
	position.x -= scroll_speed * delta
	var x_dist: float = absf(target_position.x - global_position.x)
	if position.x <= attract_x or x_dist <= attract_range_x:
		var k: float = 1.0 - clampf(x_dist / attract_range_x, 0.0, 1.0)
		k = pow(k, attract_curve)
		var speed: float = lerpf(attract_far_lerp_speed, attract_near_lerp_speed, k)
		position.y = lerpf(position.y, target_position.y, clampf(speed * delta, 0.0, 1.0))
	_pulse_t += delta
	var spin_t: float = _pulse_t * spin_speed
	var rot_wave: float = sin(spin_t + _spin_phase) * 0.72 + sin(spin_t * 0.46 + _spin_phase2) * 0.28
	rotation = deg_to_rad(spin_max_deg) * rot_wave
	queue_redraw()

func try_collect(player_position: Vector2, player_radius: float) -> bool:
	if collected:
		return false
	var hit_dist := radius + player_radius * 1.1 + 4.0
	if global_position.distance_to(player_position) <= hit_dist:
		collected = true
		return true
	return false

func is_offscreen() -> bool:
	return global_position.x < -radius * 2.0

func _draw() -> void:
	var pulse: float = 0.9 + 0.1 * sin(_pulse_t * 7.0)
	var s: float = radius * pulse

	# Soft rescue beacon halo.
	draw_circle(Vector2.ZERO, s * 1.35, Color(glow_color.r, glow_color.g, glow_color.b, 0.14))
	draw_circle(Vector2.ZERO, s * 1.05, Color(glow_color.r, glow_color.g, glow_color.b, 0.2))

	# Helmet.
	var helmet_center := Vector2(0.0, -s * 0.34)
	draw_circle(helmet_center, s * 0.44, suit_color)
	draw_circle(helmet_center, s * 0.30, visor_color)
	draw_circle(helmet_center + Vector2(-s * 0.10, -s * 0.08), s * 0.09, Color(1.0, 1.0, 1.0, 0.34))

	# Torso.
	draw_rect(
		Rect2(Vector2(-s * 0.34, -s * 0.04), Vector2(s * 0.68, s * 0.66)),
		suit_color,
		true
	)

	# Arms.
	draw_rect(
		Rect2(Vector2(-s * 0.58, s * 0.06), Vector2(s * 0.2, s * 0.42)),
		suit_color,
		true
	)
	draw_rect(
		Rect2(Vector2(s * 0.38, s * 0.06), Vector2(s * 0.2, s * 0.42)),
		suit_color,
		true
	)

	# Legs.
	draw_rect(
		Rect2(Vector2(-s * 0.28, s * 0.62), Vector2(s * 0.22, s * 0.34)),
		suit_color,
		true
	)
	draw_rect(
		Rect2(Vector2(s * 0.06, s * 0.62), Vector2(s * 0.22, s * 0.34)),
		suit_color,
		true
	)

	# Tiny booster sparkle.
	var spark_t: float = 0.6 + 0.4 * sin(_pulse_t * 14.0)
	draw_circle(Vector2(0.0, s * 1.04), s * 0.12 * spark_t, Color(0.97, 0.75, 0.35, 0.8))

	# Role marker.
	_draw_pickup_marker(s)

func _draw_pickup_marker(s: float) -> void:
	var center := Vector2(0.0, s * 0.26)
	if pickup_type == PickupType.STAMP:
		var c := Color(0.96, 0.90, 0.55, 0.95)
		draw_rect(Rect2(center + Vector2(-s * 0.12, -s * 0.26), Vector2(s * 0.24, s * 0.52)), c, true)
		draw_rect(Rect2(center + Vector2(-s * 0.26, -s * 0.12), Vector2(s * 0.52, s * 0.24)), c, true)
	elif pickup_type == PickupType.SCORE:
		var pts := PackedVector2Array()
		var outer := s * 0.24
		var inner := s * 0.11
		for i: int in range(10):
			var a := -PI * 0.5 + TAU * float(i) / 10.0
			var r := outer if i % 2 == 0 else inner
			pts.append(center + Vector2(cos(a), sin(a)) * r)
		draw_polygon(pts, PackedColorArray([Color(1.0, 0.95, 0.72, 0.95)]))
	elif pickup_type == PickupType.LIFE:
		var life_color := Color(1.0, 0.78, 0.78, 0.95)
		draw_circle(center + Vector2(-s * 0.09, -s * 0.04), s * 0.11, life_color)
		draw_circle(center + Vector2(s * 0.09, -s * 0.04), s * 0.11, life_color)
		var tri := PackedVector2Array([
			center + Vector2(-s * 0.22, -s * 0.02),
			center + Vector2(s * 0.22, -s * 0.02),
			center + Vector2(0.0, s * 0.22)
		])
		draw_polygon(tri, PackedColorArray([life_color]))
	else:
		var shield_c := Color(0.75, 0.82, 1.0, 0.95)
		draw_arc(center, s * 0.24, 0.0, TAU, 24, shield_c, 2.0, true)
		draw_arc(center, s * 0.16, 0.0, TAU, 18, Color(0.93, 0.97, 1.0, 0.9), 1.4, true)
		draw_circle(center + Vector2(s * 0.22, 0.0), s * 0.04, Color(1.0, 1.0, 1.0, 0.9))

func _apply_type_colors() -> void:
	match pickup_type:
		PickupType.STAMP:
			suit_color = Color("#dbeafe")
			visor_color = Color("#60a5fa")
			glow_color = Color("#93c5fd")
		PickupType.SCORE:
			suit_color = Color("#dcfce7")
			visor_color = Color("#22c55e")
			glow_color = Color("#86efac")
		PickupType.LIFE:
			suit_color = Color("#fee2e2")
			visor_color = Color("#ef4444")
			glow_color = Color("#fca5a5")
		_:
			suit_color = Color("#e0e7ff")
			visor_color = Color("#6366f1")
			glow_color = Color("#a5b4fc")
