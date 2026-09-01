extends Node

# The native bridge is deliberately provider-neutral. Its implementation is added
# with the Android ad SDK once the app and ad-unit configuration is available.
const NATIVE_BRIDGE_NAME := "RewardedAdBridge"

const PLACEMENT_SHOP_MERIT := "shop_merit_500"
const PLACEMENT_UPGRADE_REFRESH := "upgrade_refresh"
const PLACEMENT_REVIVE := "battle_revive"
const PLACEMENT_RESULT_DOUBLE := "result_double_merit"
const REWARDED_VIDEO_TIMEOUT_SECONDS := 90.0

signal rewarded_video_completed(placement: String, rewarded: bool, message: String)

var native_bridge: Object
var active_placement := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not Engine.has_singleton(NATIVE_BRIDGE_NAME):
		return
	var candidate := Engine.get_singleton(NATIVE_BRIDGE_NAME) as Object
	if candidate == null:
		return
	if not candidate.has_method("show_rewarded_video") or not candidate.has_signal("rewarded_video_completed"):
		push_warning("RewardedAdBridge must provide show_rewarded_video() and rewarded_video_completed.")
		return
	native_bridge = candidate
	native_bridge.connect("rewarded_video_completed", _on_native_rewarded_video_completed)

func show_rewarded_video(placement: String) -> bool:
	if placement.is_empty() or not active_placement.is_empty():
		return false
	active_placement = placement
	if native_bridge != null and native_bridge.has_method("show_rewarded_video"):
		var started: Variant = native_bridge.call("show_rewarded_video", placement)
		if bool(started):
			get_tree().create_timer(REWARDED_VIDEO_TIMEOUT_SECONDS, true).timeout.connect(_on_rewarded_video_timeout.bind(placement))
			return true
		_complete(placement, false, "广告暂不可用")
		return false
	if OS.is_debug_build():
		get_tree().create_timer(0.35, true).timeout.connect(_complete.bind(placement, true, "开发模拟：广告奖励已发放"))
		return true
	_complete(placement, false, "广告服务尚未配置")
	return false

func is_showing_rewarded_video() -> bool:
	return not active_placement.is_empty()

func uses_development_simulation() -> bool:
	return native_bridge == null and OS.is_debug_build()

func _on_native_rewarded_video_completed(placement: String, rewarded: bool, message: String = "") -> void:
	_complete(placement, rewarded, message)

func _on_rewarded_video_timeout(placement: String) -> void:
	_complete(placement, false, "广告响应超时，请稍后再试")

func _complete(placement: String, rewarded: bool, message: String) -> void:
	if placement.is_empty() or placement != active_placement:
		return
	active_placement = ""
	rewarded_video_completed.emit(placement, rewarded, message)
