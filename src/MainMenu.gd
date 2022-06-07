extends Control

func _ready():
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")

func _on_StartButton_pressed():
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://src/Battle.tscn")


func _on_CreditsButton_pressed():
	$CreditsPopup.popup_centered_ratio()


func _on_QuitButton_pressed():
	get_tree().quit()
	yield(get_tree().create_timer(1), "timeout")
