extends Node

const CONFIG_SCRIPT := preload("res://autoload/taptap_config.gd")
const CONFIG_PATH := "res://taptap_local.cfg"
const DEFAULT_PRIVACY_URL := ""
const PRIVACY_POLICY_PATH := "res://privacy_policy.txt"
const USER_AGREEMENT_PATH := "res://user_agreement.txt"
const THIRD_PARTY_LIST_PATH := "res://third_party_info_list.txt"
const PRIVACY_CONSENT_PATH := "user://privacy_consent.cfg"
const PRIVACY_POLICY_VERSION := "2026-09-12-taptap-oaid-consent"
const PRIVACY_POLICY_FALLBACK := """隐私保护提示

欢迎使用《三国：破阵无双》。在您点击“同意并继续”前，游戏不会主动调用 TapTap SDK 的初始化接口，也不会通过该 SDK 收集设备标识信息。

经您明确同意后，我们会初始化 TapTap SDK（易玩（上海）网络科技有限公司）用于 TapTap 登录、实名认证和防沉迷校验。该 SDK 将收集您的 OAID、Android ID、设备型号、系统版本、网络信息及 TapTap 账号认证信息，用于设备识别、登录安全、实名认证、防沉迷、反作弊和服务稳定运行。相关信息由该 SDK 按其隐私政策处理。

您可以拒绝同意，拒绝后将无法使用 TapTap 登录、实名认证和防沉迷校验相关功能。
"""
signal gate_ready
signal auth_state_changed

const COMPLIANCE_OK := 500
const COMPLIANCE_EXITED := 1000
const COMPLIANCE_SWITCH := 1001
const COMPLIANCE_PERIOD := 1030
const COMPLIANCE_DURATION := 1050
const COMPLIANCE_AGE := 1100
const COMPLIANCE_NETWORK := 1200
const COMPLIANCE_REALNAME_STOP := 9002
const LOGIN_OK := 200
const LOGIN_FAIL := 400
const LOGIN_CANCEL := 499

var client_id := ""
var client_token := ""
var privacy_url := DEFAULT_PRIVACY_URL
var gate_is_ready := false
var sdk_ready := false
var last_compliance_code := -1
var status_message := ""
var login_in_flight := false
var compliance_in_flight := false
var _flow_timeout: SceneTreeTimer
const FLOW_TIMEOUT_SECONDS := 12.0
var overlay: CanvasLayer
var _overlay_root: Control
var _panel: Panel
var _title_label: Label
var _body_label: Label
var _primary_button: Button
var _secondary_button: Button
var _phase := ""
var _connected_sdk := false
var _privacy_consent_pending := false
var _privacy_dialog: Control
var _privacy_agree_check: CheckBox
var _privacy_checkbox_unchecked: Texture2D
var _privacy_checkbox_checked: Texture2D
var _gate_finish_pending := false
const SDK_INIT_SETTLE_SECONDS := 0.8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_privacy_checkbox_unchecked = load("res://assets/art/ui/privacy_checkbox_unchecked.svg") as Texture2D
	_privacy_checkbox_checked = load("res://assets/art/ui/privacy_checkbox_checked.svg") as Texture2D
	_load_local_config()
	if DisplayServer.get_name() == "headless":
		_finish_gate()
		return
	_build_overlay()
	if overlay != null:
		overlay.hide()
	if _has_privacy_consent():
		_init_sdk()
	else:
		_show_privacy_consent()

func requires_taptap_login() -> bool:
	return OS.has_feature("android")

func allows_title_touch_enter() -> bool:
	return not requires_taptap_login()

func is_logged_in() -> bool:
	if not requires_taptap_login():
		return false
	var tap := _tap()
	return tap != null and tap.isLogin()

func is_blocked() -> bool:
	return last_compliance_code in [COMPLIANCE_PERIOD, COMPLIANCE_DURATION, COMPLIANCE_AGE]

