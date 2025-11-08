extends HSlider

@export var bus : StringName = "Master"  #音频总线索引，0为主总线

@onready var bus_index : int = AudioServer.get_bus_index(bus) #通过总线名称获取总线索引

func _ready() -> void:
	value = VolumeManager.get_volume(bus_index) #初始化滑块位置

	value_changed.connect(func (v: float):
		VolumeManager.set_volume(bus_index,v)
		) #滑块值变化时设置音量
