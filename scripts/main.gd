extends Node2D

const SAVE_PATH := "user://save.cfg"
const STAMP_WINDOW_SEC := 0.40
const PERFECT_WINDOW_SEC := 0.10
const PERFECT_STAMP_BONUS := 2
const PERFECT_CHAIN_BONUS_CAP := 3
const STAMP_CHARGES_MAX := 2
const STAMP_REGEN_L1_SEC := 1.8
const STAMP_REGEN_L2_SEC := 2.2
const STAMP_REGEN_L3_SEC := 2.6
const STAMP_REGEN_L4_SEC := 3.0
const SWEEP_STREAK_BONUS_EVERY := 3
const SWEEP_STREAK_BONUS_POINTS := 1
const SCROLL_SPEED := 240.0
const RESTART_DELAY_SEC := 0.2
const DEATH_REVEAL_DELAY_SEC := 0.42
const POST_DEATH_BEST_CELEBRATION_SEC := 3.8
const SFX_POOL_SIZE := 8
const VOICE_POOL_SIZE := 2
const PALETTE_STEP_SCORE := 10
const NEAR_MISS_MARGIN_PX := 20.0
const NEAR_MISS_BONUS := 1
const GOLD_GATE_POINTS := 2
const GOLD_RUSH_DURATION_SEC := 4.5
const GOLD_RUSH_SPAWN_MULT := 0.62
const GOLD_RUSH_COOLDOWN_MIN := 12.0
const GOLD_RUSH_COOLDOWN_MAX := 18.0
const LEVEL_DURATION_SEC := 30.0
const LEVEL_COUNT := 4
const DUPLICATE_SHARD_POINTS := 40
const SCORE_CARD_RARE_MIN := 20
const SCORE_CARD_EPIC_MIN := 45
const SCORE_CARD_LEGEND_MIN := 70
const SCORE_CARD_DUPLICATE_PACK_BONUS := 60
const ASTRONAUT_TYPE_STAMP := 0
const ASTRONAUT_TYPE_SCORE := 1
const ASTRONAUT_TYPE_LIFE := 2
const ASTRONAUT_TYPE_BOOST := 3
const ASTRONAUT_SCORE_BONUS := 2
const EXTRA_LIFE_MAX := 2
const PICKUP_STAMP_WEIGHT := 0.24
const PICKUP_SCORE_WEIGHT := 0.50
const PICKUP_LIFE_WEIGHT := 0.10
const PICKUP_BOOST_WEIGHT := 0.16
const ARMOR_SHIELD_BASE_SEC := 0.25
const ARMOR_SHIELD_BOOST_SEC := 1.5
const ARMOR_BOOST_DURATION_SEC := 8.0
const FUEL_MAX := 100.0
const FUEL_DRAIN_PER_SEC := 4.2
const FUEL_PICKUP_INTERVAL_MIN := 6.0
const FUEL_PICKUP_INTERVAL_MAX := 9.0
const FUEL_PICKUP_LOW50_MIN := 3.6
const FUEL_PICKUP_LOW50_MAX := 5.8
const FUEL_PICKUP_LOW25_MIN := 2.2
const FUEL_PICKUP_LOW25_MAX := 3.6
const LOOP_THREAT_CAP := 0.85
const CARD_TRAIL_DEFAULT := "trail_default"
const CARD_TRAIL_NEON := "trail_neon"
const CARD_TRAIL_SOLAR := "trail_solar"
const CARD_TRAIL_VOID := "trail_void"
const CARD_SCORE_BADGE_RARE := "score_badge_rare"
const CARD_SCORE_BADGE_EPIC := "score_badge_epic"
const CARD_SCORE_BADGE_LEGEND := "score_badge_legend"
const CARD_LOOP_BADGE_I := "loop_badge_i"
const CARD_LOOP_BADGE_II := "loop_badge_ii"
const CARD_LOOP_BADGE_III := "loop_badge_iii"
const PACK_REQ_TIER_1 := 500
const PACK_REQ_TIER_2 := 2500
const PACK_REQ_TIER_3 := 10000

enum GameState {
	READY,
	RUNNING,
	DYING,
	CELEBRATING,
	REWARDING,
	DEAD
}

@onready var world: Node2D = $World
@onready var background: ColorRect = $BgLayer/Background
@onready var space_background: Node = $World/SpaceBackground
@onready var player = $World/Player
@onready var trail = $World/Trail
@onready var rescue_sparkles = $World/RescueSparkles
@onready var sweep = $World/Sweep
@onready var gates_root = $World/Gates
@onready var heart_pickups_root = $World/HeartPickups
@onready var fuel_pickups_root = $World/FuelPickups
@onready var ghost_marker: GhostMarker = $World/GhostMarker

@onready var score_label: Label = $HUDLayer/HUD/Score
@onready var best_label: Label = $HUDLayer/HUD/Best
@onready var streak_label: Label = $HUDLayer/HUD/Streak
@onready var rescue_title_label: Label = $HUDLayer/HUD/RescueTitle
@onready var rescue_label: Label = $HUDLayer/HUD/Rescue
@onready var life_label: Label = $HUDLayer/HUD/Life
@onready var level_label: Label = $HUDLayer/HUD/LevelLabel
@onready var level_timer_label: ProgressBar = $HUDLayer/HUD/LevelTimer
@onready var score_pop_label: Label = $HUDLayer/HUD/ScorePop
@onready var charge_panel: ColorRect = $HUDLayer/HUD/ChargePanel
@onready var charge_hint_label: Label = $HUDLayer/HUD/ChargeHint
@onready var charges_label: ArmorMeter = $HUDLayer/HUD/Charges
@onready var fuel_bar: ProgressBar = $HUDLayer/HUD/FuelBar
@onready var fuel_text: Label = $HUDLayer/HUD/FuelText
@onready var best_celebration: BestCelebration = $HUDLayer/BestCelebration
@onready var status_label: Label = $HUDLayer/Center/Status
@onready var level_banner_label: Label = $HUDLayer/Center/LevelBanner
@onready var best_banner: ColorRect = $HUDLayer/BestBanner
@onready var best_banner_title: Label = $HUDLayer/BestBanner/BestBannerTitle
@onready var best_banner_score: Label = $HUDLayer/BestBanner/BestBannerScore
@onready var settings_button: Button = $HUDLayer/HUD/SettingsButton
@onready var help_button: Button = $HUDLayer/HUD/HelpButton
@onready var album_nav_button: Button = $HUDLayer/HUD/AlbumNavButton
@onready var settings_panel: ColorRect = $HUDLayer/HUD/SettingsPanel
@onready var music_toggle: CheckBox = $HUDLayer/HUD/SettingsPanel/MusicToggle
@onready var music_volume_slider: HSlider = $HUDLayer/HUD/SettingsPanel/MusicVolume
@onready var sfx_toggle: CheckBox = $HUDLayer/HUD/SettingsPanel/SfxToggle
@onready var sfx_volume_slider: HSlider = $HUDLayer/HUD/SettingsPanel/SfxVolume
@onready var settings_close_button: Button = $HUDLayer/HUD/SettingsPanel/CloseSettings
@onready var help_panel: ColorRect = $HUDLayer/HUD/HelpPanel
@onready var help_close_button: Button = $HUDLayer/HUD/HelpPanel/CloseHelp
@onready var death_card: ColorRect = $HUDLayer/HUD/DeathCard
@onready var death_title_label: Label = $HUDLayer/HUD/DeathCard/DeathTitle
@onready var death_reason_label: Label = $HUDLayer/HUD/DeathCard/DeathReason
@onready var death_score_label: Label = $HUDLayer/HUD/DeathCard/DeathScore
@onready var death_best_label: Label = $HUDLayer/HUD/DeathCard/DeathBest
@onready var death_perfect_label: Label = $HUDLayer/HUD/DeathCard/DeathPerfect
@onready var death_loop_label: Label = $HUDLayer/HUD/DeathCard/DeathLoop
@onready var death_pack_label: Label = $HUDLayer/HUD/DeathCard/DeathPack
@onready var death_pack_bar: ProgressBar = $HUDLayer/HUD/DeathCard/DeathPackBar
@onready var open_pack_button: Button = $HUDLayer/HUD/DeathCard/OpenPackButton
@onready var album_button: Button = $HUDLayer/HUD/DeathCard/AlbumButton
@onready var pack_result_panel: ColorRect = $HUDLayer/HUD/PackResultPanel
@onready var pack_result_title: Label = $HUDLayer/HUD/PackResultPanel/PackResultTitle
@onready var pack_result_name: Label = $HUDLayer/HUD/PackResultPanel/PackResultName
@onready var pack_result_desc: Label = $HUDLayer/HUD/PackResultPanel/PackResultDesc
@onready var pack_result_rarity: Label = $HUDLayer/HUD/PackResultPanel/PackResultRarity
@onready var pack_result_badge: CardBadge = $HUDLayer/HUD/PackResultPanel/PackResultBadge
@onready var pack_result_equip: Button = $HUDLayer/HUD/PackResultPanel/EquipButton
@onready var pack_result_close: Button = $HUDLayer/HUD/PackResultPanel/ClosePackResult
@onready var album_panel: ColorRect = $HUDLayer/HUD/AlbumPanel
@onready var album_badge_neon: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeNeon
@onready var album_badge_solar: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeSolar
@onready var album_badge_void: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeVoid
@onready var album_badge_score_rare: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeScoreRare
@onready var album_badge_score_epic: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeScoreEpic
@onready var album_badge_score_legend: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeScoreLegend
@onready var album_badge_loop_i: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeLoopI
@onready var album_badge_loop_ii: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeLoopII
@onready var album_badge_loop_iii: CardBadge = $HUDLayer/HUD/AlbumPanel/BadgeLoopIII
@onready var album_close: Button = $HUDLayer/HUD/AlbumPanel/CloseAlbum
@onready var badge_unlock_panel: ColorRect = $HUDLayer/BadgeUnlockPanel
@onready var badge_unlock_title: Label = $HUDLayer/BadgeUnlockPanel/BadgeUnlockTitle
@onready var badge_unlock_name: Label = $HUDLayer/BadgeUnlockPanel/BadgeUnlockName
@onready var badge_unlock_badge: CardBadge = $HUDLayer/BadgeUnlockPanel/BadgeUnlockBadge
@onready var badge_unlock_close: Button = $HUDLayer/BadgeUnlockPanel/BadgeUnlockClose
@onready var flash_rect: ColorRect = $HUDLayer/HUD/Flash

