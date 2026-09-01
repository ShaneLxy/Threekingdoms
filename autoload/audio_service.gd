extends Node

const HERO_ATTACK_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/hero/attack/attack.wav"),
	preload("res://assets/audio/hero/attack/attack2.mp3"),
	preload("res://assets/audio/hero/attack/attack3.mp3"),
	preload("res://assets/audio/hero/attack/attack4.wav"),
]
const HERO_ATTACK_SHOUT_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/hero/voice/attack-shout-01.mp3"),
	preload("res://assets/audio/hero/voice/attack-shout-02.mp3"),
	preload("res://assets/audio/hero/voice/attack-shout-03.mp3"),
]
const HERO_MISS_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/hero/miss/miss.wav"),
	preload("res://assets/audio/hero/miss/miss2.wav"),
]
const HERO_MOVE_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/hero/move/move1.wav"),
	preload("res://assets/audio/hero/move/move2.wav"),
]
const HERO_SKILL_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/hero/skill/skill.mp3"),
]
const HERO_FIREWHEEL_LOOP_STREAM: AudioStream = preload("res://assets/audio/hero/firewheel-loop.mp3")
const HERO_ULTIMATE_START_STREAM: AudioStream = preload("res://assets/audio/hero/ultimate-power-up.wav")
const HERO_GUAN_YU_BLADE_WAVE_STREAM: AudioStream = preload("res://assets/audio/hero/guan_yu/knife-wave.mp3")
const HERO_ZHANG_FEI_GROUND_SLAM_STREAM: AudioStream = preload("res://assets/audio/hero/zhang_fei/ground-slam.wav")
const TIANJI_FIRE_RAIN_STREAM: AudioStream = preload("res://assets/audio/tianji/fire-rain.mp3")
const TIANJI_LIGHTNING_STREAM: AudioStream = preload("res://assets/audio/tianji/lightning.mp3")
const TIANJI_ARROW_VOLLEY_STREAM: AudioStream = preload("res://assets/audio/tianji/arrow-volley.mp3")
const TIANJI_WATER_STREAM: AudioStream = preload("res://assets/audio/tianji/water.mp3")
const TIANJI_WIND_STREAM: AudioStream = preload("res://assets/audio/tianji/wind.mp3")
const WEAPON_CLASH_STREAM: AudioStream = preload("res://assets/audio/hero/attack/attack.wav")
const TITLE_BGM_STREAM: AudioStream = preload("res://assets/audio/battle/iron-siege-march.mp3")
const BATTLE_BGM_STREAM: AudioStream = preload("res://assets/audio/battle/red-banner-charge.mp3")
const ENEMY_DUEL_CHEER_STREAM: AudioStream = preload("res://assets/audio/enemies/duel/formation-cheer.mp3")
const BOSS_ENTRANCE_VOICE_STREAM: AudioStream = preload("res://assets/audio/enemies/boss/entrance-laugh.mp3")
const ENEMY_AMBIENCE_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/enemies/ambient/enemy-voice-01.wav"),
	preload("res://assets/audio/enemies/ambient/enemy-voice-02.wav"),
]
const SFX_PLAYER_COUNT := 12
const DUEL_CHEER_INTERVAL_MIN := 3.0
const DUEL_CHEER_INTERVAL_MAX := 5.0
const MUSIC_BUS_NAME := &"Music"
const SFX_BUS_NAME := &"SFX"
const SILENT_VOLUME_DB := -80.0
const MUSIC_PLAYER_VOLUME_DB := -9.0
const MUSIC_CROSSFADE_DURATION := 0.85
const TIANJI_SOUND_TAIL_DELAY := 0.16
const TIANJI_SOUND_FADE_DURATION := 0.32

var master_volume_db := 0.0
var music_volume := 1.0
var sfx_volume := 1.0
var music_bus_index := -1
var sfx_bus_index := -1
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_cursor := 0
var firewheel_loop_player: AudioStreamPlayer
var weapon_clash_player: AudioStreamPlayer
var guan_yu_blade_wave_player: AudioStreamPlayer
var zhang_fei_ground_slam_player: AudioStreamPlayer
var tianji_sound_players: Dictionary = {}
var tianji_sound_remaining: Dictionary = {}
var tianji_sound_tail_delay: Dictionary = {}
var tianji_sound_tail_remaining: Dictionary = {}
var tianji_sound_base_volume: Dictionary = {}
var tianji_sounds_paused := false
var enemy_duel_cheer_player: AudioStreamPlayer
var hero_attack_shout_player: AudioStreamPlayer
var boss_entrance_voice_player: AudioStreamPlayer
var title_bgm_player: AudioStreamPlayer
var battle_bgm_player: AudioStreamPlayer
var music_transition: Tween
var title_bgm_enabled := false
var battle_bgm_enabled := false
var enemy_duel_cheers_enabled := false
var enemy_duel_cheers_paused := false
var enemy_duel_cheer_wait_remaining := -1.0
var last_hero_attack_shout_index := -1

