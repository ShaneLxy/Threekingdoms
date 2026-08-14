extends Node

const HERO_ATTACK_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/hero/attack/attack.wav"),
	preload("res://assets/audio/hero/attack/attack2.mp3"),
	preload("res://assets/audio/hero/attack/attack3.mp3"),
	preload("res://assets/audio/hero/attack/attack4.wav"),
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
const BATTLE_BGM_STREAM: AudioStream = preload("res://assets/audio/battle/iron-siege-march.mp3")
const ENEMY_AMBIENCE_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/enemies/ambient/enemy-voice-01.wav"),
	preload("res://assets/audio/enemies/ambient/enemy-voice-02.wav"),
]
const SFX_PLAYER_COUNT := 12
const MUSIC_BUS_NAME := &"Music"
const SFX_BUS_NAME := &"SFX"
const SILENT_VOLUME_DB := -80.0

var master_volume_db := 0.0
var music_volume := 1.0
var sfx_volume := 1.0
var music_bus_index := -1
var sfx_bus_index := -1
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_cursor := 0
var firewheel_loop_player: AudioStreamPlayer
var battle_bgm_player: AudioStreamPlayer
var battle_bgm_enabled := false

func _ready() -> void:
	music_bus_index = _ensure_audio_bus(MUSIC_BUS_NAME)
	sfx_bus_index = _ensure_audio_bus(SFX_BUS_NAME)
	for _index in range(SFX_PLAYER_COUNT):
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS_NAME
		add_child(player)
		sfx_players.append(player)
	firewheel_loop_player = AudioStreamPlayer.new()
	firewheel_loop_player.bus = SFX_BUS_NAME
	firewheel_loop_player.stream = HERO_FIREWHEEL_LOOP_STREAM
	firewheel_loop_player.volume_db = -6.0
	add_child(firewheel_loop_player)
	battle_bgm_player = AudioStreamPlayer.new()
	battle_bgm_player.bus = MUSIC_BUS_NAME
	battle_bgm_player.stream = BATTLE_BGM_STREAM
	battle_bgm_player.volume_db = -9.0
	battle_bgm_player.finished.connect(_on_battle_bgm_finished)
	add_child(battle_bgm_player)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

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

func play_battle_bgm() -> void:
	if battle_bgm_player == null:
		return
	battle_bgm_enabled = true
	battle_bgm_player.stream_paused = false
	if not battle_bgm_player.playing:
		battle_bgm_player.play()

func stop_battle_bgm() -> void:
	battle_bgm_enabled = false
	if battle_bgm_player != null and battle_bgm_player.playing:
		battle_bgm_player.stop()

func set_battle_bgm_paused(is_paused: bool) -> void:
	if battle_bgm_player != null:
		battle_bgm_player.stream_paused = is_paused

func play_enemy_battle_voice() -> void:
	_play_random(ENEMY_AMBIENCE_STREAMS, -17.0)

func _on_battle_bgm_finished() -> void:
	if battle_bgm_enabled and battle_bgm_player != null:
		battle_bgm_player.play()

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