func block_message() -> String:
	match last_compliance_code:
		COMPLIANCE_PERIOD:
			return "当前时段不可游戏"
		COMPLIANCE_DURATION:
			return "今日游戏时长已用尽"
		COMPLIANCE_AGE:
			return "未达到游戏适龄要求"
		COMPLIANCE_NETWORK:
			return "网络或应用配置异常，请重试"
		COMPLIANCE_REALNAME_STOP:
			return "请完成实名认证后再进入"
		_:
			return status_message

func title_prompt_text() -> String:
	if not requires_taptap_login():
		return ""
	if not gate_is_ready:
		return "正在准备…"
	if is_blocked():
		return block_message()
	if login_in_flight:
		return "正在登录…"
	if compliance_in_flight:
		return "正在进入…"
	return ""

func should_show_login_button() -> bool:
	return requires_taptap_login() and gate_is_ready and last_compliance_code != COMPLIANCE_OK and not login_in_flight and not compliance_in_flight and not is_blocked()

func start_title_flow() -> void:
	if not requires_taptap_login() or not gate_is_ready:
		return
	login_in_flight = false
	compliance_in_flight = false
	last_compliance_code = -1
	status_message = ""
	if is_logged_in():
		start_compliance()
		return
	auth_state_changed.emit()
	var tree := get_tree()
	if tree != null:
		tree.create_timer(0.8).timeout.connect(_retry_cached_session)
		tree.create_timer(2.0).timeout.connect(_retry_cached_session)

func _retry_cached_session() -> void:
	if last_compliance_code == COMPLIANCE_OK or login_in_flight or compliance_in_flight:
		return
	if is_logged_in():
		start_compliance()

func start_login() -> void:
	if login_in_flight or compliance_in_flight or not gate_is_ready:
		return
	if not requires_taptap_login():
		return
	var tap := _tap()
	if tap == null:
		status_message = "未检测到 TapTap 插件"
		auth_state_changed.emit()
		return
	last_compliance_code = -1
	login_in_flight = true
	status_message = "正在登录…"
	auth_state_changed.emit()
	_arm_flow_timeout()
	tap.tap_login()

func start_compliance() -> void:
	if compliance_in_flight or not gate_is_ready:
		return
	if not requires_taptap_login():
		return
	var tap := _tap()
	if tap == null or not tap.isLogin():
		login_in_flight = false
		compliance_in_flight = false
		status_message = "请先登录 TapTap"
		auth_state_changed.emit()
		return
	compliance_in_flight = true
	status_message = "正在校验…"
	auth_state_changed.emit()
	_arm_flow_timeout()
	tap.quickCheck()

func _arm_flow_timeout() -> void:
	if _flow_timeout != null and is_instance_valid(_flow_timeout):
		if _flow_timeout.timeout.is_connected(_on_flow_timeout):
			_flow_timeout.timeout.disconnect(_on_flow_timeout)
	_flow_timeout = get_tree().create_timer(FLOW_TIMEOUT_SECONDS)
	_flow_timeout.timeout.connect(_on_flow_timeout)

func _on_flow_timeout() -> void:
	if not login_in_flight and not compliance_in_flight:
		return
	login_in_flight = false
	compliance_in_flight = false
	last_compliance_code = -1
	status_message = "登录超时，请重试"
	auth_state_changed.emit()

func _tap() -> Node:
	return get_node_or_null("/root/GodotTapTap")

func _load_local_config() -> void:
	client_id = str(CONFIG_SCRIPT.CLIENT_ID)
	client_token = str(CONFIG_SCRIPT.CLIENT_TOKEN)
	privacy_url = str(CONFIG_SCRIPT.PRIVACY_URL)
	if privacy_url.is_empty():
		privacy_url = DEFAULT_PRIVACY_URL
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	var cfg_id := str(cfg.get_value("taptap", "client_id", ""))
	var cfg_token := str(cfg.get_value("taptap", "client_token", ""))
	if not cfg_id.is_empty():
		client_id = cfg_id
	if not cfg_token.is_empty():
		client_token = cfg_token
	var cfg_privacy := str(cfg.get_value("taptap", "privacy_url", ""))
	if not cfg_privacy.is_empty():
		privacy_url = cfg_privacy

