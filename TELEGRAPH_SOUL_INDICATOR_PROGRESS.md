# Telegraph / Soul 修复进度

目标：修复 telegraph 快照遍历顺序与回调同步删除安全性，补齐真实动态回归，并将战魂 HUD 指示器与 Boss 指示器安全分离。

- [x] 读取最新源码并确认 6 处 telegraph 快照循环、_tick_telegraphs、HUD 排布与现有测试
- [x] 为 6 处 telegraphs.duplicate() 快照恢复 reverse 顺序
- [x] 修复 _tick_telegraphs 回调后 live membership 检查，避免已移除对象继续结算
- [x] 将正式 telegraph_soul_indicator_regression.gd 扩展为真实动态回归
- [x] 将战魂 HUD 槽位间距提升到至少 54，保持 Boss slot 0 位置并校验边缘安全
- [x] 执行 headless regression、GPU 截图与解析、git diff 核验
- [x] 写入实际通过项数、动态用例结果、截图路径和未完成项

## 实际验证结果

- Headless：`REGRESSION checks=34 failures=0`，日志：`任务_0929_先不写代码有几个问题1马/telegraph_soul_headless.log`
- 动态 telegraph 用例：通过 guard false 同步删除当前/另一个、`clear`、新 append；late false 删除当前；hero `receive_damage` 同步删除当前/另一个、`clear`、新 append；无伤害重复、无越界；新项下一 tick 结算；同 `hit_group` 按倒序优先级只结算一次。
- Soul 生命周期/视野：真实 pickup 与过期清理通过；真实 `_update_battle_soul_indicators()` 通过 camera rect 子类 override 验证迟滞状态与过期清理。
- GPU：通过 Vulkan/NVIDIA 渲染回归，截图：`任务_0929_先不写代码有几个问题1马/telegraph-soul-indicators.png`；解析为 `1280x720`，非空 RGB 像素 `921598/921600`。
- Diff：目标源码已核对，`git diff --check` 无空白错误。工作区另有前序/用户改动，未回滚。
