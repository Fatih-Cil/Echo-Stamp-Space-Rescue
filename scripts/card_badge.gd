extends Control
class_name CardBadge

@export var card_id: String = "trail_neon"
@export var rarity: String = "RARE"
@export var owned: bool = false
@export var equipped: bool = false
@export var title_text: String = "Card"
@export var is_new: bool = false

var _icon_texture: Texture2D

func configure(next_card_id: String, next_title: String, next_rarity: String, is_owned: bool, is_equipped: bool, mark_new: bool = false) -> void:
	card_id = next_card_id
	title_text = next_title
	rarity = next_rarity
	owned = is_owned
	equipped = is_equipped
	is_new = mark_new
	_refresh_icon_texture()
	queue_redraw()

func _ready() -> void:
	_refresh_icon_texture()

func _draw() -> void:
	var sz: Vector2 = size
	if sz.x <= 0.0 or sz.y <= 0.0:
		return

	var image_margin: float = 10.0
	var top_margin: float = 12.0
	var bottom_margin: float = 12.0
	var image_rect: Rect2 = Rect2(
		Vector2(image_margin, top_margin),
		Vector2(sz.x - image_margin * 2.0, sz.y - (top_margin + bottom_margin + 16.0))
	)
	var content_rect: Rect2 = image_rect

	if _icon_texture != null:
		var tex_size: Vector2 = _icon_texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			var scale_x: float = image_rect.size.x / tex_size.x
			var scale_y: float = image_rect.size.y / tex_size.y
			var scale_fit: float = minf(scale_x, scale_y)
			var draw_size: Vector2 = tex_size * scale_fit
			var draw_pos: Vector2 = image_rect.position + (image_rect.size - draw_size) * 0.5
			var fit_rect: Rect2 = Rect2(draw_pos, draw_size)
			content_rect = fit_rect
			draw_texture_rect(_icon_texture, fit_rect, false, Color(1.0, 1.0, 1.0, 1.0 if owned else 0.38))
	else:
		draw_rect(image_rect, Color(0.15, 0.17, 0.23, 0.75), true)

	var title_strip_h: float = 28.0
	var title_rect: Rect2 = Rect2(
		Vector2(image_rect.position.x, image_rect.end.y - title_strip_h),
		Vector2(image_rect.size.x, title_strip_h)
	)
	draw_rect(title_rect, Color(0.04, 0.06, 0.12, 0.68), true)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(title_rect.position.x + 10.0, title_rect.position.y + 20.0),
		title_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		title_rect.size.x - 16.0,
		17,
		Color(0.95, 0.98, 1.0, 1.0 if owned else 0.62)
	)

	if not owned:
		draw_rect(content_rect, Color(0.02, 0.02, 0.03, 0.38), true)
		var locked_y: float = content_rect.position.y + content_rect.size.y * 0.5 + 6.0
		draw_string(
			ThemeDB.fallback_font,
			Vector2(content_rect.position.x, locked_y),
			"LOCKED",
			HORIZONTAL_ALIGNMENT_CENTER,
			content_rect.size.x,
			20,
			Color(1.0, 0.7, 0.7, 0.9)
		)

	if equipped and owned:
		var equipped_rect: Rect2 = Rect2(Vector2(8.0, 8.0), Vector2(sz.x - 16.0, 24.0))
		draw_rect(equipped_rect, Color(0.16, 0.44, 0.90, 0.90), true)
		draw_string(
			ThemeDB.fallback_font,
			Vector2(equipped_rect.position.x + 10.0, equipped_rect.position.y + 18.0),
			"EQUIPPED",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			14,
			Color(0.92, 0.98, 1.0, 1.0)
		)
	elif is_new and owned:
		var new_rect: Rect2 = Rect2(Vector2(8.0, 8.0), Vector2(56.0, 24.0))
		draw_rect(new_rect, Color(0.96, 0.56, 0.2, 0.94), true)
		draw_string(
			ThemeDB.fallback_font,
			Vector2(new_rect.position.x + 8.0, new_rect.position.y + 18.0),
			"NEW",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			14,
			Color(1.0, 0.97, 0.90, 1.0)
		)

func _refresh_icon_texture() -> void:
	var path: String = "res://assets/badges/%s.png" % card_id
	if ResourceLoader.exists(path):
		_icon_texture = load(path) as Texture2D
	else:
		_icon_texture = null
