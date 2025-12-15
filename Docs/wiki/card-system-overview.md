# 卡牌系统概述

## 🎴 系统简介

卡牌系统是《像素弹雨》的核心机制之一，玩家通过选择不同的卡牌来强化角色能力。系统采用模块化设计，遵循SOLID原则，具有高度的可扩展性和可维护性。

## 🏗️ 系统架构

### 基础架构

卡牌系统基于以下核心组件：

1. **BaseCard基类** - 定义所有卡牌的通用接口和行为
2. **CardFactory工厂类** - 负责创建和管理所有卡牌
3. **标签系统** - 用于卡牌分类和启用/禁用控制
4. **信号总线** - 实现卡牌与游戏系统的松耦合通信

### 设计模式

- **工厂模式**：通过CardFactory统一创建卡牌实例
- **继承与多态**：通过BaseCard实现不同类型卡牌的统一管理
- **信号系统**：使用Godot的信号系统实现松耦合的组件通信
- **标签分类**：支持按标签筛选和管理卡牌

## 📋 卡牌分类

### 基础卡牌 (Basic)
标签：`"basic"`

基础强化卡牌，提供核心属性提升：
- **子弹伤害提升** - 增加子弹伤害
- **开火速率提升** - 减少射击间隔
- **经验获取提升** - 增加经验值获取

### 追踪子弹卡牌 (TrackingBullet)
标签：`"tracking_bullet"`

专门强化追踪子弹的卡牌：
- **追踪子弹转向速度提升** - 提高追踪子弹的转向能力
- **追踪子弹最大生存时间提升** - 延长追踪子弹的存活时间

### 爆炸连锁卡牌 (ExplosionChain)
标签：`"explosion_chain"`

强化爆炸效果的卡牌：
- **爆炸连锁伤害系数提升** - 增加爆炸伤害
- **爆炸连锁概率提升** - 提高爆炸触发概率

### 穿透卡牌 (Penetrate)
标签：`"penetrate"`

强化子弹穿透能力的卡牌：
- **穿透伤害系数提升** - 增加穿透伤害
- **穿透概率提升** - 提高穿透触发概率

### 终极天赋卡牌 (Ultimate)
标签：`"ultimate"`

强大的终极技能，在特定等级可选择：
- **终极追踪子弹** - 获得强大的追踪子弹能力
- **终极爆炸连锁** - 获得爆炸连锁效果
- **终极穿透** - 获得子弹穿透能力

### 轮回卡牌 (Rein)
标签：`"Rein"`

10级时出现的特殊选项：
- **轮回保留** - 重置基础属性但保留终极效果
- **轮回重置** - 完全重置所有属性

## 🎯 卡牌获取机制

### 升级选择
- **1级**：初始选卡，从2张终极天赋中选择1张
- **2-9级**：常规升级，从3张随机卡牌中选择1张
- **10级**：轮回选择，从2张轮回选项中选择1张

### 卡牌生成规则
1. **第一张卡牌**：固定为基础卡牌（子弹伤害提升）
2. **其他卡牌**：根据启用的标签随机生成
3. **标签控制**：通过CardFactory.enabled_tags控制可用的卡牌类型

### 标签启用机制
```gdscript
# 基础游戏时启用基础卡牌
CardFactory.enabled_tags = ["basic"]

# 选择终极天赋后启用对应标签
CardFactory.enabled_tags.append("explosion_chain")
CardFactory.enabled_tags.append("penetrate")
```

## 🔧 技术实现

### 卡牌生命周期

1. **初始化阶段**
   - 创建卡牌实例
   - 调用`initialize()`方法设置属性
   - 设置卡牌标签和启用状态

2. **选择阶段**
   - 显示卡牌信息（名称、描述、图标）
   - 等待玩家选择
   - 处理卡牌交互

3. **应用阶段**
   - 调用`apply_effect()`方法
   - 发送相应的信号到游戏系统
   - 执行卡牌效果

### 信号通信

卡牌系统通过SignalBus与游戏其他部分通信：

```gdscript
# 基础强化信号
SignalBus.Sel_Bullet_damage.emit(coefficient)
SignalBus.Sel_Bullet_fire_timer.emit(coefficient)
SignalBus.Sel_Exp_obtain.emit(coefficient)

# 终极天赋信号
SignalBus.Sel_Tracking_Bullet.emit()
SignalBus.Sel_Explosion_Chain.emit()
SignalBus.Sel_Penetrate.emit()

# 增强信号
SignalBus.Sel_Explosion_Chain_Damage.emit(coefficient)
SignalBus.Sel_Tracking_Bullet_Turn_Speed.emit(coefficient)
```

## 🎨 卡牌UI设计

### 卡牌显示元素
- **卡牌名称**：显示卡牌的名称
- **效果描述**：简洁明了的效果说明
- **图标**：卡牌的视觉标识（当前为空，可扩展）
- **状态指示**：启用/禁用状态的视觉反馈

### 交互设计
- **悬停效果**：鼠标悬停时显示详细信息
- **选择动画**：选择时的视觉反馈
- **禁用状态**：不可选择卡牌的视觉提示

## 📊 卡牌平衡

### 数值设计原则
1. **线性成长**：基础卡牌提供稳定的属性提升
2. **指数收益**：终极天赋提供质变的能力提升
3. **风险收益**：部分卡牌需要特定条件才能发挥最大效果

### 平衡机制
- **随机性**：卡牌随机生成增加游戏变化性
- **选择限制**：每次只能选择一张卡牌，需要权衡利弊
- **标签控制**：通过标签系统控制卡牌出现频率

## 🔮 扩展性

### 添加新卡牌

1. **创建卡牌类**
   ```gdscript
   class_name NewCard
   extends BaseCard
   
   func _init():
       card_name = "新卡牌"
       description = "新卡牌效果"
       card_tag = "new_tag"
   
   func initialize() -> void:
       # 初始化逻辑
   
   func apply_effect() -> void:
       # 应用效果
   ```

2. **注册到工厂**
   ```gdscript
   # 在CardFactory._all_cards_cache中添加
   NewCard.new(),
   ```

3. **添加信号（如需要）**
   ```gdscript
   # 在SignalBus中添加新信号
   signal New_Card_Effect(parameter)
   ```

### 标签系统扩展
- 支持自定义标签
- 可以动态启用/禁用标签
- 支持多标签筛选（未来扩展）

## 🎯 最佳实践

1. **保持一致性**：所有卡牌遵循相同的命名约定和结构
2. **使用标签**：合理使用标签系统对卡牌进行分类
3. **信号通信**：通过信号总线进行模块间通信，避免直接依赖
4. **文档更新**：添加新卡牌时及时更新文档
5. **测试覆盖**：为每个卡牌编写单元测试

---

*相关文档：[基础卡牌](basic-cards.md) | [终极天赋](ultimate-talents.md) | [轮回系统](reincarnation-system.md) | [卡牌系统开发](card-system-development.md)*