func _ready() -> void:
	music_bus_index = _ensure_audio_bus(MUSIC_BUS_NAME)
	sfx_bus_index = _ensure_audio_bus(SFX_BUS_NAME)
	for _index in range(SFX_PLAYER_COUNT):
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS_NAME
		add_child(player)
		sfx_players.append(player)
	firewheel_loop_player = _create_sfx_player(HERO_FIREWHEEL_LOOP_STREAM, -6.0)
	weapon_clash_player = _create_sfx_player(WEAPON_CLASH_STREAM, -2.0)
	guan_yu_blade_wave_player = _create_sfx_player(HERO_GUAN_YU_BLADE_WAVE_STREAM, 4.0)
	zhang_fei_ground_slam_player = _create_sfx_player(HERO_ZHANG_FEI_GROUND_SLAM_STREAM, -3.0)
	_register_tianji_sound("fire_rain_burning", TIANJI_FIRE_RAIN_STREAM, -1.5)
	_register_tianji_sound("seven_star_lightning", TIANJI_LIGHTNING_STREAM, -1.5)
	_register_tianji_sound("arrow_support_volley", TIANJI_ARROW_VOLLEY_STREAM, -2.5)
	_register_tianji_sound("eight_trigram_tide", TIANJI_WATER_STREAM, -2.0)
	_register_tianji_sound("xun_wind_break", TIANJI_WIND_STREAM, -2.0)
	enemy_duel_cheer_player = _create_sfx_player(ENEMY_DUEL_CHEER_STREAM, -5.0)
	enemy_duel_cheer_player.finished.connect(_on_enemy_duel_cheer_finished)
	hero_attack_shout_player = _create_sfx_player(HERO_ATTACK_SHOUT_STREAMS[0], -5.0)
	boss_entrance_voice_player = _create_sfx_player(BOSS_ENTRANCE_VOICE_STREAM, -1.0)
	title_bgm_player = _create_music_player(TITLE_BGM_STREAM)
	title_bgm_player.finished.connect(_on_title_bgm_finished)
	battle_bgm_player = _create_music_player(BATTLE_BGM_STREAM)
	battle_bgm_player.finished.connect(_on_battle_bgm_finished)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

func _process(delta: float) -> void:
	_tick_tianji_sounds(delta)
	if not enemy_duel_cheers_enabled or enemy_duel_cheers_paused or enemy_duel_cheer_player == null:
		return
	if enemy_duel_cheer_player.playing or enemy_duel_cheer_wait_remaining < 0.0:
		return
	enemy_duel_cheer_wait_remaining = maxf(0.0, enemy_duel_cheer_wait_remaining - delta)
	if enemy_duel_cheer_wait_remaining <= 0.0:
		enemy_duel_cheer_wait_remaining = -1.0
		enemy_duel_cheer_player.play()

func set_master_volume(value_db: float) -> void:
	master_volume_db = value_db
	AudioServer.set_bus_volume_db(0, master_volume_db)

