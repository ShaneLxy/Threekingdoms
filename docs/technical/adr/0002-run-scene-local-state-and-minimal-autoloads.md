# ADR-0002：局内状态归 RunScene，使用最少 AutoLoad

**状态**：已接受  
**日期**：2026-07-12  
**引擎基线**：Godot `4.7.stable.official.5b4e0cb0f`

## 背景

游戏包含局内经验、强化、敌军、Boss 阶段、对象池和 HUD。如果这些状态进入全局 `GameManager` 或多个互相调用的 AutoLoad，场景重开、测试隔离、结算和后续多人协作都会变得脆弱。

## 决定

- `RunScene` 创建并独占当前 `RunState`、敌军模拟、刷怪导演、对象池和局内 HUD。
- 只保留 `SaveService`、`AudioService`、`SceneRouter` 三个 AutoLoad。
- RunScene 结算时发出 `run_finished(result)`，由 SceneRouter 调用 SaveService 更新 ProfileState 并切换场景。
- 首个版本不建立全局 EventBus，也不建立包揽局内逻辑的 GameManager。

## 后果

### 正面

- 重开一局等同于销毁并新建 RunScene，局内脏状态不残留。
- 单元测试和集成测试更容易构建独立 RunState。
- 全局状态小且职责明确，降低循环依赖风险。

### 负面

- RunScene 需要显式组装依赖，初期比随处访问单例更繁琐。
- 跨场景功能新增时必须判断是否真的需要 AutoLoad。
- 中途存档若要支持，需要明确序列化 RunState，而不能依赖单例常驻。

## 关联需求

TR-004、TR-007、TR-009、TR-010。

## 引擎兼容性

遵循 Godot AutoLoad 的顺序初始化规则：AutoLoad 的 `_ready()` 不访问排在其后的 AutoLoad 或当前场景。实际项目需在 `project.godot` 中确认顺序并用启动健康检查验证。
