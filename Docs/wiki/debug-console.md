# 调试控制台使用指南

## 🔧 概述

调试控制台是《像素弹雨》内置的开发者工具，提供游戏内调试和测试功能。通过控制台，开发者可以快速测试游戏机制、调整参数和验证功能。

## 🎮 控制台操作

### 基础操作
- **开启/关闭**：按F1键打开或关闭调试控制台
- **关闭控制台**：当控制台打开时，按ESC键关闭
- **历史浏览**：使用↑/↓键浏览之前输入的指令历史
- **清空输出**：输入`/clear`指令清空控制台输出

### 界面元素
- **输入框**：位于底部的文本输入区域
- **输出区域**：显示指令执行结果和系统信息
- **提示信息**：显示可用的指令和帮助信息

## 📋 可用指令

### 1. 经验值管理

#### 增加经验值
```bash
/exp add <amount>
```

**功能**：为玩家增加指定数量的经验值  
**参数**：
- `amount`：要增加的经验值数量（正整数）

**示例**：
```bash
/exp add 100    # 增加100点经验值
/exp add 50     # 增加50点经验值
```

**使用场景**：
- 测试升级机制
- 快速达到特定等级
- 验证经验计算公式

---

### 2. 等级管理

#### 设置等级
```bash
/level set <amount>
```

**功能**：直接设置玩家的等级  
**参数**：
- `amount`：要设置的等级（正整数）

**示例**：
```bash
/level set 5    # 设置等级为5级
/level set 10   # 设置等级为10级
```

**使用场景**：
- 测试特定等级的游戏内容
- 验证等级解锁机制
- 快速测试高等级内容

---

### 3. 子弹类型管理

#### 设置子弹模型
```bash
/bullet model set <type>
```

**功能**：切换当前的子弹类型  
**参数**：
- `type`：子弹类型（0或1）
  - 0：普通子弹
  - 1：追踪子弹

**示例**：
```bash
/bullet model set 0    # 切换到普通子弹
/bullet model set 1    # 切换到追踪子弹
```

**使用场景**：
- 测试不同子弹类型的效果
- 验证子弹切换机制
- 对比不同子弹的性能

---

### 4. 终极技能管理

#### 增加终极技能次数
```bash
/ultimate <type> add <amount>
```

**功能**：增加指定终极技能的使用次数  
**参数**：
- `type`：终极技能类型
  - `tracking_bullet`：追踪子弹
  - `explosion_chain`：爆炸连锁
  - `penetrate`：穿透
- `amount`：增加的次数（正整数）

**示例**：
```bash
/ultimate tracking_bullet add 2    # 增加追踪子弹终极技能2次
/ultimate explosion_chain add 1    # 增加爆炸连锁终极技能1次
/ultimate penetrate add 3          # 增加穿透终极技能3次
```

**使用场景**：
- 测试终极技能效果
- 验证技能触发机制
- 快速获得终极技能进行测试

---

### 5. 控制台管理

#### 清空控制台
```bash
/clear
```

**功能**：清空控制台的所有输出内容  
**参数**：无

**示例**：
```bash
/clear    # 清空控制台输出
```

#### 显示帮助信息
```bash
/help
```

**功能**：显示所有可用指令的详细帮助信息  
**参数**：无

**示例**：
```bash
/help    # 显示帮助信息
```

---

## 🛠️ 技术实现

### 控制台架构

调试控制台基于以下组件构建：

```gdscript
# 控制台主脚本
class_name DebugConsole
extends Control

# 输入处理
func _on_command_input(command_text: String):
    var parts = command_text.split(" ")
    var command = parts[0].to_lower()
    var args = parts.slice(1)
    
    match command:
        "/exp":
            handle_exp_command(args)
        "/level":
            handle_level_command(args)
        "/bullet":
            handle_bullet_command(args)
        "/ultimate":
            handle_ultimate_command(args)
        "/clear":
            clear_console()
        "/help":
            show_help()
```

### 指令解析系统

控制台使用统一的指令解析机制：

