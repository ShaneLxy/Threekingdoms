# 三国：破阵斩将 — 可玩 MVP

Godot 4.7 的俯视斜角割草 Roguelike 原型。当前版本是 3 分钟压缩剧情演示：赵云对抗刀兵、弓兵、戟兵、盾兵，并依次遭遇夏侯恩、淳于导，最终迎战张郃。

## 启动

```powershell
& 'E:\Godot_v4.7\Godot_v4.7-stable_win64.exe' --path 'E:\AIGame\ThreeKingdom'
```

## 桌面试玩操作

- `WASD` 或方向键：移动。
- 鼠标左键：向鼠标方向施放普攻。
- 鼠标右键或 `Q`：七探盘蛇。
- 鼠标中键、`E` 或空格：无双（能量 100% 时）。
- 触摸设备：左侧拖拽移动；右侧普攻、主动、无双按钮可直接触碰。

## MVP 范围

- 赵云三段手动普攻、被动护体、主动技能和无双。
- 经验、升级三选一、无双能量。
- 刀/戟/弓/盾、夏侯恩与淳于导具名精英，以及张郃三阶段 Boss。
- 有边界的长坂坡战场、预警区与敌军刷怪导演。
- 代码绘制的占位像素风表现；正式美术资源尚未接入。

## 自动冒烟测试

```powershell
& 'E:\Godot_v4.7\Godot_v4.7-stable_win64_console.exe' --headless --path 'E:\AIGame\ThreeKingdom' -s res://tests/test_runner.gd
```