var _state: GameState = GameState.READY
var _score: int = 0
var _best_score: int = 0
var _charges: int = STAMP_CHARGES_MAX
var _regen_timer: float = 0.0
var _gate_timer: float = 0.0
var _heart_timer: float = 0.0
var _heart_next_interval: float = 7.5
var _fuel_timer: float = 0.0
var _fuel_next_interval: float = 8.5
var _fuel: float = FUEL_MAX
var _level_index: int = 0
var _loop_index: int = 1
var _level_time_left: float = LEVEL_DURATION_SEC
var _level_configs: Array[Dictionary] = []
var _run_distance: float = 0.0
var _last_death_distance: float = -1.0
var _last_death_y: float = 0.0
var _current_gate_spacing: float = 420.0
var _current_heart_interval_min: float = 6.0
var _current_heart_interval_max: float = 10.0
var _current_regen_mul: float = 1.0
var _dead_time: float = 0.0
var _dying_time: float = 0.0
var _post_best_time: float = 0.0
var _last_stamp_time: float = -1000.0
var _prev_charges: int = STAMP_CHARGES_MAX
var _sweep_streak: int = 0
var _perfect_count: int = 0
var _perfect_chain: int = 0
var _rescued_count: int = 0
var _rescue_combo: int = 0
var _best_rescue_combo: int = 0
var _extra_lives: int = 0
var _armor_boost_time_left: float = 0.0
var _best_at_run_start: int = 0
var _best_celebrated_run: bool = false
var _run_hit_new_best: bool = false
var _pack_progress: int = 0
var _packs_unopened: int = 0
var _packs_earned_last_run: int = 0
var _auto_pack_reward_text: String = ""
var _owned_cards: PackedStringArray = PackedStringArray()
var _equipped_trail_card: String = CARD_TRAIL_DEFAULT
var _last_drawn_card_id: String = ""
var _score_card_reward_text: String = ""
var _card_defs: Dictionary = {}
var _card_order: PackedStringArray = PackedStringArray()
var _pack_card_order: PackedStringArray = PackedStringArray()
var _new_cards_session: PackedStringArray = PackedStringArray()
var _unlock_queue: Array[String] = []
var _unlock_showing: bool = false
var _death_reason: String = "DEAD"
var _gold_rush_active: bool = false
var _gold_rush_time_left: float = 0.0
var _gold_rush_cooldown_left: float = 0.0

var _charge_tween: Tween
var _score_pop_tween: Tween
var _flash_tween: Tween
var _charge_glow_tween: Tween
var _level_banner_tween: Tween
var _badge_unlock_tween: Tween
var _pack_result_tween: Tween

var _shake_time: float = 0.0
var _shake_duration: float = 0.0
var _shake_strength: float = 0.0
var _rng := RandomNumberGenerator.new()
var _sfx_players: Array[AudioStreamPlayer] = []
var _voice_players: Array[AudioStreamPlayer] = []
var _voice_streams: Dictionary = {}
var _music_player: AudioStreamPlayer
var _music_playback: AudioStreamGeneratorPlayback
var _music_phase: float = 0.0
var _music_time: float = 0.0
var _music_mix_rate: float = 44100.0
var _music_enabled: bool = false
var _sfx_enabled: bool = true
var _music_volume_db: float = -12.0
var _sfx_volume_db: float = -8.0
var _settings_open: bool = false

func _ready() -> void:
	_rng.randomize()
	_level_configs = _build_level_configs()
	_setup_card_defs()
	_setup_sfx_pool()
	_setup_voice_pool()
	_load_voice_streams()
	_setup_music_player()
	_connect_settings_ui()
	_load_audio_settings()
	_apply_audio_settings_to_ui()
	_apply_audio_settings()
	sweep.connect("sweep_triggered", _on_sweep_triggered)
	sweep.connect("warning_started", _on_sweep_warning_started)
	_reset_run(true)

func _process(delta: float) -> void:
	var view_size := get_viewport_rect().size
	background.size = view_size
	_update_music()
	_tick_unlock_banner(delta)
	if _is_overlay_open():
		world.position = Vector2.ZERO
		return
	_update_shake(delta)

	if _state == GameState.RUNNING:
		_run_distance += SCROLL_SPEED * delta
		player.tick_motion(delta)
		_update_player_shield_visual()
		trail.tick_trail(delta, player.get_trail_origin_global(), SCROLL_SPEED)
		rescue_sparkles.tick_sparkles(delta, SCROLL_SPEED)
		var sweep_min_y: float = player.base_y - player.amplitude
		var sweep_max_y: float = player.base_y + player.amplitude
		var predicted_y: float = player.predict_y(sweep.warning_sec)
		sweep.set_target_window(predicted_y, sweep_min_y, sweep_max_y)
		sweep.tick_sweep(delta, view_size, true)
		_tick_charges(delta)
		if _tick_fuel(delta):
			return
		_tick_level_progress(delta)
		_tick_gates(delta, view_size)
		_tick_heart_pickups(delta, view_size)
		_tick_fuel_pickups(delta, view_size)
		_update_ghost_marker(view_size)
		_apply_run_palette()
		_update_hud()
	elif _state == GameState.DEAD:
		player.set_shield_active(false)
		sweep.tick_sweep(delta, view_size, false)
		_dead_time += delta
	elif _state == GameState.DYING:
		player.set_shield_active(false)
		sweep.tick_sweep(delta, view_size, false)
		_dying_time += delta
		if player.tick_explosion(delta) and _dying_time >= DEATH_REVEAL_DELAY_SEC:
			if _run_hit_new_best:
				_enter_post_death_best_celebration()
			else:
				_enter_dead_state()
	elif _state == GameState.CELEBRATING:
		player.set_shield_active(false)
		sweep.tick_sweep(delta, view_size, false)
		_post_best_time = maxf(_post_best_time - delta, 0.0)
		if _post_best_time <= 0.0:
			_enter_dead_state()
	elif _state == GameState.REWARDING:
		player.set_shield_active(false)
		sweep.tick_sweep(delta, view_size, false)
		if not _unlock_showing and _unlock_queue.is_empty():
			_enter_dead_state_ui()
	else:
		player.set_shield_active(false)
		sweep.tick_sweep(delta, view_size, false)
		ghost_marker.set_marker(false, Vector2.ZERO)

func _input(event: InputEvent) -> void:
	var pointer_pos := Vector2.ZERO
	var has_pointer := false
	if event is InputEventMouseButton:
		pointer_pos = event.position
		has_pointer = true
	elif event is InputEventScreenTouch:
		pointer_pos = event.position
		has_pointer = true

	if has_pointer:
		if settings_button.get_global_rect().has_point(pointer_pos):
			return
		if help_button.get_global_rect().has_point(pointer_pos):
			return
		if album_nav_button.get_global_rect().has_point(pointer_pos):
			return
		if settings_panel.visible and settings_panel.get_global_rect().has_point(pointer_pos):
			return
		if help_panel.visible and help_panel.get_global_rect().has_point(pointer_pos):
			return
		if pack_result_panel.visible and pack_result_panel.get_global_rect().has_point(pointer_pos):
			return
		if album_panel.visible and album_panel.get_global_rect().has_point(pointer_pos):
			return
		if _state == GameState.DEAD and death_card.visible and death_card.get_global_rect().has_point(pointer_pos):
			return

	if _is_overlay_open():
		return

	var is_tap := false
	if event.is_action_pressed("tap"):
		is_tap = true
	elif event is InputEventMouseButton:
		is_tap = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		is_tap = event.pressed

	if not is_tap:
		return

	if _state == GameState.READY:
		_start_run()
		return

	if _state == GameState.DEAD:
		if _dead_time >= RESTART_DELAY_SEC:
			_reset_run(false)
			_start_run()
		return
	if _state == GameState.DYING or _state == GameState.CELEBRATING or _state == GameState.REWARDING:
		return

	if _charges <= 0:
		_play_dry_sfx()
		return

	_charges -= 1
	_regen_timer = 0.0
	_last_stamp_time = Time.get_ticks_msec() / 1000.0
	trail.stamp_last_window(STAMP_WINDOW_SEC, _last_stamp_time)
	_play_stamp_sfx()
	_try_perfect_stamp()
	_update_hud()

func _start_run() -> void:
	_state = GameState.RUNNING
	status_label.text = ""
	level_banner_label.visible = false
	level_banner_label.modulate.a = 0.0
	_set_best_banner(false, 0)
	death_card.visible = false
	_set_pack_result_open(false)
	_set_album_open(false)
	_set_settings_open(false)
	_set_help_open(false)
	sweep.reset_sweep(get_viewport_rect().size)
	_apply_level_difficulty()
	_play_start_sfx()

func _reset_run(is_initial: bool) -> void:
	_clear_gates()
	_state = GameState.READY
	_score = 0
	_charges = STAMP_CHARGES_MAX
	_regen_timer = 0.0
	_gate_timer = 0.0
	_heart_timer = 0.0
	_fuel_timer = 0.0
	_level_index = 0
	_loop_index = 1
	_level_time_left = LEVEL_DURATION_SEC
	_run_distance = 0.0
	_last_death_y = player.base_y
	_current_gate_spacing = 420.0
	_current_heart_interval_min = 6.0
	_current_heart_interval_max = 10.0
	_current_regen_mul = 1.0
	_heart_next_interval = randf_range(_current_heart_interval_min, _current_heart_interval_max)
	_fuel_next_interval = _roll_fuel_interval()
	_fuel = FUEL_MAX
	_dead_time = 0.0
	_dying_time = 0.0
	_post_best_time = 0.0
	_last_stamp_time = -1000.0
	_prev_charges = _charges
	_sweep_streak = 0
	_perfect_count = 0
	_perfect_chain = 0
	_rescued_count = 0
	_rescue_combo = 0
	_best_rescue_combo = 0
	_extra_lives = 0
	_armor_boost_time_left = 0.0
	_best_celebrated_run = false
	_run_hit_new_best = false
	_packs_earned_last_run = 0
	_auto_pack_reward_text = ""
	_score_card_reward_text = ""
	_unlock_queue.clear()
	_unlock_showing = false
	_death_reason = "DEAD"
	_gold_rush_active = false
	_gold_rush_time_left = 0.0
	_gold_rush_cooldown_left = randf_range(GOLD_RUSH_COOLDOWN_MIN, GOLD_RUSH_COOLDOWN_MAX)
	_load_best_score_if_needed()
	_load_meta_progress_if_needed()
	_best_at_run_start = _best_score
	player.reset_player(_rng.randf())
	trail.reset_trail(player.get_trail_origin_global())
	rescue_sparkles.clear_sparkles()
	best_celebration.clear_effect()
	_set_best_banner(false, 0)
	sweep.reset_sweep(get_viewport_rect().size)
	_apply_level_difficulty()
	status_label.text = "Tap to Start\nRescue Astronauts" if is_initial else ""
	death_card.visible = false
	_set_pack_result_open(false)
	_set_album_open(false)
	_set_settings_open(false)
	_set_help_open(false)
	_set_badge_unlock_visible(false)
	flash_rect.color = Color(1.0, 0.2745, 0.3569, 0.0)
	world.position = Vector2.ZERO
	_apply_run_palette()
	_apply_equipped_trail_skin()
	_update_ghost_marker(get_viewport_rect().size)
	_update_hud()

