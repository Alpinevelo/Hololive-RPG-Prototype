extends Control

signal textbox_closed

export(Resource) var enemy = null

var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

func _ready():
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	set_health($EnemyHealth, enemy.health, enemy.health)
	$BotanContainer/Botan.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$Textbox.hide()
	$ActionsPanel.hide()
	$EnemyHealth.hide()
	$PlayerPanel.hide()
	
	$TalkStreamPlayer.play()
	
	display_text("Botan appears.")
	yield(self, "textbox_closed")
	
	$ActionsPanel.show()
	$EnemyHealth.show()
	$PlayerPanel.show()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP:%d/%d" % [health, max_health]
	
func _input(event):
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT):
		$Textbox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text

func enemy_turn():
	display_text("Botan slashes at you with her claws!")
	yield(self, "textbox_closed")
	
	if is_defending:
		is_defending = false
		
		current_player_health = max(0, current_player_health - (enemy.damage / 2))
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("mini_shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("You take %d damage!" % (enemy.damage / 2))
		yield(self, "textbox_closed")
		
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("You take %d damage!" % enemy.damage)
		yield(self, "textbox_closed")
	
	if current_player_health == 0:
		display_text("You were defeated...")
		yield(self, "textbox_closed")
		
		$AnimationPlayer.play("fade_out")
		yield($AnimationPlayer, "animation_finished")
		
		get_tree().quit()
		yield(get_tree().create_timer(1), "timeout")

	$ActionsPanel.show()

func _on_Attack_pressed():
	if $TalkStreamPlayer.playing == true:
		$TalkStreamPlayer.stop()
		yield($TalkStreamPlayer, "finished")
		$BattleStreamPlayer.play()
	
	display_text("You swing your sword!")
	yield(self, "textbox_closed")
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyHealth, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	yield($AnimationPlayer, "animation_finished")
	
	display_text("You dealt %d damage!" % State.damage)
	yield(self, "textbox_closed")

	if current_enemy_health == 0:
		display_text("Botan was defeated!")
		yield(self, "textbox_closed")
		
		$EnemyHealth.hide()
		
		$AnimationPlayer.play("enemy_died")
		yield($AnimationPlayer, "animation_finished")
		yield(get_tree().create_timer(0.25), "timeout")
		get_tree().quit()
		yield(get_tree().create_timer(1), "timeout")
	enemy_turn()

func _on_Defend_pressed():
	if $TalkStreamPlayer.playing == true:
		$TalkStreamPlayer.stop()
		yield($TalkStreamPlayer, "finished")
		$BattleStreamPlayer.play()
	
	is_defending = true
	display_text("You brace yourself.")
	yield(self, "textbox_closed")
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	enemy_turn()

func _on_Run_pressed():
	display_text("You escaped successfully.")
	yield(self, "textbox_closed")
	
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	
	yield(get_tree().create_timer(0.25), "timeout")
	get_tree().quit()
