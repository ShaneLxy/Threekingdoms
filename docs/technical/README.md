# 技术设计文档

> 状态：架构草案 v0.1  
> 最后更新：2026-07-12  
> 已确认引擎基线：Godot `4.7.stable.official.5b4e0cb0f`。

## 文档导航

- [Godot 技术架构](godot-architecture.md)：模块边界、数据流、场景树、性能分层与实施顺序。
- [测试与性能策略](testing-and-performance.md)：单元/集成/真机测试与性能验收。
- [架构决策记录](adr/README.md)：关键技术决定及其取舍。

## 已锁定的平台基线

- 默认渲染器：Godot 4.7 **Mobile** 渲染器（Vulkan）。
- 逻辑画布：横屏 16:9，基准分辨率 1280 × 720；最终缩放策略需在真机确认像素清晰度。
- Android 参考档：Snapdragon 778G / Dimensity 1080、6 GB 内存、Android 11+，目标 60 FPS。
- Android 最低兼容档：Snapdragon 720G / 同等级 Vulkan 设备、4 GB 内存、Android 10+，目标 30 FPS。
- Compatibility 渲染器不是首个版本的默认支持路径；仅在最低兼容档真机暴露 Vulkan 驱动问题时作为受控备选方案。

## 与游戏设计的关系

技术架构覆盖 [游戏设计文档](../game-design/README.md) 当前已确定的首个垂直切片：赵云、四类基础敌兵、夏侯恩、淳于导、张郃、长坂坡开放战场、剧情模式与无尽模式共用战斗规则。

## 维护约定

- 主架构文档描述“系统如何协作”；关键且难以逆转的单点选择记录在 ADR 中。
- 已接受的 ADR 不直接改写；发生变化时新增一份“Supersedes” ADR。
- 所有性能数值都必须经过目标 Android 真机验证，不能只依据编辑器表现。
