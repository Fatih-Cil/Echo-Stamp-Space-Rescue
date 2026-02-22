extends Node2D
class_name FuelPickup

@export var radius: float = 20.0
@export var body_color: Color = Color("#67e8f9")
@export var core_color: Color = Color("#0ea5e9")
@export var attract_x: float = 430.0
@export var attract_range_x: float = 520.0
@export var attract_far_lerp_speed: float = 1.4
@export var attract_near_lerp_speed: float = 6.4
@export var attract_curve: float = 1.45

var collected: bool = false
var _pulse_t: float = 0.0

func tick_move(delta: float, scroll_speed: float, target_position: Vector2) -> void:
	position.x -= scroll_speed * delta
	var x_dist: float = absf(target_position.x - global_position.x)
	if position.x <= attract_x or x_dist <= attract_range_x:
		var k: float = 1.0 - clampf(x_dist / attract_range_x, 0.0, 1.0)
		k = pow(k, attract_curve)
		var speed: float = lerpf(attract_far_lerp_speed, attract_near_lerp_speed, k)
		position.y = lerpf(position.y, target_position.y, clampf(speed * delta, 0.0, 1.0))
	_pulse_t += delta
	queue_redraw()

func try_collect(player_position: Vector2, player_radius: float) -> bool:
	if collected:
		return false
	var hit_dist: float = radius + player_radius + 4.0
	if global_position.distance_to(player_position) <= hit_dist:
		collected = true
		return true
	return false

func is_offscreen() -> bool:
	return global_position.x < -radius * 2.0

func _draw() -> void:
	var pulse: float = 0.9 + 0.1 * sin(_pulse_t * 7.8)
	var r: float = radius * pulse
	draw_circle(Vector2.ZERO, r * 1.35, Color(body_color.r, body_color.g, body_color.b, 0.2))
	draw_rect(Rect2(Vector2(-r * 0.46, -r * 0.72), Vector2(r * 0.92, r * 1.44)), body_color, true)
	draw_rect(Rect2(Vector2(-r * 0.28, -r * 0.46), Vector2(r * 0.56, r * 0.92)), core_color, true)
	draw_rect(Rect2(Vector2(-r * 0.10, -r * 0.92), Vector2(r * 0.2, r * 0.18)), Color(0.88, 0.98, 1.0, 0.9), true)
	draw_circle(Vector2(-r * 0.12, -r * 0.18), r * 0.12, Color(1.0, 1.0, 1.0, 0.34))