func _tick_charges(delta: float) -> void:
	if _armor_boost_time_left > 0.0:
		_armor_boost_time_left = maxf(_armor_boost_time_left - delta, 0.0)
	if _charges >= STAMP_CHARGES_MAX:
		return
	_regen_timer += delta
	var regen_sec: float = _current_regen_sec() * _current_regen_mul
	while _regen_timer >= regen_sec and _charges < STAMP_CHARGES_MAX:
		_regen_timer -= regen_sec
		_charges += 1
		_play_regen_sfx()
		regen_sec = _current_regen_sec() * _current_regen_mul

func _tick_fuel(delta: float) -> bool:
	_fuel = maxf(_fuel - FUEL_DRAIN_PER_SEC * delta, 0.0)
	if _fuel <= 0.0 and _state == GameState.RUNNING:
		_kill_player("OUT OF FUEL")
		return true
	return false

func _tick_level_progress(delta: float) -> void:
	_level_time_left = maxf(_level_time_left - delta, 0.0)
	if _level_time_left > 0.0:
		return

	_advance_level()

func _advance_level() -> void:
	var completed_level: int = _level_index
	if _level_index >= LEVEL_COUNT - 1:
		_level_index = 0
		_loop_index += 1
		_award_loop_badge_for_loop(_loop_index)
		_show_level_banner("LOOP %d" % _loop_index, Color("#fbbf24"))
	else:
		_level_index += 1
		_show_level_banner("LEVEL %d\n%s" % [_level_index + 1, _level_name(_level_index)], Color("#93c5fd"))

	_level_time_left = LEVEL_DURATION_SEC
	_fuel = FUEL_MAX
	_fuel_next_interval = _roll_fuel_interval()
	_apply_level_difficulty()

	# Small clear reward to reinforce progression rhythm.
	if completed_level == LEVEL_COUNT - 1:
		_add_score(3, "LOOP CLEAR +3", Color("#fbbf24"))
	else:
		_add_score(1, "LEVEL +1", Color("#86efac"))

func _apply_level_difficulty() -> void:
	if _level_configs.is_empty():
		return
	var cfg: Dictionary = _level_configs[_level_index]
	var loop_factor: float = float(maxi(_loop_index - 1, 0))
	var interval_base: float = float(cfg["sweep_interval"])
	var warning_base: float = float(cfg["warning"])
	var threat_base: float = float(cfg["threat"])
	var gate_base: float = float(cfg["gate_spacing"])
	var pickup_min_base: float = float(cfg["pickup_min"])
	var pickup_max_base: float = float(cfg["pickup_max"])
	var regen_mul_base: float = float(cfg["regen_mul"])
	var biome_id: int = int(cfg["biome"])

	sweep.interval_sec = maxf(interval_base * (1.0 - 0.06 * loop_factor), 1.55)
	sweep.warning_sec = maxf(warning_base * (1.0 - 0.04 * loop_factor), 0.45)
	sweep.threat_probability = minf(threat_base + 0.03 * loop_factor, LOOP_THREAT_CAP)
	sweep.target_jitter = clampf(36.0 + 5.0 * loop_factor, 36.0, 64.0)
	sweep.safe_offset = maxf(130.0 - 6.0 * loop_factor, 88.0)

	_current_gate_spacing = maxf(gate_base * (1.0 - 0.05 * loop_factor), 300.0)
	_current_heart_interval_min = pickup_min_base + 0.25 * loop_factor
	_current_heart_interval_max = pickup_max_base + 0.35 * loop_factor
	_current_regen_mul = minf(regen_mul_base + 0.08 * loop_factor, 1.55)
	_heart_next_interval = randf_range(_current_heart_interval_min, _current_heart_interval_max)
	player.frequency_hz = _current_player_frequency_hz()

	space_background.call("set_biome_from_level", biome_id)

func _current_player_frequency_hz() -> float:
	var base_freq: float = 0.45
	var step: float = 0.05
	var max_freq: float = 0.60
	var loop_steps: int = maxi(_loop_index - 1, 0)
	return minf(base_freq + step * float(loop_steps), max_freq)

func _build_level_configs() -> Array[Dictionary]:
	return [
		{
			"biome": 0,
			"sweep_interval": 2.9,
			"warning": 0.90,
			"threat": 0.55,
			"gate_spacing": 430.0,
			"pickup_min": 6.0,
			"pickup_max": 9.0,
			"regen_mul": 1.00
		},
		{
			"biome": 1,
			"sweep_interval": 2.6,
			"warning": 0.80,
			"threat": 0.64,
			"gate_spacing": 410.0,
			"pickup_min": 6.5,
			"pickup_max": 10.0,
			"regen_mul": 1.08
		},
		{
			"biome": 2,
			"sweep_interval": 2.35,
			"warning": 0.70,
			"threat": 0.73,
			"gate_spacing": 390.0,
			"pickup_min": 7.0,
			"pickup_max": 11.0,
			"regen_mul": 1.16
		},
		{
			"biome": 3,
			"sweep_interval": 2.1,
			"warning": 0.60,
			"threat": 0.82,
			"gate_spacing": 370.0,
			"pickup_min": 8.0,
			"pickup_max": 12.0,
			"regen_mul": 1.24
		}
	]

func _level_name(level_idx: int) -> String:
	match level_idx:
		0:
			return "NEBULA"
		1:
			return "ASTEROID"
		2:
			return "PLASMA"
		_:
			return "SOLAR"

func _tick_gates(delta: float, view_size: Vector2) -> void:
	_tick_gold_rush(delta)
	_gate_timer += delta
	var spawn_interval := (_current_gate_spacing / SCROLL_SPEED) * (GOLD_RUSH_SPAWN_MULT if _gold_rush_active else 1.0)
	if _gate_timer >= spawn_interval:
		_gate_timer -= spawn_interval
		_spawn_gate(view_size)

	for gate in gates_root.get_children():
		gate.tick_move(delta, SCROLL_SPEED)
		if gate.try_score(player.global_position):
			var points: int = int(gate.get_meta("points", 1))
			gate.play_score_burst(points >= GOLD_GATE_POINTS)
			if points >= GOLD_GATE_POINTS:
				_add_score(points, "GOLD +%d" % points, Color("#fbbf24"))
				_play_gold_gate_sfx()
				_trigger_shake(6.0, 0.10)
			else:
				_add_score(1, "+1", Color("#32d17e"))
		if gate.is_offscreen():
			gate.queue_free()

func _tick_heart_pickups(delta: float, view_size: Vector2) -> void:
	_heart_timer += delta
	if _heart_timer >= _heart_next_interval:
		_heart_timer = 0.0
		_heart_next_interval = randf_range(_current_heart_interval_min, _current_heart_interval_max)
		_spawn_heart_pickup(view_size)

	for heart_node in heart_pickups_root.get_children():
		var heart: HeartPickup = heart_node as HeartPickup
		if heart == null:
			continue
		heart.tick_move(delta, SCROLL_SPEED, player.global_position)
		if heart.try_collect(player.global_position, player.radius):
			var pickup_type: int = heart.get_pickup_type()
			_rescued_count += 1
			_rescue_combo += 1
			_best_rescue_combo = maxi(_best_rescue_combo, _rescue_combo)
			var combo_bonus: int = mini(maxi(_rescue_combo - 1, 0), 3)
			rescue_sparkles.emit_burst(player.get_trail_origin_global(), player.global_rotation, 18)
			_play_heart_pickup_sfx()
			if pickup_type == ASTRONAUT_TYPE_STAMP:
				_charges = mini(_charges + 1, STAMP_CHARGES_MAX)
				_play_score_pop_with("+1 ARMOR", Color("#93c5fd"))
			elif pickup_type == ASTRONAUT_TYPE_SCORE:
				_add_score(ASTRONAUT_SCORE_BONUS, "ASTRO +%d" % ASTRONAUT_SCORE_BONUS, Color("#34d399"))
			elif pickup_type == ASTRONAUT_TYPE_LIFE:
				_extra_lives = mini(_extra_lives + 1, EXTRA_LIFE_MAX)
				_play_score_pop_with("+1 LIFE", Color("#fca5a5"))
			else:
				_charges = mini(_charges + 1, STAMP_CHARGES_MAX)
				_armor_boost_time_left = ARMOR_BOOST_DURATION_SEC
				_play_score_pop_with("ARMOR BOOST!", Color("#a5b4fc"))
			if combo_bonus > 0:
				_add_score(combo_bonus, "RESCUE x%d +%d" % [_rescue_combo, combo_bonus], Color("#93c5fd"))
				_play_streak_sfx()
			heart.queue_free()
			continue
		if heart.is_offscreen():
			_break_rescue_combo()
			heart.queue_free()

func _tick_fuel_pickups(delta: float, view_size: Vector2) -> void:
	_fuel_timer += delta
	if _fuel_timer >= _fuel_next_interval:
		_fuel_timer = 0.0
		_fuel_next_interval = _roll_fuel_interval()
		_spawn_fuel_pickup(view_size)

	for fuel_node in fuel_pickups_root.get_children():
		var fuel_pickup: FuelPickup = fuel_node as FuelPickup
		if fuel_pickup == null:
			continue
		fuel_pickup.tick_move(delta, SCROLL_SPEED, player.global_position)
		if fuel_pickup.try_collect(player.global_position, player.radius):
			var fuel_add: float = _current_fuel_pickup_add()
			_fuel = minf(_fuel + fuel_add, FUEL_MAX)
			_play_fuel_pickup_sfx()
			_play_score_pop_with("FUEL +%d" % int(fuel_add), Color("#67e8f9"))
			_fuel_next_interval = _roll_fuel_interval()
			fuel_pickup.queue_free()
			continue
		if fuel_pickup.is_offscreen():
			fuel_pickup.queue_free()