func apply_settings(settings: Dictionary) -> void:
	var sound_enabled := bool(settings.get("sound_enabled", true))
	set_master_volume(0.0 if sound_enabled else SILENT_VOLUME_DB)
	set_music_volume(float(settings.get("music_volume", 1.0)))
	set_sfx_volume(float(settings.get("sfx_volume", 1.0)))

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_set_bus_linear_volume(music_bus_index, music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_set_bus_linear_volume(sfx_bus_index, sfx_volume)

func play_hero_attack_hit() -> void:
	_play_random(HERO_ATTACK_STREAMS, -5.0)

func play_hero_miss() -> void:
	_play_random(HERO_MISS_STREAMS, -7.0)

func play_hero_move() -> void:
	_play_random(HERO_MOVE_STREAMS, -9.0)

func play_hero_skill_hit() -> void:
	_play_random(HERO_SKILL_STREAMS, -4.0)

func play_weapon_clash(perfect: bool, skill_clash: bool) -> void:
	if weapon_clash_player == null:
		return
	weapon_clash_player.volume_db = -1.0 if perfect else -2.0
	weapon_clash_player.pitch_scale = 1.08 if perfect else (0.94 if skill_clash else 1.0)
	weapon_clash_player.play()

func play_guan_yu_blade_wave() -> void:
	_play_dedicated_sfx(guan_yu_blade_wave_player)

func play_zhang_fei_ground_slam() -> void:
	_play_dedicated_sfx(zhang_fei_ground_slam_player)

func play_hero_attack_shout() -> void:
	if hero_attack_shout_player == null or hero_attack_shout_player.playing or HERO_ATTACK_SHOUT_STREAMS.is_empty():
		return
	var stream_index := randi() % HERO_ATTACK_SHOUT_STREAMS.size()
	if HERO_ATTACK_SHOUT_STREAMS.size() > 1 and stream_index == last_hero_attack_shout_index:
		stream_index = (stream_index + 1 + randi() % (HERO_ATTACK_SHOUT_STREAMS.size() - 1)) % HERO_ATTACK_SHOUT_STREAMS.size()
	last_hero_attack_shout_index = stream_index
	hero_attack_shout_player.stream = HERO_ATTACK_SHOUT_STREAMS[stream_index]
	_play_dedicated_sfx(hero_attack_shout_player)

func play_boss_entrance_voice() -> void:
	_play_dedicated_sfx(boss_entrance_voice_player)

func stop_battle_voiceovers() -> void:
	last_hero_attack_shout_index = -1
	for player in [hero_attack_shout_player, boss_entrance_voice_player]:
		if player == null:
			continue
		player.stream_paused = false
		if player.playing:
			player.stop()

func set_battle_voiceovers_paused(is_paused: bool) -> void:
	for player in [hero_attack_shout_player, boss_entrance_voice_player]:
		if player != null:
			player.stream_paused = is_paused

func play_hero_ultimate_start() -> void:
	if sfx_players.is_empty():
		return
	var player := _next_sfx_player()
	player.stream = HERO_ULTIMATE_START_STREAM
	player.volume_db = -1.0
	player.pitch_scale = 1.0
	player.play()

func play_hero_firewheel_loop() -> void:
	if firewheel_loop_player == null:
		return
	if firewheel_loop_player.playing:
		firewheel_loop_player.stop()
	firewheel_loop_player.stream_paused = false
	firewheel_loop_player.pitch_scale = 1.0
	firewheel_loop_player.play()

func stop_hero_firewheel_loop() -> void:
	if firewheel_loop_player != null and firewheel_loop_player.playing:
		firewheel_loop_player.stop()

func set_hero_firewheel_loop_paused(is_paused: bool) -> void:
	if firewheel_loop_player != null:
		firewheel_loop_player.stream_paused = is_paused

func start_tianji_sound(skill_id: String, duration: float) -> void:
	var player := tianji_sound_players.get(skill_id) as AudioStreamPlayer
	if player == null:
		return
	var safe_duration := maxf(0.0, duration)
	if safe_duration <= 0.0 or float(tianji_sound_remaining.get(skill_id, 0.0)) > 0.0:
		return
	tianji_sound_remaining[skill_id] = safe_duration
	tianji_sound_tail_delay[skill_id] = 0.0
	tianji_sound_tail_remaining[skill_id] = 0.0
	player.volume_db = float(tianji_sound_base_volume.get(skill_id, player.volume_db))
	player.stream_paused = false
	player.pitch_scale = 1.0
	player.play()
	if tianji_sounds_paused:
		player.stream_paused = true

func stop_tianji_sound(skill_id: String) -> void:
	tianji_sound_remaining[skill_id] = 0.0
	tianji_sound_tail_delay[skill_id] = 0.0
	tianji_sound_tail_remaining[skill_id] = 0.0
	var player := tianji_sound_players.get(skill_id) as AudioStreamPlayer
	if player == null:
		return
	player.stream_paused = false
	if player.playing:
		player.stop()

func stop_all_tianji_sounds() -> void:
	for skill_id in tianji_sound_players.keys():
		stop_tianji_sound(str(skill_id))
	tianji_sounds_paused = false

func set_tianji_sounds_paused(is_paused: bool) -> void:
	tianji_sounds_paused = is_paused
	for skill_id in tianji_sound_players.keys():
		var player := tianji_sound_players[skill_id] as AudioStreamPlayer
		var active := float(tianji_sound_remaining.get(skill_id, 0.0)) > 0.0
		var tailing := float(tianji_sound_tail_delay.get(skill_id, 0.0)) > 0.0 or float(tianji_sound_tail_remaining.get(skill_id, 0.0)) > 0.0
		if player == null or (not active and not tailing):
			continue
		player.stream_paused = is_paused
		if not is_paused and active and not player.playing:
			player.play()

func start_enemy_duel_cheers() -> void:
	if enemy_duel_cheer_player == null:
		return
	enemy_duel_cheers_enabled = true
	enemy_duel_cheers_paused = false
	enemy_duel_cheer_wait_remaining = -1.0
	enemy_duel_cheer_player.stream_paused = false
	enemy_duel_cheer_player.play()

func stop_enemy_duel_cheers() -> void:
	enemy_duel_cheers_enabled = false
	enemy_duel_cheers_paused = false
	enemy_duel_cheer_wait_remaining = -1.0
	if enemy_duel_cheer_player != null:
		enemy_duel_cheer_player.stream_paused = false
		if enemy_duel_cheer_player.playing:
			enemy_duel_cheer_player.stop()

func set_enemy_duel_cheers_paused(is_paused: bool) -> void:
	enemy_duel_cheers_paused = is_paused
	if enemy_duel_cheer_player != null and enemy_duel_cheer_player.playing:
		enemy_duel_cheer_player.stream_paused = is_paused

func play_title_bgm() -> void:
	title_bgm_enabled = true
	battle_bgm_enabled = false
	_switch_music_to(title_bgm_player, battle_bgm_player)

func stop_title_bgm() -> void:
	title_bgm_enabled = false
	_stop_music_player(title_bgm_player)

func play_battle_bgm() -> void:
	title_bgm_enabled = false
	battle_bgm_enabled = true
	_switch_music_to(battle_bgm_player, title_bgm_player)

func stop_battle_bgm() -> void:
	battle_bgm_enabled = false
	_stop_music_player(battle_bgm_player)

func set_battle_bgm_paused(is_paused: bool) -> void:
	if battle_bgm_player != null:
		battle_bgm_player.stream_paused = is_paused

func play_enemy_battle_voice() -> void:
	_play_random(ENEMY_AMBIENCE_STREAMS, -17.0)

func _on_enemy_duel_cheer_finished() -> void:
	if enemy_duel_cheers_enabled:
		enemy_duel_cheer_wait_remaining = randf_range(DUEL_CHEER_INTERVAL_MIN, DUEL_CHEER_INTERVAL_MAX)

func _on_battle_bgm_finished() -> void:
	if battle_bgm_enabled and battle_bgm_player != null:
		battle_bgm_player.volume_db = MUSIC_PLAYER_VOLUME_DB
		battle_bgm_player.play()

func _on_title_bgm_finished() -> void:
	if title_bgm_enabled and title_bgm_player != null:
		title_bgm_player.volume_db = MUSIC_PLAYER_VOLUME_DB
		title_bgm_player.play()

func _create_music_player(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = MUSIC_BUS_NAME
	player.stream = stream
	player.volume_db = MUSIC_PLAYER_VOLUME_DB
	add_child(player)
	return player

func _create_sfx_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = SFX_BUS_NAME
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	return player

func _register_tianji_sound(skill_id: String, stream: AudioStream, volume_db: float) -> void:
	var player := _create_sfx_player(stream, volume_db)
	tianji_sound_players[skill_id] = player
	tianji_sound_remaining[skill_id] = 0.0
	tianji_sound_tail_delay[skill_id] = 0.0
	tianji_sound_tail_remaining[skill_id] = 0.0
	tianji_sound_base_volume[skill_id] = volume_db
	player.finished.connect(_on_tianji_sound_finished.bind(skill_id))

func _tick_tianji_sounds(delta: float) -> void:
	if tianji_sounds_paused:
		return
	for raw_skill_id in tianji_sound_remaining.keys():
		var skill_id := str(raw_skill_id)
		var previous_remaining := float(tianji_sound_remaining[skill_id])
		var remaining := maxf(0.0, previous_remaining - delta)
		if previous_remaining > 0.0:
			tianji_sound_remaining[skill_id] = remaining
			if remaining > 0.0:
				continue
		elif float(tianji_sound_tail_delay.get(skill_id, 0.0)) <= 0.0 and float(tianji_sound_tail_remaining.get(skill_id, 0.0)) <= 0.0:
			# An idle sound must not enter a fade tail on every audio frame.
			continue
		if previous_remaining > 0.0:
			tianji_sound_tail_delay[skill_id] = TIANJI_SOUND_TAIL_DELAY
			tianji_sound_tail_remaining[skill_id] = TIANJI_SOUND_FADE_DURATION
			var tail_player := tianji_sound_players.get(skill_id) as AudioStreamPlayer
			if tail_player != null and not tail_player.playing:
				tail_player.volume_db = float(tianji_sound_base_volume.get(skill_id, tail_player.volume_db))
				tail_player.play()
		var delay := maxf(0.0, float(tianji_sound_tail_delay.get(skill_id, 0.0)) - delta)
		tianji_sound_tail_delay[skill_id] = delay
		if delay > 0.0:
			continue
		var tail_remaining := maxf(0.0, float(tianji_sound_tail_remaining.get(skill_id, 0.0)) - delta)
		tianji_sound_tail_remaining[skill_id] = tail_remaining
		var player := tianji_sound_players.get(skill_id) as AudioStreamPlayer
		if player != null and player.playing:
			var fade_progress := 1.0 - tail_remaining / TIANJI_SOUND_FADE_DURATION
			var base_volume := float(tianji_sound_base_volume.get(skill_id, -1.5))
			player.volume_db = lerpf(base_volume, SILENT_VOLUME_DB, fade_progress)
		if tail_remaining <= 0.0:
			stop_tianji_sound(skill_id)

func _on_tianji_sound_finished(skill_id: String) -> void:
	if tianji_sounds_paused or float(tianji_sound_remaining.get(skill_id, 0.0)) <= 0.0:
		return
	var player := tianji_sound_players.get(skill_id) as AudioStreamPlayer
	if player != null:
		player.play()

func _play_dedicated_sfx(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	player.stream_paused = false
	player.pitch_scale = 1.0
	player.play()

func _switch_music_to(target: AudioStreamPlayer, other: AudioStreamPlayer) -> void:
	if target == null:
		return
	if music_transition != null and music_transition.is_valid():
		music_transition.kill()
	if target.playing:
		target.stream_paused = false
		target.volume_db = MUSIC_PLAYER_VOLUME_DB
		if other != null and other.playing:
			other.stop()
		return
	target.volume_db = -80.0 if other != null and other.playing else MUSIC_PLAYER_VOLUME_DB
	target.stream_paused = false
	target.play()
	if other == null or not other.playing:
		target.volume_db = MUSIC_PLAYER_VOLUME_DB
		return
	music_transition = create_tween().set_parallel(true)
	music_transition.tween_property(other, "volume_db", -80.0, MUSIC_CROSSFADE_DURATION)
	music_transition.tween_property(target, "volume_db", MUSIC_PLAYER_VOLUME_DB, MUSIC_CROSSFADE_DURATION)
	music_transition.chain().tween_callback(other.stop)

func _stop_music_player(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	if music_transition != null and music_transition.is_valid():
		music_transition.kill()
	if player.playing:
		player.stop()
	player.volume_db = MUSIC_PLAYER_VOLUME_DB

func _play_random(streams: Array[AudioStream], volume_db: float) -> void:
	if streams.is_empty() or sfx_players.is_empty():
		return
	var player := _next_sfx_player()
	player.stream = streams[randi() % streams.size()]
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.96, 1.04)
	player.play()

func _next_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	var player := sfx_players[sfx_cursor]
	sfx_cursor = (sfx_cursor + 1) % sfx_players.size()
	return player

func _ensure_audio_bus(bus_name: StringName) -> int:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		return bus_index
	AudioServer.add_bus()
	bus_index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, &"Master")
	return bus_index

func _set_bus_linear_volume(bus_index: int, value: float) -> void:
	if bus_index < 0:
		return
	var clamped_value := clampf(value, 0.0, 1.0)
	var volume_db := SILENT_VOLUME_DB if clamped_value <= 0.001 else linear_to_db(clamped_value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
