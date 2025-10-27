## 快速目标 — 让 AI 代码助手立刻可用

这是为本 Godot 4.5 项目（MyfirstGame）准备的简短运行与编码指导，目的是让 AI 编码代理快速理解项目结构、关键约定与常见改动点。

### 1) 大局与目录约定
- 引擎 / 版本：Godot 4.5（见 `project.godot` 中的 config/features）。
- 场景放在 `Scenes/`，可复用场景（PackedScene）在场景文件内以 `PackedScene` 引用。
- 脚本集中在 `Scripts/`（例如 `Game_manager.gd`, `SignalBus.gd`, `player.gd`, `enemy.gd`, `selection.gd`）。
- 资源与美术放在 `AssetBundle/`（字体、精灵、音频等）。

### 2) 关键集成点（必须熟悉）
- Autoloads（全局单例）在 `project.godot` 的 `[autoload]` 区配置：
  - `SignalBus` -> `res://Scripts/SignalBus.gd`（项目中大量使用信号进行跨场景通信）
  - `Bgm` -> `res://Scenes/bgm.tscn`
 任何跨场景/跨脚本的事件与状态都优先通过 `SignalBus` 发射/连接（不要直接创建新的全局变量）。

- 场景与当前场景访问：代码中经常使用 `get_tree().current_scene` 来访问或向当前场景添加实例（例如在 `Game_manager.gd:Spawn_enemy`、`_on_fire` 中）。保持此风格以避免路径失配。

### 3) 常见模式与约定（具体示例）
- 信号优先：例如 `SignalBus.gd` 定义 `Sel_Bullet_damage`, `Sel_Exp_obtain`, `Close_Choose_time` 等信号。脚本通过 `SignalBus.X.connect(fn)` 连接并用 `SignalBus.X.emit(...)` 广播。
- 选择卡（selection）模式：`selection.gd` 使用索引数组存储初始化与按下行为：
  - `method_init = [null,Bullet_Halve_init,Bullet_damage_init,Exp_obtain_init]` —— 约定用数组索引决定行为，新增卡牌遵循此约定。
- 场景实例化：用 `PackedScene.instantiate()` 然后 `get_tree().current_scene.add_child(node)`；保持位置/属性在实例化后设置。
- 游戏状态门控：`SignalBus.Is_choose_time` 在全局阻止玩家输入/敌人生成等行为（见 `player.gd` 和 `Game_manager.gd` 的检查）。AI 修改逻辑时要尊重这类门控变量。

### 4) 运行 / 导出 / 调试（开发工作流）
- 在编辑器中打开项目：把 Godot 4.5 编辑器指向此文件夹（包含 `project.godot`）。
- 从命令行运行（如果在系统上安装了 Godot 可执行文件）：
  PowerShell 示例：
  ```powershell
  # 在编辑器中打开
  godot --path "G:\Godot_Games\myfirst-game"

  # 直接运行（不打开编辑器）
  godot --path "G:\Godot_Games\myfirst-game" --main-pack "project.godot"
  ```
 （注：命令依赖你本地的 godot 可执行名与版本，调整为 `godot.exe` 或安装路径即可）

- 导出（已有导出预设）：`export_presets.cfg` 中含有名为 `Windows Desktop` 的预设，输出到 `Build/0.0.3.exe`。CLI 导出示例：
  ```powershell
  godot --path "G:\Godot_Games\myfirst-game" --export "Windows Desktop" "G:\Godot_Games\myfirst-game\Build\0.0.3.exe"
  ```

### 5) 变更 & 贡献建议（AI 应如何变更代码）
- 修改事件/信号：优先在 `SignalBus.gd` 添加信号；所有发射/连接点使用一致的信号命名与参数签名。
- 添加新全局单例（autoload）：更新 `project.godot` 的 `[autoload]` 段并确保代码使用该单例而非硬编码路径。
- 新场景/Prefab：放入 `Scenes/`，并在需要的地方以 `PackedScene` 资源方式引用（不直接 new Node）。

### 6) 可见的陷阱与注意事项
- `get_tree().current_scene` 在不同调用时可能不是期望的根节点；在复杂改动时确认目标场景对象是否是 `current_scene`。
- `Selection` 卡牌通过数组索引调用函数，数组越界或写错索引会导致运行时错误；保持数组与 `tot_Choose_functon` 的一致性（参见 `SignalBus.tot_Choose_functon`）。
- 使用 `SignalBus.Is_choose_time` 做输入/行为屏蔽；忘记检查会导致玩家能在选卡时移动或开火。

### 7) 快速查阅文件（重要文件示例）
- `project.godot` — autoloads, input map, engine features
- `Scripts/SignalBus.gd` — 所有全局信号定义与布尔门控
- `Scripts/Game_manager.gd` — 生成、经验与选卡控制逻辑
- `Scripts/player.gd` — 玩家输入/移动/开火逻辑，响应 `SignalBus`
- `Scripts/selection.gd` — 卡片选项实现（method arrays）
- `Scenes/Game.tscn` — 主场景，展示节点结构与连接点

如果你希望我把这份文件扩充为更详尽的 `AGENT.md`（包含编码示例、单元测试建议和可运行的本地验证脚本），告诉我你要多详细，我会继续补充。

----
请检查是否需要补充：例如你想加入 CI 环境（自动导出 / 运行示例）或代码风格规则（如 GDScript 风格约束）。
