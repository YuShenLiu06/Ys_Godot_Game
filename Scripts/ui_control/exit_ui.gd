extends Button

# 按下按钮后退出游戏
func _on_pressed() -> void:
	ConfigManager.save_config()
	get_tree().quit()