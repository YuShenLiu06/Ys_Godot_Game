extends Button

func _on_pressed() -> void:
	# 继续游戏
	SignalBus.Is_paused = false
	SignalBus.Pause_game.emit(false)
	get_tree().paused = false