func _spawn_heart_pickup(view_size: Vector2) -> void:
	var scene := preload("res://scenes/HeartPickup.tscn")
	var heart: HeartPickup = scene.instantiate() as HeartPickup
	if heart == null:
		return
	heart.set_pickup_type(_roll_astronaut_type())
	var min_y: float = player.base_y - player.amplitude + 35.0
	var max_y: float = player.base_y + player.amplitude - 35.0
	var predicted_y: float = player.predict_y(1.15)
	var spawn_y := clampf(predicted_y + randf_range(-115.0, 115.0), min_y, max_y)
	heart.position = Vector2(view_size.x + 120.0, spawn_y)
	heart_pickups_root.add_child(heart)

func _spawn_fuel_pickup(view_size: Vector2) -> void:
	var scene := preload("res://scenes/FuelPickup.tscn")
	var fuel_pickup: FuelPickup = scene.instantiate() as FuelPickup
	if fuel_pickup == null:
		return
	_configure_fuel_pickup_for_level(fuel_pickup)
	var min_y: float = player.base_y - player.amplitude + 40.0
	var max_y: float = player.base_y + player.amplitude - 40.0
	var predicted_y: float = player.predict_y(1.0)
	var spawn_y: float = clampf(predicted_y + randf_range(-130.0, 130.0), min_y, max_y)
	fuel_pickup.position = Vector2(view_size.x + 130.0, spawn_y)
	fuel_pickups_root.add_child(fuel_pickup)

func _configure_fuel_pickup_for_level(fuel_pickup: FuelPickup) -> void:
	match _level_index:
		0:
			# Level 1: strongest assist so early progression feels fair.
			fuel_pickup.attract_x = 520.0
			fuel_pickup.attract_range_x = 700.0
			fuel_pickup.attract_far_lerp_speed = 2.4
			fuel_pickup.attract_near_lerp_speed = 10.0
			fuel_pickup.attract_curve = 1.10
		1:
			fuel_pickup.attract_x = 490.0
			fuel_pickup.attract_range_x = 640.0
			fuel_pickup.attract_far_lerp_speed = 2.0
			fuel_pickup.attract_near_lerp_speed = 8.6
			fuel_pickup.attract_curve = 1.25
		2:
			fuel_pickup.attract_x = 460.0
			fuel_pickup.attract_range_x = 580.0
			fuel_pickup.attract_far_lerp_speed = 1.7
			fuel_pickup.attract_near_lerp_speed = 7.4
			fuel_pickup.attract_curve = 1.35
		_:
			# Level 4: keep original baseline behavior.
			fuel_pickup.attract_x = 430.0
			fuel_pickup.attract_range_x = 520.0
			fuel_pickup.attract_far_lerp_speed = 1.4
			fuel_pickup.attract_near_lerp_speed = 6.4
			fuel_pickup.attract_curve = 1.45

func _roll_fuel_interval() -> float:
	var ratio: float = _fuel / FUEL_MAX
	if ratio <= 0.25:
		return randf_range(FUEL_PICKUP_LOW25_MIN, FUEL_PICKUP_LOW25_MAX)
	if ratio <= 0.50:
		return randf_range(FUEL_PICKUP_LOW50_MIN, FUEL_PICKUP_LOW50_MAX)
	return randf_range(FUEL_PICKUP_INTERVAL_MIN, FUEL_PICKUP_INTERVAL_MAX)

func _current_fuel_pickup_add() -> float:
	match _level_index:
		0:
			return 40.0
		1:
			return 38.0
		2:
			return 36.0
		_:
			return 34.0

func _spawn_gate(view_size: Vector2) -> void:
	var gate_scene := preload("res://scenes/Gate.tscn")
	var gate := gate_scene.instantiate()
	var min_y: float = player.base_y - player.amplitude + 70.0
	var max_y: float = player.base_y + player.amplitude - 70.0
	gate.position = Vector2(view_size.x + 100.0, randf_range(min_y, max_y))
	if _gold_rush_active:
		gate.set_meta("points", GOLD_GATE_POINTS)
		gate.fill_color = Color("#f59e0b")
		gate.stroke_color = Color("#fef3c7")
	else:
		gate.set_meta("points", 1)
		var colors: Array[Color] = _current_gate_colors()
		gate.fill_color = colors[0]
		gate.stroke_color = colors[1]
	gates_root.add_child(gate)

func _on_sweep_warning_started(_target_y: float) -> void:
	if _state != GameState.RUNNING:
		return
	_play_warning_sfx()
	_play_charge_warning_glow()

func _on_sweep_triggered(_target_y: float) -> void:
	trail.clear_unlocked()
	if _state != GameState.RUNNING:
		return

	var hit_player: bool = sweep.overlaps_y(player.global_position.y)
	_play_sweep_flash(hit_player)
	if not hit_player:
		_check_near_miss_bonus()
	if hit_player and _has_active_stamp_shield():
		_play_shield_sfx()
		_trigger_shake(7.0, 0.12)
	if hit_player and not _has_active_stamp_shield():
		if _try_consume_extra_life():
			_register_survived_sweep()
			return
		_kill_player("DEAD")
		return
	_register_survived_sweep()

func _has_active_stamp_shield() -> bool:
	return (Time.get_ticks_msec() / 1000.0) - _last_stamp_time <= _current_shield_window_sec()

func _update_player_shield_visual() -> void:
	var elapsed: float = (Time.get_ticks_msec() / 1000.0) - _last_stamp_time
	var window_sec: float = _current_shield_window_sec()
	if elapsed > window_sec:
		player.set_shield_active(false)
		return
	var strength := 1.0 - clampf(elapsed / window_sec, 0.0, 1.0)
	player.set_shield_active(true, strength)

func _kill_player(reason: String = "DEAD") -> void:
	_state = GameState.DYING
	_death_reason = reason
	_dying_time = 0.0
	_dead_time = 0.0
	player.start_death_explosion()
	_commit_pack_progress(_score)
	_award_score_card_from_run(_score)
	_last_death_distance = _run_distance
	_last_death_y = player.global_position.y
	_save_meta_progress()
	if _score > _best_score:
		_best_score = _score
		_save_best_score()
	death_card.visible = false
	_play_death_sfx()
	_play_death_flash()
	_trigger_shake(16.0, 0.24)
	_update_hud()

func _enter_post_death_best_celebration() -> void:
	_state = GameState.CELEBRATING
	_post_best_time = POST_DEATH_BEST_CELEBRATION_SEC
	death_card.visible = false
	status_label.text = ""
	_set_best_banner(true, _score)
	best_celebration.trigger_fullscreen_celebration()
	_play_best_break_sfx()
	_trigger_shake(12.0, 0.26)

func _enter_dead_state() -> void:
	_auto_claim_run_packs()
	_set_best_banner(false, 0)
	status_label.text = ""
	if not _unlock_queue.is_empty():
		_state = GameState.REWARDING
		_dead_time = 0.0
		death_card.visible = false
		return
	_enter_dead_state_ui()

func _enter_dead_state_ui() -> void:
	_state = GameState.DEAD
	_dead_time = 0.0
	status_label.text = ""
	_set_best_banner(false, 0)
	death_title_label.text = "DEAD"
	death_reason_label.visible = _death_reason != "DEAD"
	death_reason_label.text = _death_reason
	death_score_label.text = "Score: %d" % _score
	death_best_label.text = "Best: %d" % _best_score
	death_perfect_label.text = "Perfect: %d   Rescue: %d\nR.Combo: %d" % [_perfect_count, _rescued_count, _best_rescue_combo]
	death_loop_label.text = "Loop: %d   Level: %d" % [_loop_index, _level_index + 1]
	var req: int = _current_pack_points_required()
	if _packs_earned_last_run > 0:
		death_pack_label.text = "Next Pack: %d/%d   (+%d RUN PACK)" % [_pack_progress, req, _packs_earned_last_run]
	else:
		death_pack_label.text = "Next Pack: %d/%d" % [_pack_progress, req]
	death_pack_bar.max_value = float(req)
	death_pack_bar.value = float(_pack_progress)
	open_pack_button.visible = _packs_unopened > 0
	open_pack_button.disabled = _packs_unopened <= 0
	open_pack_button.text = "Open Pack (%d)" % _packs_unopened
	death_card.visible = true

func _auto_claim_run_packs() -> void:
	_auto_pack_reward_text = ""
	var auto_claim_count: int = mini(_packs_earned_last_run, _packs_unopened)
	if auto_claim_count <= 0:
		return
	var new_names: PackedStringArray = PackedStringArray()
	var duplicate_count: int = 0
	for _i: int in range(auto_claim_count):
		var result: Dictionary = _claim_one_pack_silent()
		if result.is_empty():
			continue
		var is_new: bool = bool(result.get("is_new", false))
		var name: String = str(result.get("name", "Card"))
		if is_new:
			new_names.append(name)
		else:
			duplicate_count += 1
	_save_meta_progress()
	if not new_names.is_empty():
		_auto_pack_reward_text = "Auto Pack Reward: %s" % ", ".join(new_names)
	if duplicate_count > 0:
		var dup_text: String = "Auto Pack Duplicate x%d" % duplicate_count
		_auto_pack_reward_text = dup_text if _auto_pack_reward_text.is_empty() else "%s | %s" % [_auto_pack_reward_text, dup_text]

func _claim_one_pack_silent() -> Dictionary:
	if _packs_unopened <= 0:
		return {}
	_packs_unopened -= 1
	var card_id: String = _roll_card_id()
	var is_new: bool = not _owned_cards.has(card_id)
	if is_new:
		_owned_cards.append(card_id)
		_mark_new_card(card_id)
	else:
		_pack_progress += DUPLICATE_SHARD_POINTS
		var req: int = _current_pack_points_required()
		while _pack_progress >= req:
			_pack_progress -= req
			_packs_unopened += 1
	var card: Dictionary = _card_defs.get(card_id, {})
	return {
		"id": card_id,
		"name": str(card.get("name", card_id)),
		"is_new": is_new
	}

