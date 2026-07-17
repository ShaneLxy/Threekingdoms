# 架构决策记录（ADR）

> ADR 记录关键且难以逆转的技术决定。状态为“已接受”的记录不直接修改；方案变化时新增一份 Supersedes ADR。

| ADR | 状态 | 决策 |
|---|---|---|
| [0001](0001-hybrid-enemy-representation.md) | 已接受 | 普通敌军采用批量模拟，玩家/Boss/精英采用组合式 Actor。 |
| [0002](0002-run-scene-local-state-and-minimal-autoloads.md) | 已接受 | 局内状态归 RunScene，使用最少 AutoLoad。 |
| [0003](0003-resource-driven-content-definitions.md) | 已接受 | 用 Resource 定义内容，运行时状态与定义分离。 |
| [0004](0004-mobile-rendering-target.md) | 已接受 | Android 以 Mobile（Vulkan）渲染器为默认路径，并定义参考/最低设备档。 |

每份 ADR 必须包含：背景、决定、正负后果、关联设计需求，以及引擎兼容性说明。
