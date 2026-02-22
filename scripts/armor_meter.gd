extends Control
class_name ArmorMeter

@export var max_charges: int = 2
@export var current_charges: int = 2
@export var active_color: Color = Color("#67e8f9")
@export var inactive_color: Color = Color("#334155")

var _pulse_time: float = 0.0
var _pulse_strength: float = 0.0

func _process(delta: float) -> void:
	if _pulse_time > 0.0:
		_pulse_time = maxf(_pulse_time - delta, 0.0)
		queue_redraw()

func set_values(current: int, max_value: int) -> void:
	current_charges = maxi(current, 0)
	max_charges = maxi(max_value, 1)
	queue_redraw()

func play_feedback(increased: bool) -> void:
	_pulse_time = 0.28
	_pulse_strength = 1.0 if increased else 0.7
	queue_redraw()

func _draw() -> void:
	var count: int = maxi(max_charges, 1)
	var spacing: float = 72.0
	var start_x: float = (size.x - spacing * float(count - 1)) * 0.5
	var center_y: float = size.y * 0.54

	var pulse_k: float = 0.0
	if _pulse_time > 0.0:
		pulse_k = (_pulse_time / 0.28) * _pulse_strength

	for i: int in range(count):
		var filled: bool = i < current_charges
		var c: Color = active_color if filled else inactive_color
		var cx: float = start_x + float(i) * spacing
		var r: float = 19.0 + (2.8 * pulse_k if filled else 0.0)
		var p := Vector2(cx, center_y)

		# Outer glow.
		var glow_a: float = 0.26 if filled else 0.08
		draw_circle(p, r * 1.45, Color(c.r, c.g, c.b, glow_a))
		draw_circle(p, r * 1.2, Color(c.r, c.g, c.b, glow_a * 0.7))

		# Shield core and ring.
		draw_circle(p, r * (0.84 if filled else 0.62), Color(c.r, c.g, c.b, 0.24 if filled else 0.08))
		draw_arc(p, r, 0.0, TAU, 40, Color(c.r, c.g, c.b, 0.95 if filled else 0.35), 2.3, true)
		draw_arc(p, r * 0.68, 0.0, TAU, 28, Color(c.r, c.g, c.b, 0.48 if filled else 0.15), 1.4, true)

		# Tiny spark for active charges.
		if filled:
			var t: float = Time.get_ticks_msec() / 1000.0
			var a: float = t * 6.2 + float(i) * 1.3
			var spark := p + Vector2(cos(a), sin(a)) * (r * 0.9)
			draw_circle(spark, 2.5, Color(1.0, 1.0, 1.0, 0.85))
