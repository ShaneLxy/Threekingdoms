extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# The source is a 1920x1080 full-canvas animation. Its ground contact is in
# the lower-right quadrant rather than at the canvas center.
const SOURCE_CONTACT_OFFSET := Vector2(-320.0, -300.0)
const FRAME_HOLD := 1.0 / 24.0

var _flip_h := false
var _max_frame := -1
var _uniform_scale := 1.0
var _speed_scale := 1.0
var _has_custom_scale := false
var _stopping := false

func configure(options: Dictionary) -> void:
	_flip_h = bool(options.get("flip_h", false))
	_max_frame = int(options.get("max_frame", -1))
	_uniform_scale = float(options.get("scale", 1.0))
	_speed_scale = float(options.get("speed_scale", 1.0))

func _ready() -> void:
	if not _has_custom_scale:
		scale = Vector2.ONE * _uniform_scale
	sprite.flip_h = _flip_h
	sprite.offset = Vector2(-SOURCE_CONTACT_OFFSET.x if _flip_h else SOURCE_CONTACT_OFFSET.x, SOURCE_CONTACT_OFFSET.y)
	sprite.speed_scale = _speed_scale
	sprite.play("default")
	if _max_frame >= 0:
		sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_frame_changed() -> void:
	if _stopping or _max_frame < 0:
		return
	if sprite.frame >= _max_frame:
		_stopping = true
		sprite.pause()
		sprite.frame = _max_frame
		get_tree().create_timer(FRAME_HOLD / maxf(0.01, _speed_scale)).timeout.connect(queue_free)

func _on_animation_finished() -> void:
	if _stopping:
		return
	queue_free()

func set_scale_multiplier(multiplier: Variant) -> void:
	if multiplier is Vector2:
		scale = multiplier
	else:
		scale = Vector2.ONE * float(multiplier)
	_has_custom_scale = true
