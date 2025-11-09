# 牌包系统架构文档

## 概述

新的牌包系统采用模块化设计，将牌包功能分为两部分：
1. **主程序** (selection.gd) - 负责UI交互和生命周期管理
2. **牌包** (BaseCard及其子类) - 负责具体功能实现

## 架构设计

### 基类 - BaseCard
- 定义所有牌包的通用接口和行为
- 包含基本信息：名称、描述、图标路径
- 提供标签系统用于分类和启用/禁用控制
- 定义虚函数供子类实现

### 具体牌包类
- **BulletFireRateCard** - 开火速率提升牌包
- **BulletDamageCard** - 子弹伤害提升牌包
- **ExpGainCard** - 经验获取提升牌包

### 工厂类 - CardFactory
- 负责创建和管理所有牌包
- 支持按类型、标签、随机等方式创建牌包
- 提供启用/禁用牌包的筛选功能

### 主程序 - selection.gd
- 负责牌包的UI交互和生命周期管理
- 通过组合模式挂载不同的牌包实现
- 提供便捷的初始化方法

## 标签系统

每个牌包都有单一标签属性（card_tag），用于：
- **分组**：如 "basic"、"expansion1"、"expansion2" 等
- **启用/禁用**：通过CardFactory设置启用的标签来控制牌包生成
- **筛选**：根据启用的标签创建特定分组的牌包

### 标签使用方式
- `card_tag` - 牌包的分组标签，每个牌包只有一个
- `enabled_tags` - CardFactory中的启用标签列表，可以包含多个标签

### 常用标签
- `basic` - 基础牌包
- `expansion1` - 扩展包1
- `expansion2` - 扩展包2
- 可以根据需要自定义更多标签

## 使用方法

### 创建新牌包
1. 继承BaseCard类
2. 实现必要的虚函数
3. 在_init()中设置基本信息和标签
4. 在CardFactory中添加创建逻辑

### 使用牌包
```gdscript
# 通过类型创建
var card = CardFactory.create_card(CardFactory.CardType.BULLET_DAMAGE)

# 通过标签创建
var card = CardFactory.create_card_by_tag("basic")

# 随机创建（从启用的标签中）
var card = CardFactory.create_random_card()

# 初始化到UI
var selection_node = preload("res://Scenes/slections/selection.tscn").instantiate()
selection_node.initialize_card(card)
```

### 控制牌包启用/禁用
```gdscript
# 设置启用的标签
CardFactory.set_enabled_tags(["basic", "expansion1"])

# 添加启用的标签
CardFactory.add_enabled_tag("expansion2")

# 移除启用的标签
CardFactory.remove_enabled_tag("expansion1")

# 获取当前启用的标签
var enabled_tags = CardFactory.get_enabled_tags()

# 获取所有启用的牌包
var enabled_cards = CardFactory.get_all_enabled_cards()

# 创建随机启用的牌包
var card = CardFactory.create_random_enabled_card()
```

## 扩展性

新架构遵循SOLID原则，具有很好的扩展性：
- **单一职责**：每个类只负责一个功能
- **开闭原则**：可以添加新牌包而不修改现有代码
- **依赖倒置**：主程序依赖抽象而非具体实现

## 兼容性

为了保持向后兼容，保留了原有的Spawn_Card方法，同时新增了Spawn_Card_New方法使用新架构。