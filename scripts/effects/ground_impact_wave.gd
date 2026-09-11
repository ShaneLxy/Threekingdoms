extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# The source is a 1920x1080 full-canvas animation. Its ground contact is in
# the lower-right quadrant rather than at the canvas center.
const SOURCE_CONTACT_OFFSET := Vector2(-320.0, -300.0)

func _ready() -> void:
	sprite.offset = SOURCE_CONTACT_OFFSET
	sprite.play("default")
	sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	queue_free()

func set_scale_multiplier(multiplier: float) -> void:
	scale = Vector2.ONE * multiplier