1. **指令分割**：按空格分割指令和参数
2. **类型转换**：自动转换参数类型
3. **错误处理**：提供友好的错误提示
4. **结果反馈**：显示执行结果和状态信息

### 信号集成

控制台通过信号总线与游戏系统集成：

```gdscript
# 与游戏管理器的交互
SignalBus.exp_add_requested.emit(amount)
SignalBus.level_set_requested.emit(level)
SignalBus.bullet_model_changed.emit(model)

# 与玩家系统的交互
SignalBus.ultimate_skill_added.emit(type, amount)
```

## 🔍 调试用例

### 测试升级机制
```bash
# 测试经验积累和升级
/exp add 10      # 测试1级升级
/exp add 15      # 测试2级升级
/exp add 23      # 测试3级升级

# 直接设置等级测试
/level set 5     # 测试5级内容
/level set 10    # 测试10级轮回
```

### 测试武器系统
```bash
# 切换子弹类型测试
/bullet model set 0    # 测试普通子弹
/bullet model set 1    # 测试追踪子弹

# 重复切换测试
/bullet model set 0
/bullet model set 1
/bullet model set 0
```

### 测试终极技能
```bash
# 添加终极技能
/ultimate tracking_bullet add 5
/ultimate explosion_chain add 3
/ultimate penetrate add 2

# 测试技能效果
# 在游戏中使用技能并观察效果
```

### 综合测试场景
```bash
# 完整的游戏流程测试
/level set 1                    # 设置为1级
/ultimate tracking_bullet add 1   # 添加追踪子弹技能
/exp add 100                     # 快速升级到5级
/ultimate explosion_chain add 1   # 添加爆炸连锁技能
/exp add 500                     # 升级到10级
# 测试轮回选择
```

## ⚠️ 使用注意事项

### 安全性考虑
1. **参数验证**：所有输入参数都会进行类型和范围验证
2. **状态检查**：执行指令前检查游戏状态
3. **错误处理**：提供清晰的错误信息和解决建议

### 性能影响
1. **最小开销**：控制台在不使用时几乎不影响性能
2. **批量操作**：支持批量执行相关指令
3. **状态同步**：确保控制台状态与游戏状态同步

### 兼容性
1. **版本兼容**：控制台指令在不同版本中保持兼容
2. **平台兼容**：支持所有目标平台
3. **输入法兼容**：支持不同输入法环境

## 🔮 扩展计划

### 新指令计划
- **敌人生成控制**：`/spawn <type> <count>` - 生成指定敌人
- **时间控制**：`/time <speed>` - 调整游戏时间流速
- **难度设置**：`/difficulty <level>` - 设置游戏难度
- **状态查询**：`/status` - 显示当前游戏状态

### 界面改进
- **自动补全**：支持指令和参数的自动补全
- **历史记录**：保存更长的指令历史
- **分类显示**：按类型分类显示输出信息
- **可视化**：添加图形化的调试界面

### 高级功能
- **脚本执行**：支持执行调试脚本文件
- **性能监控**：实时显示性能指标
- **网络调试**：支持网络功能的调试
- **录制回放**：录制和回放游戏过程

## 🐛 故障排除

### 常见问题

#### 控制台无法打开
**问题**：按F1键没有反应  
**解决方案**：
1. 检查是否在游戏主界面
2. 确认键盘功能正常
3. 重启游戏尝试

#### 指令无效
**问题**：输入指令后没有效果  
**解决方案**：
1. 检查指令拼写是否正确
2. 确认参数格式是否正确
3. 查看`/help`确认指令列表

#### 参数错误
**问题**：显示参数错误信息  
**解决方案**：
1. 检查参数类型是否正确
2. 确认参数数值范围
3. 参考示例指令格式

### 调试技巧

1. **逐步测试**：一次只测试一个功能
2. **状态观察**：观察指令执行后的状态变化
3. **日志记录**：记录测试步骤和结果
4. **对比测试**：对比正常和异常情况

---

*相关文档：[开发指令](development-commands.md) | [架构设计](architecture.md) | [信号系统](signal-system.md)*