func _update_hud() -> void:
	score_label.text = "%d" % _score
	best_label.text = "%d" % _best_score
	streak_label.text = "Streak: %d  Chain: %d" % [_sweep_streak, _perfect_chain]
	rescue_label.text = "%d" % _rescued_count
	life_label.text = "Extra Life: ♥%d" % _extra_lives
	level_label.text = "LEVEL %d  LOOP %d" % [_level_index + 1, _loop_index]
	level_timer_label.max_value = LEVEL_DURATION_SEC
	level_timer_label.value = _level_time_left
	fuel_bar.max_value = FUEL_MAX
	fuel_bar.value = _fuel
	fuel_text.text = "FUEL %d%%" % int(round((_fuel / FUEL_MAX) * 100.0))
	var fuel_color: Color = Color("#67e8f9")
	if _fuel <= 35.0:
		fuel_color = Color("#fb923c")
	if _fuel <= 15.0:
		fuel_color = Color("#ef4444")
	fuel_text.add_theme_color_override("font_color", fuel_color)
	charge_hint_label.text = "ARMOR"
	if _armor_boost_time_left > 0.0:
		charge_hint_label.text = "ARMOR+ %.1fs" % _armor_boost_time_left
	rescue_title_label.text = "RESCUE" if _rescue_combo <= 1 else "RESCUE x%d" % _rescue_combo
	var rescue_title_color: Color = Color("#93c5fd") if _rescue_combo <= 1 else Color("#fbbf24")
	rescue_title_label.add_theme_color_override("font_color", rescue_title_color)
	charges_label.set_values(_charges, STAMP_CHARGES_MAX)
	if _charges != _prev_charges:
		_play_charge_feedback(_charges > _prev_charges)
		_prev_charges = _charges
	elif not _is_charge_tween_running():
		charges_label.scale = Vector2.ONE

func _current_regen_sec() -> float:
	var level: int = mini(int(floor(float(_score) / 10.0)), 3)
	match level:
		0:
			return STAMP_REGEN_L1_SEC
		1:
			return STAMP_REGEN_L2_SEC
		2:
			return STAMP_REGEN_L3_SEC
		_:
			return STAMP_REGEN_L4_SEC

func _play_charge_feedback(increased: bool) -> void:
	if _is_charge_tween_running():
		_charge_tween.kill()
	charges_label.play_feedback(increased)
	var from_scale := Vector2(1.28, 1.28) if increased else Vector2(0.8, 0.8)
	charges_label.scale = from_scale
	_charge_tween = create_tween()
	_charge_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_charge_tween.tween_property(charges_label, "scale", Vector2.ONE, 0.22)

func _play_score_pop() -> void:
	_play_score_pop_with("+1", Color("#32d17e"))

func _play_score_pop_with(text: String, color: Color) -> void:
	if _score_pop_tween != null and _score_pop_tween.is_running():
		_score_pop_tween.kill()
	score_pop_label.text = text
	score_pop_label.modulate = Color(color.r, color.g, color.b, 0.0)
	score_pop_label.position = Vector2(276.0, 136.0)
	var pop_target := Vector2(276.0, 108.0)
	_score_pop_tween = create_tween()
	_score_pop_tween.set_parallel(true)
	_score_pop_tween.tween_property(score_pop_label, "position", pop_target, 0.3)
	_score_pop_tween.tween_property(score_pop_label, "modulate:a", 1.0, 0.08)
	_score_pop_tween.tween_property(score_pop_label, "modulate:a", 0.0, 0.22).set_delay(0.08)

func _try_perfect_stamp() -> void:
	if not sweep.is_warning_active():
		_break_perfect_chain()
		return
	var t_until: float = sweep.time_until_sweep()
	if t_until > PERFECT_WINDOW_SEC:
		_break_perfect_chain()
		return
	# Perfect must also be a guaranteed save timing with current shield window.
	if t_until > _current_shield_window_sec():
		_break_perfect_chain()
		return
	_perfect_chain += 1
	_perfect_count += 1
	var chain_bonus: int = mini(maxi(_perfect_chain - 1, 0), PERFECT_CHAIN_BONUS_CAP)
	var points: int = PERFECT_STAMP_BONUS + chain_bonus
	var text: String = "PERFECT +%d" % points
	if _perfect_chain > 1:
		text = "PERFECT x%d +%d" % [_perfect_chain, points]
	_add_score(points, text, Color("#60a5fa"))
	_play_perfect_sfx()

func _register_survived_sweep() -> void:
	_sweep_streak += 1
	if _sweep_streak % SWEEP_STREAK_BONUS_EVERY == 0:
		_add_score(SWEEP_STREAK_BONUS_POINTS, "STREAK +%d" % SWEEP_STREAK_BONUS_POINTS, Color("#fbbf24"))
		_play_streak_sfx()

func _add_score(points: int, pop_text: String, pop_color: Color) -> void:
	_score += points
	_apply_run_palette()
	_play_score_pop_with(pop_text, pop_color)
	if not _best_celebrated_run and _score > _best_at_run_start:
		_best_celebrated_run = true
		best_celebration.trigger_celebration()
		_play_best_break_sfx()
		_play_score_pop_with("NEW BEST!", Color("#fbbf24"))
		_trigger_shake(10.0, 0.24)
	if points == 1 and pop_text == "+1":
		_play_gate_sfx()
	if _score > _best_score:
		_run_hit_new_best = true
		_best_score = _score
		_save_best_score()

func _break_perfect_chain() -> void:
	_perfect_chain = 0

func _break_rescue_combo() -> void:
	_rescue_combo = 0

func _roll_astronaut_type() -> int:
	var r: float = randf()
	var life_cut: float = PICKUP_LIFE_WEIGHT
	var stamp_cut: float = life_cut + PICKUP_STAMP_WEIGHT
	var boost_cut: float = stamp_cut + PICKUP_BOOST_WEIGHT
	var score_cut: float = boost_cut + PICKUP_SCORE_WEIGHT
	if r < life_cut:
		return ASTRONAUT_TYPE_LIFE
	if r < stamp_cut:
		return ASTRONAUT_TYPE_STAMP
	if r < boost_cut:
		return ASTRONAUT_TYPE_BOOST
	if r < score_cut:
		return ASTRONAUT_TYPE_SCORE
	return ASTRONAUT_TYPE_SCORE

func _current_shield_window_sec() -> float:
	return ARMOR_SHIELD_BOOST_SEC if _armor_boost_time_left > 0.0 else ARMOR_SHIELD_BASE_SEC

func _commit_pack_progress(run_points: int) -> void:
	var total: int = _pack_progress + maxi(run_points, 0)
	_packs_earned_last_run = 0
	var req: int = _current_pack_points_required()
	while total >= req:
		total -= req
		_packs_earned_last_run += 1
	_packs_unopened += _packs_earned_last_run
	_pack_progress = total
	_save_meta_progress()

func _award_score_card_from_run(run_score: int) -> void:
	var rarity: String = ""
	var reward_card_id: String = ""
	if run_score >= SCORE_CARD_LEGEND_MIN:
		rarity = "LEGEND"
		reward_card_id = CARD_SCORE_BADGE_LEGEND
	elif run_score >= SCORE_CARD_EPIC_MIN:
		rarity = "EPIC"
		reward_card_id = CARD_SCORE_BADGE_EPIC
	elif run_score >= SCORE_CARD_RARE_MIN:
		rarity = "RARE"
		reward_card_id = CARD_SCORE_BADGE_RARE
	if rarity.is_empty() or reward_card_id.is_empty():
		_score_card_reward_text = ""
		return

	var card: Dictionary = _card_defs.get(reward_card_id, {})
	var card_name: String = str(card.get("name", reward_card_id))
	if _unlock_card_if_new(reward_card_id):
		_score_card_reward_text = "Score Milestone unlocked: %s" % card_name
	else:
		_pack_progress += SCORE_CARD_DUPLICATE_PACK_BONUS
		var req: int = _current_pack_points_required()
		while _pack_progress >= req:
			_pack_progress -= req
			_packs_unopened += 1
		_score_card_reward_text = "Score reward already owned: +%d Pack Progress" % SCORE_CARD_DUPLICATE_PACK_BONUS
	_save_meta_progress()

func _award_loop_badge_for_loop(loop_value: int) -> void:
	var badge_id: String = ""
	if loop_value >= 6:
		badge_id = CARD_LOOP_BADGE_III
	elif loop_value >= 4:
		badge_id = CARD_LOOP_BADGE_II
	elif loop_value >= 2:
		badge_id = CARD_LOOP_BADGE_I
	if badge_id.is_empty():
		return
	if _unlock_card_if_new(badge_id):
		_save_meta_progress()

func _unlock_card_if_new(card_id: String) -> bool:
	if _owned_cards.has(card_id):
		return false
	_owned_cards.append(card_id)
	_mark_new_card(card_id)
	return true

func _try_consume_extra_life() -> bool:
	if _extra_lives <= 0:
		return false
	_extra_lives -= 1
	_play_shield_sfx()
	_play_score_pop_with("LIFE SAVE!", Color("#fca5a5"))
	_trigger_shake(9.0, 0.14)
	_play_sweep_flash(false)
	return true

func _check_near_miss_bonus() -> void:
	var distance: float = sweep.distance_to_band(player.global_position.y)
	if distance > 0.0 and distance <= NEAR_MISS_MARGIN_PX:
		_add_score(NEAR_MISS_BONUS, "NEAR MISS +%d" % NEAR_MISS_BONUS, Color("#f472b6"))
		_play_near_miss_sfx()

func _tick_gold_rush(delta: float) -> void:
	if _gold_rush_active:
		_gold_rush_time_left = maxf(_gold_rush_time_left - delta, 0.0)
		if _gold_rush_time_left <= 0.0:
			_gold_rush_active = false
			_gold_rush_cooldown_left = randf_range(GOLD_RUSH_COOLDOWN_MIN, GOLD_RUSH_COOLDOWN_MAX)
		return

	_gold_rush_cooldown_left -= delta
	if _gold_rush_cooldown_left <= 0.0:
		_gold_rush_active = true
		_gold_rush_time_left = GOLD_RUSH_DURATION_SEC
		_gate_timer = 0.0
		_play_score_pop_with("GOLD RUSH!", Color("#fbbf24"))
		_play_gold_rush_sfx()

func _play_charge_warning_glow() -> void:
	if _charge_glow_tween != null and _charge_glow_tween.is_running():
		_charge_glow_tween.kill()
	charge_panel.color = Color("#1a2c4d")
	_charge_glow_tween = create_tween()
	_charge_glow_tween.tween_property(charge_panel, "color", Color("#3b1b2f"), 0.14)
	_charge_glow_tween.tween_property(charge_panel, "color", Color("#081129"), 0.46)

