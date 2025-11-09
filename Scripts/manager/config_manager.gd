extends Node

const CONFIG_PATH :="user://config.ini"



#全局保存
func save_config() -> void:
	var config := ConfigFile.new()

# auidio设置音频设置
	config.set_value("audio","master",VolumeManager.get_volume(VolumeManager.Bus.Master))
	config.set_value("audio","sfx",VolumeManager.get_volume(VolumeManager.Bus.sfx))
	config.set_value("audio","bgm",VolumeManager.get_volume(VolumeManager.Bus.bgm))

# game_manager设置    

	config.set_value("game_manager","bullet_model",SignalBus.bullet_model)

	config.save(CONFIG_PATH)

#全局加载

func load_config() ->void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)

	VolumeManager.set_volume(
		VolumeManager.Bus.Master,config.get_value("audio","master",0.5)
	)

	VolumeManager.set_volume(
		VolumeManager.Bus.sfx,config.get_value("audio","sfx",0.5)
	)
	
	VolumeManager.set_volume(
		VolumeManager.Bus.bgm,config.get_value("audio","bgm",0.5)
	)

	SignalBus.bullet_model = config.get_value("game_manager","bullet_model",SignalBus.bullet_models.tracking_bullet)

#获取

func get_config_value(section: String,key: String) -> Variant:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	return config.get_value(section,key,null)

#设置

# func set_config_value(section: String,key: String,value: Variant) ->void:
# 	var config := ConfigFile.new().load(
# 	config.set_value(section,key,value)
# 	config.save(CONFIG_PATH)

func _ready() -> void:
	load_config()
