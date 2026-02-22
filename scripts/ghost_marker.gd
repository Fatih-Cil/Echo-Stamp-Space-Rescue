extends Node2D
class_name GhostMarker

@export var base_color: Color = Color(0.72, 0.86, 1.0, 0.9)
@export var glow_color: Color = Color(0.45, 0.72, 1.0, 0.35)

var _enabled: bool = false
var _pulse_t: float = 0.0
var _label_text: String = "LAST CRASH"

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	_pulse_t += delta
	if not _enabled:
		return
	queue_redraw()

func set_marker(enabled: bool, world_pos: Vector2, label_text: String = "LAST CRASH") -> void:
	_enabled = enabled
	visible = enabled
	global_position = world_pos
	_label_text = label_text
	if enabled:
		queue_redraw()

func _draw() -> void:
	if not _enabled:
		return
	var pulse: float = 0.78 + 0.22 * sin(_pulse_t * 6.5)
	var halo_r: float = 46.0 + 5.0 * pulse
	draw_circle(Vector2.ZERO, halo_r, Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * pulse))

	# Ground dust ring.
	draw_arc(Vector2.ZERO, 31.0, PI * 0.1, PI * 0.9, 20, Color(0.86, 0.95, 1.0, 0.26), 2.4, true)

	# Tombstone body.
	var stone_rect := Rect2(Vector2(-22.0, -24.0), Vector2(44.0, 54.0))
	draw_rect(stone_rect, Color(0.74, 0.82, 0.96, 0.84), true)
	draw_circle(Vector2(0.0, -24.0), 22.0, Color(0.74, 0.82, 0.96, 0.84))
	draw_rect(Rect2(Vector2(-18.0, -16.0), Vector2(36.0, 42.0)), Color(0.58, 0.67, 0.84, 0.52), true)

	# Crack.
	var crack := PackedVector2Array([
		Vector2(-4.0, -14.0),
		Vector2(3.0, -4.0),
		Vector2(-2.0, 7.0),
		Vector2(5.0, 19.0)
	])
	draw_polyline(crack, Color(0.22, 0.28, 0.44, 0.72), 2.1, true)

	# Tiny cross mark.
	draw_line(Vector2(-8.0, 2.0), Vector2(8.0, 2.0), Color(1.0, 0.88, 0.93, 0.78), 2.0, true)
	draw_line(Vector2(0.0, -6.0), Vector2(0.0, 10.0), Color(1.0, 0.88, 0.93, 0.78), 2.0, true)

	# Floating ghost spark.
	var spark_y := -42.0 + sin(_pulse_t * 3.2) * 4.0
	draw_circle(Vector2(18.0, spark_y), 4.0, Color(0.90, 0.98, 1.0, 0.86))
	draw_circle(Vector2(18.0, spark_y), 9.0, Color(0.66, 0.86, 1.0, 0.24))

	draw_string(
		ThemeDB.fallback_font,
		Vector2(-74.0, -62.0),
		_label_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		148.0,
		17,
		Color(0.86, 0.93, 1.0, 0.9)
	)