func _connect_sdk_signals() -> void:
	if _connected_sdk:
		return
	var tap := _tap()
	if tap == null:
		return
	if not tap.onLoginResult.is_connected(_on_login_result):
		tap.onLoginResult.connect(_on_login_result)
	if not tap.onAntiAddictionCallback.is_connected(_on_compliance_result):
		tap.onAntiAddictionCallback.connect(_on_compliance_result)
	_connected_sdk = true

func _init_sdk() -> void:
	_connect_sdk_signals()
	if not requires_taptap_login():
		sdk_ready = true
		_finish_gate()
		return
	if client_id.is_empty() or client_token.is_empty():
		_show_message("配置缺失", "未找到 TapTap Client ID 或 Token\n请重新导出后再试", "退出", _quit_game)
		return
	var tap := _tap()
	if tap == null:
		_show_message("插件未启用", "未找到 GodotTapTap\n请启用插件后用 Gradle 导出", "退出", _quit_game)
		return
	tap.initialize(client_id, client_token, "CN", OS.is_debug_build())
	sdk_ready = true
	# TapTap's native initialize() registers callbacks asynchronously.  Do not
	# query isLogin/quickCheck in the same frame, or the SDK reports that the
	# application has not been initialized even though initialization is queued.
	_defer_finish_gate()

func _defer_finish_gate() -> void:
	if gate_is_ready or _gate_finish_pending:
		return
	_gate_finish_pending = true
	var tree := get_tree()
	if tree == null:
		_gate_finish_pending = false
		_finish_gate()
		return
	tree.create_timer(SDK_INIT_SETTLE_SECONDS).timeout.connect(_finish_gate)

func _has_privacy_consent() -> bool:
	var file := FileAccess.open(PRIVACY_CONSENT_PATH, FileAccess.READ)
	return file != null and file.get_as_text().strip_edges() == "accepted:%s" % PRIVACY_POLICY_VERSION