func _play_sweep_flash(hit_player: bool) -> void:
	if _flash_tween != null and _flash_tween.is_running():
		_flash_tween.kill()
	flash_rect.color = Color(1.0, 0.44, 0.34, 0.0) if hit_player else Color(1.0, 0.62, 0.5, 0.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(flash_rect, "color:a", 0.16 if hit_player else 0.09, 0.05)
	_flash_tween.tween_property(flash_rect, "color:a", 0.0, 0.18)

func _play_death_flash() -> void:
	if _flash_tween != null and _flash_tween.is_running():
		_flash_tween.kill()
	flash_rect.color = Color(1.0, 0.2, 0.34, 0.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(flash_rect, "color:a", 0.35, 0.06)
	_flash_tween.tween_property(flash_rect, "color:a", 0.0, 0.26)

func _trigger_shake(strength: float, duration: float) -> void:
	_shake_strength = strength
	_shake_duration = duration
	_shake_time = duration

func _update_shake(delta: float) -> void:
	if _shake_time <= 0.0:
		world.position = Vector2.ZERO
		return
	_shake_time = maxf(_shake_time - delta, 0.0)
	var t := _shake_time / _shake_duration
	var mag := _shake_strength * t
	world.position = Vector2(
		_rng.randf_range(-mag, mag),
		_rng.randf_range(-mag, mag)
	)

func _is_charge_tween_running() -> bool:
	return _charge_tween != null and _charge_tween.is_running()

func _setup_sfx_pool() -> void:
	for _i: int in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

func _setup_voice_pool() -> void:
	for _i: int in range(VOICE_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_voice_players.append(player)

func _get_sfx_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _sfx_players:
		if not player.playing:
			return player
	return _sfx_players[0]

func _get_voice_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _voice_players:
		if not player.playing:
			return player
	return _voice_players[0]

func _load_voice_streams() -> void:
	_voice_streams.clear()
	_voice_streams["perfect"] = _load_first_voice_stream([
		"res://assets/voice/perfect.ogg",
		"res://assets/voice/perfect.wav",
		"res://assets/voice/perfect.mp3"
	])
	_voice_streams["streak"] = _load_first_voice_stream([
		"res://assets/voice/streak.ogg",
		"res://assets/voice/streak.wav",
		"res://assets/voice/streak.mp3"
	])
	_voice_streams["new-best"] = _load_first_voice_stream([
		"res://assets/voice/new-best.ogg",
		"res://assets/voice/new_best.ogg",
		"res://assets/voice/newbest.ogg",
		"res://assets/voice/new-best.wav",
		"res://assets/voice/new-best.mp3"
	])

func _load_first_voice_stream(candidates: Array[String]) -> AudioStream:
	for path: String in candidates:
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path)
			if stream != null:
				return stream
	return null

func _play_voice(key: String, volume_offset_db: float = 0.0) -> void:
	if not _sfx_enabled:
		return
	if not _voice_streams.has(key):
		return
	var stream: AudioStream = _voice_streams[key] as AudioStream
	if stream == null:
		return
	var player := _get_voice_player()
	player.stream = stream
	player.volume_db = _sfx_volume_db + volume_offset_db
	player.play()

func _play_tone(freq_hz: float, duration_sec: float, volume_db: float = -10.0, phase_offset: float = 0.0) -> void:
	if not _sfx_enabled:
		return
	var player := _get_sfx_player()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 44100.0
	stream.buffer_length = maxf(0.08, duration_sec + 0.04)
	player.stream = stream
	player.volume_db = volume_db + _sfx_volume_db
	player.play()

	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return

	var sample_count := int(duration_sec * stream.mix_rate)
	for i: int in range(sample_count):
		var t := float(i) / stream.mix_rate
		var env := minf(1.0, t / 0.01) * maxf(0.0, (duration_sec - t) / maxf(0.001, duration_sec * 0.85))
		var sample := sin(TAU * freq_hz * t + phase_offset) * env * 0.55
		playback.push_frame(Vector2(sample, sample))

func _play_two_tones(freq_a: float, len_a: float, freq_b: float, len_b: float, vol_db: float) -> void:
	_play_tone(freq_a, len_a, vol_db)
	var timer := get_tree().create_timer(len_a * 0.55)
	timer.timeout.connect(func() -> void:
		_play_tone(freq_b, len_b, vol_db)
	)

func _play_start_sfx() -> void:
	_play_two_tones(420.0, 0.06, 620.0, 0.08, -12.0)

func _play_stamp_sfx() -> void:
	_play_two_tones(760.0, 0.05, 1040.0, 0.07, -10.0)

func _play_dry_sfx() -> void:
	_play_tone(190.0, 0.08, -14.0, PI * 0.5)

func _play_regen_sfx() -> void:
	_play_tone(560.0, 0.09, -13.0)

func _play_gate_sfx() -> void:
	_play_two_tones(640.0, 0.05, 820.0, 0.06, -11.0)

func _play_warning_sfx() -> void:
	_play_two_tones(280.0, 0.06, 240.0, 0.06, -14.0)

func _play_shield_sfx() -> void:
	_play_two_tones(960.0, 0.05, 1280.0, 0.06, -11.0)

func _play_perfect_sfx() -> void:
	_play_two_tones(990.0, 0.05, 1480.0, 0.08, -8.0)
	_play_voice("perfect", -5.0)

func _play_streak_sfx() -> void:
	_play_two_tones(540.0, 0.06, 920.0, 0.08, -9.0)
	_play_voice("streak", -4.0)

func _play_near_miss_sfx() -> void:
	_play_two_tones(720.0, 0.05, 910.0, 0.06, -10.0)

func _play_gold_rush_sfx() -> void:
	_play_two_tones(460.0, 0.08, 860.0, 0.10, -8.0)

func _play_gold_gate_sfx() -> void:
	_play_two_tones(780.0, 0.05, 1160.0, 0.08, -9.0)

func _play_heart_pickup_sfx() -> void:
	_play_two_tones(660.0, 0.06, 980.0, 0.08, -10.0)

func _play_fuel_pickup_sfx() -> void:
	_play_two_tones(520.0, 0.05, 880.0, 0.07, -9.0)

func _play_death_sfx() -> void:
	_play_tone(210.0, 0.08, -8.0, PI * 0.5)
	var timer_a := get_tree().create_timer(0.05)
	timer_a.timeout.connect(func() -> void:
		_play_tone(130.0, 0.16, -7.0, PI * 0.3)
	)
	var timer_b := get_tree().create_timer(0.11)
	timer_b.timeout.connect(func() -> void:
		_play_tone(82.0, 0.22, -6.0, PI * 0.1)
	)

func _play_best_break_sfx() -> void:
	_play_two_tones(720.0, 0.08, 1180.0, 0.10, -7.0)
	_play_voice("new-best", 1.5)
	var timer := get_tree().create_timer(0.08)
	timer.timeout.connect(func() -> void:
		_play_two_tones(980.0, 0.07, 1460.0, 0.11, -7.0)
	)

func _play_badge_unlock_sfx() -> void:
	_play_two_tones(560.0, 0.06, 1120.0, 0.10, -8.0)

func _play_pack_open_sfx() -> void:
	_play_two_tones(420.0, 0.05, 760.0, 0.07, -10.0)

func _setup_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = _music_mix_rate
	stream.buffer_length = 0.5
	_music_player.stream = stream
	add_child(_music_player)
	_music_player.play()
	_music_playback = _music_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _update_music() -> void:
	if _music_player == null:
		return
	if not _music_enabled:
		if _music_player.playing:
			_music_player.stop()
		return
	if not _music_player.playing:
		_music_player.play()
		_music_playback = _music_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if _music_playback == null:
		return

	var frames := _music_playback.get_frames_available()
	for _i: int in range(frames):
		var sample := _music_sample_step()
		_music_playback.push_frame(Vector2(sample, sample))

func _music_sample_step() -> float:
	var dt := 1.0 / _music_mix_rate
	_music_time += dt
	_music_phase += dt
	var beat_dur := 0.5
	var step := int(floor(_music_time / beat_dur)) % 8
	var beat_time := fmod(_music_time, beat_dur)
	var env := maxf(0.0, 1.0 - beat_time / beat_dur)
	var roots := PackedFloat64Array([220.0, 246.94, 196.0, 220.0, 174.61, 196.0, 164.81, 196.0])
	var root: float = roots[step]
	var lead := sin(TAU * root * _music_phase) * env
	var harmony := sin(TAU * (root * 1.5) * _music_phase + 0.8) * env * 0.62
	var bass := sin(TAU * (root * 0.5) * _music_phase + 1.3) * 0.45
	return (lead * 0.10 + harmony * 0.07 + bass * 0.06) * 0.9

func _connect_settings_ui() -> void:
	settings_button.pressed.connect(_on_settings_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	album_nav_button.pressed.connect(_on_album_nav_button_pressed)
	settings_close_button.pressed.connect(_on_settings_close_pressed)
	help_close_button.pressed.connect(_on_help_close_pressed)
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	open_pack_button.pressed.connect(_on_open_pack_pressed)
	album_button.pressed.connect(_on_album_button_pressed)
	pack_result_equip.pressed.connect(_on_pack_equip_pressed)
	pack_result_close.pressed.connect(_on_pack_result_close_pressed)
	album_close.pressed.connect(_on_album_close_pressed)
	badge_unlock_close.pressed.connect(_on_badge_unlock_close_pressed)

func _apply_audio_settings_to_ui() -> void:
	music_toggle.button_pressed = _music_enabled
	sfx_toggle.button_pressed = _sfx_enabled
	music_volume_slider.value = _music_volume_db
	sfx_volume_slider.value = _sfx_volume_db
	_refresh_toggle_labels()

func _apply_audio_settings() -> void:
	if _music_player != null:
		_music_player.volume_db = _music_volume_db
		if not _music_enabled and _music_player.playing:
			_music_player.stop()
		elif _music_enabled and not _music_player.playing:
			_music_player.play()
			_music_playback = _music_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _on_settings_button_pressed() -> void:
	_set_pack_result_open(false)
	_set_album_open(false)
	_set_help_open(false)
	_set_settings_open(not _settings_open)

func _on_settings_close_pressed() -> void:
	_set_settings_open(false)

func _on_help_button_pressed() -> void:
	_set_pack_result_open(false)
	_set_album_open(false)
	_set_settings_open(false)
	_set_help_open(not help_panel.visible)

func _on_album_nav_button_pressed() -> void:
	_set_pack_result_open(false)
	_set_settings_open(false)
	_set_help_open(false)
	var should_open: bool = not album_panel.visible
	_set_album_open(should_open)
	if not should_open:
		_clear_new_markers()

func _on_help_close_pressed() -> void:
	_set_help_open(false)

func _on_music_toggled(value: bool) -> void:
	_music_enabled = value
	_refresh_toggle_labels()
	_apply_audio_settings()
	_save_audio_settings()

func _on_sfx_toggled(value: bool) -> void:
	_sfx_enabled = value
	_refresh_toggle_labels()
	_apply_audio_settings()
	_save_audio_settings()

func _on_music_volume_changed(value: float) -> void:
	_music_volume_db = value
	_apply_audio_settings()
	_save_audio_settings()

func _on_sfx_volume_changed(value: float) -> void:
	_sfx_volume_db = value
	_apply_audio_settings()
	_save_audio_settings()

func _load_audio_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	_music_enabled = bool(cfg.get_value("audio", "music_enabled", false))
	_sfx_enabled = bool(cfg.get_value("audio", "sfx_enabled", true))
	_music_volume_db = float(cfg.get_value("audio", "music_volume_db", -12.0))
	_sfx_volume_db = float(cfg.get_value("audio", "sfx_volume_db", -8.0))

func _save_audio_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("audio", "music_enabled", _music_enabled)
	cfg.set_value("audio", "sfx_enabled", _sfx_enabled)
	cfg.set_value("audio", "music_volume_db", _music_volume_db)
	cfg.set_value("audio", "sfx_volume_db", _sfx_volume_db)
	cfg.save(SAVE_PATH)

func _refresh_toggle_labels() -> void:
	music_toggle.text = "Music: %s" % ("ON" if _music_enabled else "OFF")
	sfx_toggle.text = "SFX: %s" % ("ON" if _sfx_enabled else "OFF")

func _set_settings_open(open: bool) -> void:
	_settings_open = open
	settings_panel.visible = open
	if open:
		settings_panel.move_to_front()
	_update_status_visibility()

func _set_help_open(open: bool) -> void:
	help_panel.visible = open
	if open:
		help_panel.move_to_front()
	_update_status_visibility()

func _is_overlay_open() -> bool:
	return _settings_open or help_panel.visible or pack_result_panel.visible or album_panel.visible or badge_unlock_panel.visible

func _update_status_visibility() -> void:
	status_label.visible = not _is_overlay_open()

func _set_best_banner(visible_state: bool, score_value: int) -> void:
	best_banner.visible = visible_state
	if not visible_state:
		return
	best_banner_title.text = "NEW BEST SCORE!"
	best_banner_score.text = "%d" % score_value
	best_banner.move_to_front()

func _show_level_banner(text: String, color: Color) -> void:
	if _level_banner_tween != null and _level_banner_tween.is_running():
		_level_banner_tween.kill()
	level_banner_label.text = text
	level_banner_label.visible = true
	level_banner_label.modulate = Color(color.r, color.g, color.b, 0.0)
	level_banner_label.scale = Vector2(0.88, 0.88)
	level_banner_label.move_to_front()
	_level_banner_tween = create_tween()
	_level_banner_tween.set_parallel(true)
	_level_banner_tween.tween_property(level_banner_label, "modulate:a", 1.0, 0.16)
	_level_banner_tween.tween_property(level_banner_label, "scale", Vector2.ONE, 0.18)
	_level_banner_tween.tween_property(level_banner_label, "modulate:a", 0.0, 0.34).set_delay(0.86)
	_level_banner_tween.finished.connect(func() -> void:
		level_banner_label.visible = false
	)

func _apply_run_palette() -> void:
	var c := _loop_base_color(_loop_index)
	# Keep slight in-loop gradient so score still feels alive.
	var score_t: float = float(_score % PALETTE_STEP_SCORE) / float(PALETTE_STEP_SCORE)
	c = c.lerp(c.lightened(0.22), score_t * 0.55)
	player.color = c
	trail.unlocked_color = c
	trail.locked_color = c.lightened(0.42)
	_apply_equipped_trail_skin()
	space_background.call("set_biome_from_level", _level_index)
	player.queue_redraw()
	trail.queue_redraw()

func _score_palette_color(score_value: int) -> Color:
	var palette: Array[Color] = [
		Color("#3b82f6"), # blue
		Color("#8b5cf6"), # violet
		Color("#ec4899"), # pink
		Color("#f97316"), # orange
		Color("#ef4444") # red
	]
	var max_band: int = palette.size() - 1
	var raw_band: int = int(floor(float(score_value) / float(PALETTE_STEP_SCORE)))
	var band: int = mini(raw_band, max_band)
	if band >= max_band:
		return palette[max_band]
	var t: float = float(score_value % PALETTE_STEP_SCORE) / float(PALETTE_STEP_SCORE)
	return palette[band].lerp(palette[band + 1], t)

func _loop_base_color(loop_idx: int) -> Color:
	var loop_palette: Array[Color] = [
		Color("#3b82f6"), # loop 1 blue
		Color("#22d3ee"), # loop 2 cyan
		Color("#f59e0b"), # loop 3 amber
		Color("#ec4899"), # loop 4 pink
		Color("#ef4444") # loop 5+ red
	]
	var index: int = clampi(loop_idx - 1, 0, loop_palette.size() - 1)
	return loop_palette[index]

func _current_gate_colors() -> Array[Color]:
	# Match gate visuals to active level biome.
	match _level_index:
		0:
			return [Color("#22c55e"), Color("#dcfce7")] # nebula
		1:
			return [Color("#38bdf8"), Color("#dbeafe")] # asteroid
		2:
			return [Color("#a78bfa"), Color("#ede9fe")] # plasma
		_:
			return [Color("#fb923c"), Color("#ffedd5")] # solar

func _clear_gates() -> void:
	for gate in gates_root.get_children():
		gate.queue_free()
	for heart in heart_pickups_root.get_children():
		heart.queue_free()
	for fuel in fuel_pickups_root.get_children():
		fuel.queue_free()

func _setup_card_defs() -> void:
	_card_defs.clear()
	_pack_card_order = PackedStringArray([
		CARD_TRAIL_NEON,
		CARD_TRAIL_SOLAR,
		CARD_TRAIL_VOID
	])
	_card_order = PackedStringArray([
		CARD_TRAIL_NEON,
		CARD_TRAIL_SOLAR,
		CARD_TRAIL_VOID,
		CARD_SCORE_BADGE_RARE,
		CARD_SCORE_BADGE_EPIC,
		CARD_SCORE_BADGE_LEGEND,
		CARD_LOOP_BADGE_I,
		CARD_LOOP_BADGE_II,
		CARD_LOOP_BADGE_III
	])
	_card_defs[CARD_TRAIL_NEON] = {
		"name": "Neon Wake",
		"rarity": "RARE",
		"weight": 0.24,
		"kind": "trail",
		"desc": "Cyan neon trail with boosted glow."
	}
	_card_defs[CARD_TRAIL_SOLAR] = {
		"name": "Solar Ember",
		"rarity": "EPIC",
		"weight": 0.09,
		"kind": "trail",
		"desc": "Molten orange trail with bright comet streak."
	}
	_card_defs[CARD_TRAIL_VOID] = {
		"name": "Void Prism",
		"rarity": "LEGEND",
		"weight": 0.03,
		"kind": "trail",
		"desc": "Deep cosmic trail with low glow and hard edge."
	}
	_card_defs[CARD_SCORE_BADGE_RARE] = {
		"name": "Score Ace I",
		"rarity": "RARE",
		"kind": "score_badge",
		"desc": "Reach 20+ score in a run."
	}
	_card_defs[CARD_SCORE_BADGE_EPIC] = {
		"name": "Score Ace II",
		"rarity": "EPIC",
		"kind": "score_badge",
		"desc": "Reach 45+ score in a run."
	}
	_card_defs[CARD_SCORE_BADGE_LEGEND] = {
		"name": "Score Ace III",
		"rarity": "LEGEND",
		"kind": "score_badge",
		"desc": "Reach 70+ score in a run."
	}
	_card_defs[CARD_LOOP_BADGE_I] = {
		"name": "Loop Runner I",
		"rarity": "RARE",
		"kind": "loop_badge",
		"desc": "Reach Loop 2."
	}
	_card_defs[CARD_LOOP_BADGE_II] = {
		"name": "Loop Runner II",
		"rarity": "EPIC",
		"kind": "loop_badge",
		"desc": "Reach Loop 4."
	}
	_card_defs[CARD_LOOP_BADGE_III] = {
		"name": "Loop Runner III",
		"rarity": "LEGEND",
		"kind": "loop_badge",
		"desc": "Reach Loop 6."
	}

func _set_pack_result_open(open: bool) -> void:
	pack_result_panel.visible = open
	if open:
		pack_result_panel.move_to_front()
	_update_status_visibility()

func _set_album_open(open: bool) -> void:
	album_panel.visible = open
	if _state == GameState.DEAD:
		death_card.visible = not open
	if open:
		_refresh_album_badges()
		album_panel.move_to_front()
	_update_status_visibility()

func _set_badge_unlock_visible(visible_state: bool) -> void:
	badge_unlock_panel.visible = visible_state
	if visible_state:
		badge_unlock_panel.move_to_front()

func _mark_new_card(card_id: String) -> void:
	if not _new_cards_session.has(card_id):
		_new_cards_session.append(card_id)
	if _is_trail_card(card_id):
		_equipped_trail_card = card_id
	_unlock_queue.append(card_id)
	_play_badge_unlock_sfx()

func _tick_unlock_banner(_delta: float) -> void:
	if _unlock_showing:
		return
	if _unlock_queue.is_empty():
		return
	_show_next_unlock_banner()

func _show_next_unlock_banner() -> void:
	var card_id: String = str(_unlock_queue.pop_front())
	var card: Dictionary = _card_defs.get(card_id, {})
	var card_name: String = str(card.get("name", card_id))
	var rarity: String = str(card.get("rarity", "RARE"))
	badge_unlock_title.text = "NEW BADGE UNLOCKED"
	badge_unlock_name.text = card_name
	badge_unlock_badge.configure(card_id, card_name, rarity, true, _equipped_trail_card == card_id, true)
	_set_badge_unlock_visible(true)
	_unlock_showing = true
	if _badge_unlock_tween != null and _badge_unlock_tween.is_running():
		_badge_unlock_tween.kill()
	badge_unlock_panel.modulate = Color(1, 1, 1, 0.0)
	badge_unlock_panel.scale = Vector2(0.92, 0.92)
	_badge_unlock_tween = create_tween()
	_badge_unlock_tween.set_parallel(true)
	_badge_unlock_tween.tween_property(badge_unlock_panel, "modulate:a", 1.0, 0.12)
	_badge_unlock_tween.tween_property(badge_unlock_panel, "scale", Vector2.ONE, 0.16)

func _clear_new_markers() -> void:
	_new_cards_session.clear()
	_refresh_album_badges()

func _on_open_pack_pressed() -> void:
	if _packs_unopened <= 0:
		return
	_set_album_open(false)
	_claim_one_pack_silent()
	_save_meta_progress()
	open_pack_button.visible = _packs_unopened > 0
	open_pack_button.disabled = _packs_unopened <= 0
	open_pack_button.text = "Open Pack (%d)" % _packs_unopened
	var req_after: int = _current_pack_points_required()
	death_pack_bar.max_value = float(req_after)
	death_pack_bar.value = float(_pack_progress)
	death_pack_label.text = "Next Pack: %d/%d" % [_pack_progress, req_after]
	if _state == GameState.DEAD and not _unlock_queue.is_empty():
		_state = GameState.REWARDING
		death_card.visible = false

func _roll_card_id() -> String:
	var total_weight: float = 0.0
	for card_id: String in _pack_card_order:
		var card: Dictionary = _card_defs.get(card_id, {})
		total_weight += float(card.get("weight", 0.0))
	if total_weight <= 0.0:
		return CARD_TRAIL_NEON
	var pick: float = _rng.randf() * total_weight
	var accum: float = 0.0
	for card_id: String in _pack_card_order:
		var card: Dictionary = _card_defs.get(card_id, {})
		accum += float(card.get("weight", 0.0))
		if pick <= accum:
			return card_id
	return str(_pack_card_order[_pack_card_order.size() - 1])

func _show_pack_result(card_id: String, is_new: bool) -> void:
	var card: Dictionary = _card_defs.get(card_id, {})
	var card_name: String = str(card.get("name", card_id))
	var rarity: String = str(card.get("rarity", "RARE"))
	var desc: String = str(card.get("desc", ""))
	var rarity_color: Color = _rarity_color(rarity)
	pack_result_title.text = "NEW CARD" if is_new else "DUPLICATE"
	pack_result_name.text = card_name
	pack_result_desc.text = desc if is_new else ("%s\nDuplicate bonus: +%d Pack" % [desc, DUPLICATE_SHARD_POINTS])
	pack_result_rarity.text = rarity
	pack_result_rarity.add_theme_color_override("font_color", rarity_color)
	pack_result_badge.configure(card_id, card_name, rarity, true, _equipped_trail_card == card_id)
	pack_result_equip.visible = false
	pack_result_equip.disabled = true
	_set_pack_result_open(true)
	_play_pack_open_sfx()
	if _pack_result_tween != null and _pack_result_tween.is_running():
		_pack_result_tween.kill()
	pack_result_panel.modulate = Color(1, 1, 1, 0.0)
	pack_result_panel.scale = Vector2(0.94, 0.94)
	_pack_result_tween = create_tween()
	_pack_result_tween.set_parallel(true)
	_pack_result_tween.tween_property(pack_result_panel, "modulate:a", 1.0, 0.16)
	_pack_result_tween.tween_property(pack_result_panel, "scale", Vector2.ONE, 0.18)

func _on_pack_equip_pressed() -> void:
	if _last_drawn_card_id.is_empty():
		return
	if not _owned_cards.has(_last_drawn_card_id):
		return
	_equipped_trail_card = _last_drawn_card_id
	_apply_run_palette()
	_save_meta_progress()
	var equipped_card: Dictionary = _card_defs.get(_last_drawn_card_id, {})
	pack_result_badge.configure(
		_last_drawn_card_id,
		str(equipped_card.get("name", _last_drawn_card_id)),
		str(equipped_card.get("rarity", "RARE")),
		true,
		true
	)
	_refresh_album_badges()
	pack_result_equip.disabled = true
	pack_result_equip.text = "Equipped"

func _on_pack_result_close_pressed() -> void:
	_set_pack_result_open(false)

func _on_album_button_pressed() -> void:
	_set_pack_result_open(false)
	_set_album_open(true)

func _on_album_close_pressed() -> void:
	_set_album_open(false)
	_clear_new_markers()

func _on_badge_unlock_close_pressed() -> void:
	_unlock_showing = false
	_set_badge_unlock_visible(false)

func _refresh_album_badges() -> void:
	_configure_album_badge(album_badge_neon, CARD_TRAIL_NEON)
	_configure_album_badge(album_badge_solar, CARD_TRAIL_SOLAR)
	_configure_album_badge(album_badge_void, CARD_TRAIL_VOID)
	_configure_album_badge(album_badge_score_rare, CARD_SCORE_BADGE_RARE)
	_configure_album_badge(album_badge_score_epic, CARD_SCORE_BADGE_EPIC)
	_configure_album_badge(album_badge_score_legend, CARD_SCORE_BADGE_LEGEND)
	_configure_album_badge(album_badge_loop_i, CARD_LOOP_BADGE_I)
	_configure_album_badge(album_badge_loop_ii, CARD_LOOP_BADGE_II)
	_configure_album_badge(album_badge_loop_iii, CARD_LOOP_BADGE_III)

func _configure_album_badge(badge: CardBadge, card_id: String) -> void:
	var card: Dictionary = _card_defs.get(card_id, {})
	var card_name: String = str(card.get("name", "Unknown"))
	var rarity: String = str(card.get("rarity", "RARE"))
	var owned: bool = _owned_cards.has(card_id)
	var equipped: bool = _equipped_trail_card == card_id
	var mark_new: bool = _new_cards_session.has(card_id)
	badge.configure(card_id, card_name, rarity, owned, equipped, mark_new)

func _update_ghost_marker(view_size: Vector2) -> void:
	if _state != GameState.RUNNING:
		ghost_marker.set_marker(false, Vector2.ZERO)
		return
	if _last_death_distance <= 0.0:
		ghost_marker.set_marker(false, Vector2.ZERO)
		return
	var marker_x: float = player.global_position.x + (_last_death_distance - _run_distance)
	var marker_y: float = clampf(_last_death_y, 90.0, view_size.y - 90.0)
	var in_view: bool = marker_x >= -100.0 and marker_x <= view_size.x + 120.0
	if not in_view:
		ghost_marker.set_marker(false, Vector2.ZERO)
		return
	ghost_marker.set_marker(true, Vector2(marker_x, marker_y), "LAST CRASH")

func _current_pack_points_required() -> int:
	var owned_trail: int = _owned_trail_badge_count()
	if owned_trail <= 0:
		return PACK_REQ_TIER_1
	if owned_trail == 1:
		return PACK_REQ_TIER_2
	return PACK_REQ_TIER_3

func _owned_trail_badge_count() -> int:
	var count: int = 0
	for card_id: String in _owned_cards:
		if _is_trail_card(card_id):
			count += 1
	return count

func _is_trail_card(card_id: String) -> bool:
	return card_id == CARD_TRAIL_NEON or card_id == CARD_TRAIL_SOLAR or card_id == CARD_TRAIL_VOID

func _apply_equipped_trail_skin() -> void:
	match _equipped_trail_card:
		CARD_TRAIL_NEON:
			trail.unlocked_color = Color("#22d3ee")
			trail.locked_color = Color("#cffafe")
			trail.unlocked_width = 4.8
			trail.locked_width = 8.6
			trail.smoke_glow = true
		CARD_TRAIL_SOLAR:
			trail.unlocked_color = Color("#fb923c")
			trail.locked_color = Color("#ffedd5")
			trail.unlocked_width = 5.2
			trail.locked_width = 9.2
			trail.smoke_glow = true
		CARD_TRAIL_VOID:
			trail.unlocked_color = Color("#6366f1")
			trail.locked_color = Color("#e0e7ff")
			trail.unlocked_width = 4.0
			trail.locked_width = 7.6
			trail.smoke_glow = false
		_:
			trail.unlocked_width = 4.0
			trail.locked_width = 8.0
			trail.smoke_glow = true

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"LEGEND":
			return Color("#fbbf24")
		"EPIC":
			return Color("#c084fc")
		_:
			return Color("#60a5fa")

func _load_best_score_if_needed() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		_best_score = 0
		return
	_best_score = int(cfg.get_value("scores", "best", 0))

func _save_best_score() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("scores", "best", _best_score)
	cfg.save(SAVE_PATH)

func _load_meta_progress_if_needed() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		_pack_progress = 0
		_packs_unopened = 0
		_owned_cards = PackedStringArray()
		_equipped_trail_card = CARD_TRAIL_DEFAULT
		_last_death_distance = -1.0
		_last_death_y = player.base_y
		return
	_pack_progress = int(cfg.get_value("meta", "pack_progress", 0))
	_packs_unopened = int(cfg.get_value("meta", "packs_unopened", 0))
	var saved_cards_text: String = str(cfg.get_value("meta", "owned_cards", ""))
	_owned_cards = PackedStringArray()
	if not saved_cards_text.is_empty():
		for card_id: String in saved_cards_text.split(","):
			var trimmed: String = card_id.strip_edges()
			if not trimmed.is_empty():
				_owned_cards.append(trimmed)
	_equipped_trail_card = str(cfg.get_value("meta", "equipped_trail_card", CARD_TRAIL_DEFAULT))
	if _equipped_trail_card.is_empty():
		_equipped_trail_card = CARD_TRAIL_DEFAULT
	# Backward compatible load: use new keys, fallback to old best_death_* keys.
	_last_death_distance = float(cfg.get_value("meta", "last_death_distance", cfg.get_value("meta", "best_death_distance", -1.0)))
	_last_death_y = float(cfg.get_value("meta", "last_death_y", cfg.get_value("meta", "best_death_y", player.base_y)))

func _save_meta_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("meta", "pack_progress", _pack_progress)
	cfg.set_value("meta", "packs_unopened", _packs_unopened)
	cfg.set_value("meta", "owned_cards", ",".join(_owned_cards))
	cfg.set_value("meta", "equipped_trail_card", _equipped_trail_card)
	cfg.set_value("meta", "last_death_distance", _last_death_distance)
	cfg.set_value("meta", "last_death_y", _last_death_y)
	cfg.save(SAVE_PATH)
