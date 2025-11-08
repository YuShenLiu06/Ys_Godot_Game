extends Button

# 按下按钮后退出游戏
func _on_pressed() -> void:
	get_tree().quit()