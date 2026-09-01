# 激励视频接入说明

## 当前业务入口

`AdService` 统一处理激励视频展示和回调，当前已经接入以下奖励：

1. 商城军功栏的 `+`：成功观看后获得 500 军功。
2. 战斗三选一：基础刷新 2 次耗尽后，成功观看后额外刷新一次；每局最多 3 次。
3. 阵亡：成功观看后以 35% 生命复活；每局最多 1 次。
4. 结算：基础军功先结算，成功观看后补发等额军功；每局最多领取 1 次。

广告未完成、展示失败或超时均不发奖励。`AdService` 同一时间只允许一个广告请求。

## Godot 与 DCloud 的集成边界

当前项目是 Godot Android 工程，而非 uni-app 运行时。因此不能直接在 GDScript 中调用 `uni.createRewardedVideoAd`。如果选择 DCloud 的 uni-AD 或其合作渠道，需要把对应 Android SDK 放入 Godot 的自定义 Gradle 构建，并通过 Godot Android 插件暴露给 GDScript。

现有 Android 导出预设尚未启用 `gradle_build/use_gradle_build`；接入原生 SDK 时需要先安装 Godot Android 构建模板并开启该选项。

## 原生桥接约定

原生插件注册的 Godot Engine singleton 名称固定为 `RewardedAdBridge`，并实现：

```text
method: show_rewarded_video(placement) -> bool
signal: rewarded_video_completed(placement, rewarded, message)
```

`show_rewarded_video` 只有在广告已成功发起展示时返回 `true`。广告关闭、加载失败、用户中途退出都必须发出 `rewarded=false` 的回调；只有 SDK 的奖励回调才可以发出 `rewarded=true`。原生层应按 `placement` 选择对应广告位，并确保每次展示只回调一次。

对应广告位：

| placement | 用途 |
| --- | --- |
| `shop_merit_500` | 商城获得 500 军功 |
| `upgrade_refresh` | 三选一广告刷新 |
| `battle_revive` | 阵亡复活 |
| `result_double_merit` | 结算军功翻倍 |

未配置原生桥接时，Debug 包会模拟广告成功，便于验证业务流程；Release 包会提示广告服务未配置且不会发奖。

## 接入前需要的资料

- 最终使用的广告方案：DCloud uni-AD，或具体聚合/渠道 SDK。
- Android 包名、应用 ID、App Key 等渠道应用配置。
- 四个激励视频广告位 ID；可先共用一个广告位，正式运营建议按四个 placement 分开配置以便统计与调优。
- 发布范围：仅 Android，或同时需要 iOS。
- 正式签名证书、包名是否确定，以及是否已在广告后台完成审核。
- 是否接受使用 Godot Android Gradle 自定义构建和原生 Java/Kotlin 桥接。