func _save_privacy_consent() -> void:
	var file := FileAccess.open(PRIVACY_CONSENT_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string("accepted:%s" % PRIVACY_POLICY_VERSION)

func _show_privacy_consent() -> void:
	if _privacy_consent_pending or overlay == null:
		return
	_privacy_consent_pending = true
	overlay.show()
	_phase = "privacy"
	_title_label.text = "隐私保护提示"
	_body_label.hide()
	_primary_button.hide()
	_secondary_button.hide()
	var panel := _panel
	_set_privacy_panel_size(panel, true)
	_center_panel()
	var policy := RichTextLabel.new()
	policy.name = "PrivacyPolicyText"
	policy.bbcode_enabled = false
	policy.text = _load_privacy_policy()
	policy.scroll_active = true
	policy.fit_content = false
	policy.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	policy.add_theme_font_override("normal_font", UITheme.default_font())
	policy.add_theme_color_override("default_color", Color.WHITE)
	var policy_style := StyleBoxFlat.new()
	policy_style.bg_color = Color("050505")
	policy_style.content_margin_left = 18.0
	policy_style.content_margin_top = 14.0
	policy_style.content_margin_right = 18.0
	policy_style.content_margin_bottom = 14.0
	policy.add_theme_stylebox_override("normal", policy_style)
	panel.add_child(policy)
	_layout_privacy_policy(policy, true)
	var links := HBoxContainer.new()
	links.name = "PrivacyLinks"
	var compact_layout := _panel.size.x < 520.0
	links.position = Vector2(18.0, _panel.size.y - (136.0 if compact_layout else 156.0))
	links.size = Vector2(_panel.size.x - 36.0, 32.0)
	links.alignment = BoxContainer.ALIGNMENT_CENTER
	links.add_theme_constant_override("separation", 8)
	links.add_theme_font_override("font", UITheme.default_font())
	panel.add_child(links)
	for item in [["用户协议", USER_AGREEMENT_PATH], ["隐私政策", PRIVACY_POLICY_PATH], ["第三方信息共享清单", THIRD_PARTY_LIST_PATH]]:
		var link := LinkButton.new()
		link.text = item[0]
		link.add_theme_font_size_override("font_size", 15)
		link.pressed.connect(_show_local_document.bind(str(item[0]), str(item[1])))
		links.add_child(link)
	_privacy_agree_check = CheckBox.new()
	_privacy_agree_check.name = "PrivacyAgreeCheck"
	_privacy_agree_check.text = "我已阅读并同意以上协议"
	var initial_action_y := _panel.size.y - (60.0 if compact_layout else 80.0)
	_privacy_agree_check.position = Vector2(28.0, initial_action_y - 40.0)
	_privacy_agree_check.size = Vector2(_panel.size.x - 44.0, 34.0)
	_privacy_agree_check.add_theme_font_override("font", UITheme.default_font())
	_privacy_agree_check.add_theme_font_size_override("font_size", 15 if compact_layout else 17)
	_privacy_agree_check.add_theme_color_override("font_color", UITheme.TEXT_SOFT)
	_privacy_agree_check.add_theme_color_override("font_hover_color", Color.WHITE)
	if _privacy_checkbox_unchecked != null and _privacy_checkbox_checked != null:
		_privacy_agree_check.add_theme_icon_override("unchecked", _privacy_checkbox_unchecked)
		_privacy_agree_check.add_theme_icon_override("checked", _privacy_checkbox_checked)
		_privacy_agree_check.add_theme_icon_override("unchecked_disabled", _privacy_checkbox_unchecked)
		_privacy_agree_check.add_theme_icon_override("checked_disabled", _privacy_checkbox_checked)
	_privacy_agree_check.add_theme_constant_override("h_separation", 10)
	_panel.add_child(_privacy_agree_check)
	var agree := Button.new()
	agree.text = "同意并继续"
	_style_action_button(agree)
	agree.pressed.connect(_accept_privacy_consent)
	agree.disabled = true
	_privacy_agree_check.toggled.connect(func(checked: bool): agree.disabled = not checked)
	panel.add_child(agree)
	var reject := Button.new()
	reject.text = "不同意并退出"
	_style_action_button(reject)
	reject.pressed.connect(_reject_privacy_consent)
	panel.add_child(reject)
	_layout_privacy_actions(agree, reject)

func show_privacy_policy() -> void:
	if overlay == null:
		return
	_remove_policy_view_children()
	overlay.show()
	_phase = "privacy_view"
	_title_label.text = "隐私政策"
	_body_label.hide()
	_primary_button.hide()
	_secondary_button.hide()
	_set_privacy_panel_size(_panel, false)
	_center_panel()
	var policy := RichTextLabel.new()
	policy.name = "PrivacyPolicyText"
	policy.bbcode_enabled = false
	policy.text = _load_privacy_policy()
	policy.scroll_active = true
	policy.fit_content = false
	policy.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	policy.add_theme_font_override("normal_font", UITheme.default_font())
	policy.add_theme_color_override("default_color", Color.WHITE)
	var policy_style := StyleBoxFlat.new()
	policy_style.bg_color = Color("050505")
	policy_style.content_margin_left = 18.0
	policy_style.content_margin_top = 14.0
	policy_style.content_margin_right = 18.0
	policy_style.content_margin_bottom = 14.0
	policy.add_theme_stylebox_override("normal", policy_style)
	_panel.add_child(policy)
	_layout_privacy_policy(policy, false)
	var close_button := Button.new()
	close_button.name = "PrivacyPolicyClose"
	close_button.text = "返回" if _privacy_consent_pending else "关闭"
	_style_action_button(close_button)
	close_button.pressed.connect(_close_privacy_policy)
	_panel.add_child(close_button)
	_layout_privacy_actions(close_button, null)

func _show_local_document(title: String, path: String) -> void:
	call_deferred("_show_local_document_deferred", title, path)

func _show_local_document_deferred(title: String, path: String) -> void:
	_remove_policy_view_children()
	await get_tree().process_frame
	if not is_instance_valid(_panel) or not is_instance_valid(_title_label):
		return
	_title_label.text = title
	var document := RichTextLabel.new()
	document.name = "PrivacyPolicyText"
	document.bbcode_enabled = false
	document.text = _load_document(path)
	document.scroll_active = true
	document.fit_content = false
	document.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	document.add_theme_font_override("normal_font", UITheme.default_font())
	document.add_theme_font_size_override("normal_font_size", 15 if _panel.size.x < 520.0 else 17)
	document.add_theme_color_override("default_color", Color.WHITE)
	_panel.add_child(document)
	_layout_privacy_policy(document, false)
	var close_button := Button.new()
	close_button.name = "PrivacyPolicyClose"
	close_button.text = "返回" if _privacy_consent_pending else "关闭"
	_style_action_button(close_button)
	close_button.pressed.connect(_close_privacy_policy)
	_panel.add_child(close_button)
	_layout_privacy_actions(close_button, null)

func _load_document(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	return file.get_as_text() if file != null else "协议内容暂时无法读取，请稍后重试。"

func _close_privacy_policy() -> void:
	call_deferred("_close_privacy_policy_deferred")

func _close_privacy_policy_deferred() -> void:
	var return_to_consent := _privacy_consent_pending
	_remove_policy_view_children()
	_panel.size = Vector2(720.0, 460.0)
	_body_label.show()
	_center_panel()
	overlay.hide()
	_phase = "ready"
	if return_to_consent:
		_privacy_consent_pending = false
		await get_tree().process_frame
		_show_privacy_consent()

func _remove_policy_view_children() -> void:
	if _panel == null:
		return
	for child in _panel.get_children():
		if child.name in ["PrivacyPolicyText", "PrivacyPolicyClose", "PrivacyAgree", "PrivacyReject", "PrivacyLinks", "PrivacyAgreeCheck"]:
			child.queue_free()
	_privacy_agree_check = null

func _load_privacy_policy() -> String:
	var file := FileAccess.open(PRIVACY_POLICY_PATH, FileAccess.READ)
	if file == null:
		push_warning("Privacy policy resource is missing from the exported package: %s" % PRIVACY_POLICY_PATH)
		return PRIVACY_POLICY_FALLBACK
	return file.get_as_text()

func _set_privacy_panel_size(panel: Panel, consent: bool) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x < 2.0 or viewport_size.y < 2.0:
		viewport_size = Vector2(720.0, 460.0)
	var horizontal_margin := clampf(viewport_size.x * 0.04, 12.0, 32.0)
	var vertical_margin := clampf(viewport_size.y * 0.04, 12.0, 32.0)
	var width := minf(820.0, maxf(1.0, viewport_size.x - horizontal_margin * 2.0))
	var height := minf(620.0, maxf(1.0, viewport_size.y - vertical_margin * 2.0))
	panel.size = Vector2(width, height)
	_center_panel()
	var policy := panel.get_node_or_null("PrivacyPolicyText") as RichTextLabel
	if policy != null:
		_layout_privacy_policy(policy, consent)
	var primary := panel.get_node_or_null("PrivacyPolicyClose") as Button
	if primary != null:
		_layout_privacy_actions(primary, null)
	var agree := panel.get_node_or_null("PrivacyAgree") as Button
	var reject := panel.get_node_or_null("PrivacyReject") as Button
	if agree != null and reject != null:
		_layout_privacy_actions(agree, reject)
	var links := panel.get_node_or_null("PrivacyLinks") as HBoxContainer
	if links != null:
		var compact := panel.size.x < 520.0
		links.position = Vector2(18.0, panel.size.y - (136.0 if compact else 156.0))
		links.size = Vector2(maxf(1.0, panel.size.x - 36.0), 32.0)
		for child in links.get_children():
			var link := child as LinkButton
			if link != null:
				link.add_theme_font_size_override("font_size", 13 if compact else 15)
	var check := panel.get_node_or_null("PrivacyAgreeCheck") as CheckBox
	if check != null:
		var compact := panel.size.x < 520.0
		var action_y := panel.size.y - (60.0 if compact else 80.0)
		check.position = Vector2(28.0, action_y - 40.0)
		check.size = Vector2(maxf(1.0, panel.size.x - 44.0), 34.0)
		check.add_theme_font_size_override("font_size", 15 if compact else 17)

func _layout_privacy_policy(policy: RichTextLabel, consent: bool) -> void:
	var compact := _panel.size.x < 520.0
	var horizontal := 16.0 if compact else 30.0
	var top := 76.0 if compact else 82.0
	var bottom := (146.0 if compact else 166.0) if consent else 86.0
	policy.position = Vector2(horizontal, top)
	policy.size = Vector2(maxf(1.0, _panel.size.x - horizontal * 2.0), maxf(1.0, _panel.size.y - top - bottom))
	policy.add_theme_font_size_override("normal_font_size", 15 if compact else 17)

func _layout_privacy_actions(primary: Button, secondary: Button) -> void:
	var margin := 16.0 if _panel.size.x < 520.0 else 36.0
	var gap := 10.0
	var button_height := 44.0
	var button_width := minf(200.0, maxf(1.0, (_panel.size.x - margin * 2.0 - gap) * 0.5))
	var y := _panel.size.y - margin - button_height
	if secondary != null:
		secondary.name = "PrivacyReject"
		secondary.position = Vector2(margin, y)
		secondary.size = Vector2(button_width, button_height)
		primary.name = "PrivacyAgree"
		primary.position = Vector2(_panel.size.x - margin - button_width, y)
	else:
		primary.position = Vector2(_panel.size.x - margin - button_width, y)
	primary.size = Vector2(button_width, button_height)

func _style_action_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", UITheme.TEXT_MAIN)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", UITheme.button_style(UITheme.PANEL_FILL, UITheme.GOLD, 2))
	button.add_theme_stylebox_override("hover", UITheme.button_style(Color("1a2b33"), UITheme.DRAGON_BLUE, 3))
	button.add_theme_stylebox_override("pressed", UITheme.button_style(Color("2e291d"), UITheme.GOLD_BRIGHT, 3))

func _accept_privacy_consent() -> void:
	_save_privacy_consent()
	_privacy_consent_pending = false
	_remove_policy_view_children()
	_body_label.show()
	_init_sdk()

func _reject_privacy_consent() -> void:
	get_tree().quit()

func _finish_gate() -> void:
	_gate_finish_pending = false
	gate_is_ready = true
	_phase = "ready"
	if overlay != null:
		overlay.hide()
	gate_ready.emit()
	auth_state_changed.emit()

func _on_login_result(code, _json) -> void:
	login_in_flight = false
	if int(code) == LOGIN_OK:
		status_message = "登录成功"
		auth_state_changed.emit()
		start_compliance()
		return
	if int(code) == LOGIN_CANCEL:
		status_message = "已取消登录"
	else:
		status_message = "登录失败，请重试"
	auth_state_changed.emit()

func _on_compliance_result(code) -> void:
	compliance_in_flight = false
	last_compliance_code = int(code)
	match last_compliance_code:
		COMPLIANCE_OK:
			status_message = ""
		COMPLIANCE_PERIOD:
			status_message = "当前时段不可游戏"
		COMPLIANCE_DURATION:
			status_message = "今日游戏时长已用尽"
		COMPLIANCE_AGE:
			status_message = "未达到游戏适龄要求"
		COMPLIANCE_SWITCH, COMPLIANCE_EXITED:
			status_message = "请重新登录"
		COMPLIANCE_NETWORK:
			status_message = "网络或应用配置异常，请重试"
		COMPLIANCE_REALNAME_STOP:
			status_message = "请完成实名认证后再进入"
		_:
			status_message = "认证未通过（%d）" % last_compliance_code
	auth_state_changed.emit()

func _build_overlay() -> void:
	overlay = CanvasLayer.new()
	overlay.layer = 80
	add_child(overlay)
	_overlay_root = Control.new()
	_overlay_root.name = "PrivacyOverlayRoot"
	_overlay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(_overlay_root)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.03, 0.04, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root.add_child(dim)
	_panel = Panel.new()
	_panel.size = Vector2(720, 460)
	_panel.clip_contents = false
	_panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	_overlay_root.add_child(_panel)
	_title_label = Label.new()
	_title_label.position = Vector2(36, 28)
	_title_label.size = Vector2(648, 44)
	_title_label.clip_text = false
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", Color("f4d58d"))
	_panel.add_child(_title_label)
	_body_label = Label.new()
	_body_label.position = Vector2(36, 88)
	_body_label.size = Vector2(648, 250)
	_body_label.clip_text = false
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.add_theme_font_size_override("font_size", 18)
	_body_label.add_theme_color_override("font_color", Color("d8e6e2"))
	_panel.add_child(_body_label)
	_primary_button = Button.new()
	_primary_button.size = Vector2(200, 48)
	_primary_button.position = Vector2(484, 380)
	_primary_button.add_theme_stylebox_override("normal", UITheme.button_style(UITheme.PANEL_FILL, UITheme.GOLD, 2))
	_primary_button.add_theme_stylebox_override("hover", UITheme.button_style(Color("1a2b33"), UITheme.DRAGON_BLUE, 3))
	_primary_button.add_theme_stylebox_override("pressed", UITheme.button_style(Color("2e291d"), UITheme.GOLD_BRIGHT, 3))
	_panel.add_child(_primary_button)
	_secondary_button = Button.new()
	_secondary_button.size = Vector2(200, 48)
	_secondary_button.position = Vector2(36, 380)
	_secondary_button.add_theme_stylebox_override("normal", UITheme.button_style(UITheme.PANEL_FILL, UITheme.GOLD, 2))
	_secondary_button.add_theme_stylebox_override("hover", UITheme.button_style(Color("1a2b33"), UITheme.DRAGON_BLUE, 3))
	_secondary_button.add_theme_stylebox_override("pressed", UITheme.button_style(Color("2e291d"), UITheme.GOLD_BRIGHT, 3))
	_panel.add_child(_secondary_button)
	get_tree().root.size_changed.connect(_on_overlay_resized)
	_center_panel()

func _center_panel() -> void:
	if _panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var visible_size := Vector2(maxf(1.0, viewport_size.x), maxf(1.0, viewport_size.y))
	_panel.position = Vector2(maxf(0.0, (visible_size.x - _panel.size.x) * 0.5), maxf(0.0, (visible_size.y - _panel.size.y) * 0.5))

func _on_overlay_resized() -> void:
	if _panel == null:
		return
	if _phase == "privacy" or _phase == "privacy_view":
		_set_privacy_panel_size(_panel, _phase == "privacy")
	else:
		_center_panel()

func _show_message(title: String, body: String, action_title: String, action: Callable) -> void:
	_phase = "message"
	overlay.show()
	_title_label.text = title
	_body_label.text = body
	_secondary_button.hide()
	_primary_button.show()
	_primary_button.disabled = false
	_primary_button.text = action_title
	_clear_button_signals(_primary_button)
	_primary_button.pressed.connect(action)

func _quit_game() -> void:
	get_tree().quit()

func _clear_button_signals(button: Button) -> void:
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection["callable"])
