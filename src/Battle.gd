#Sound Effects licensed under the Mixkit Sound Effects Free License
#PowerUp28.mp3 and music by Eric Matyas at https://soundimage.org

extends Control

signal textbox_closed

export(Resource) var enemy = null

var current_player_health = 0
var current_enemy_health = 0
var stigma_charged = false
var stigma_meter = 0
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
	$MagicPanel.hide()
	
	$TalkStreamPlayer.play(1.25)
	
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
	$PlayerPanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text

func enemy_turn():
	if $TalkStreamPlayer.playing == true:
		$TalkStreamPlayer.stop()
		yield($TalkStreamPlayer, "finished")
		$BattleStreamPlayer.play()
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	stigma_meter += rng.randi_range(3, 5)
	
	if min(stigma_meter, 15) == 15:
		stigma_meter = 0
		stigma_charged = true
		
		get_tree().get_root().set_disable_input(true)
		yield(get_tree().create_timer(0.1), "timeout")
		
		display_text("Botan smirks.")
		yield(get_tree().create_timer(1), "timeout")
		display_text("Botan smirks..")
		yield(get_tree().create_timer(1), "timeout")
		display_text("Botan smirks...")
		yield(get_tree().create_timer(1.5), "timeout")
		
		get_tree().get_root().set_disable_input(false)
		yield(get_tree().create_timer(0.1), "timeout")
		
		display_text("Botan is overflowing with Stigma!")
		$SFXStigmaCharged.play()
		yield(self, "textbox_closed")
		$ActionsPanel.show()
		$PlayerPanel.show()
		return
	
	elif stigma_charged:
		stigma_charged = false
		
		display_text("Botan unleashes a devasting attack!")
		yield(self, "textbox_closed")
		
		if is_defending:
			is_defending = false
			
			var DAMAGE = floor(((enemy.damage * 2) + (enemy.damage * rng.randf_range(0.0, 0.3))) * 0.8)
			current_player_health = max(0, current_player_health - DAMAGE)
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("mini_shake")
			$SFXStigmaAttack.play()
			yield($AnimationPlayer, "animation_finished")
			display_text("You took %d damage!" % DAMAGE)
			yield(self, "textbox_closed")
			
		else:
			var DAMAGE = floor((enemy.damage * 2) + (enemy.damage * rng.randf_range(0.0, 0.3)))
			current_player_health = max(0, current_player_health - DAMAGE)
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("shake")
			$SFXStigmaAttack.play()
			yield($AnimationPlayer, "animation_finished")
			display_text("You took %d damage!" % DAMAGE)
			yield(self, "textbox_closed")
	else:
		display_text("Botan slashes at you with her claws!")
		yield(self, "textbox_closed")
		
		if is_defending:
			is_defending = false
			
			var DAMAGE = floor((enemy.damage + (enemy.damage * rng.randf_range(0.0, 0.3))) * 0.8)
			
			current_player_health = max(0, current_player_health - DAMAGE)
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("mini_shake")
			$SFXBotanBasicAttack.play()
			yield($AnimationPlayer, "animation_finished")
			display_text("You took %d damage!" % DAMAGE)
			yield(self, "textbox_closed")
			
		else:
			var DAMAGE = floor(enemy.damage + (enemy.damage * rng.randf_range(0.0, 0.3)))
			current_player_health = max(0, current_player_health - DAMAGE)
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("shake")
			$SFXBotanBasicAttack.play()
			yield($AnimationPlayer, "animation_finished")
			display_text("You took %d damage!" % DAMAGE)
			yield(self, "textbox_closed")
		
	if current_player_health < 1:
		display_text("You were defeated...")
		yield(self, "textbox_closed")
		
		$AnimationPlayer.play("fade_out")
		yield($AnimationPlayer, "animation_finished")
		
		get_tree().quit()
		yield(get_tree().create_timer(1), "timeout")

	$ActionsPanel.show()
	$PlayerPanel.show()

func _on_Attack_pressed():
	if $MagicPanel.is_visible_in_tree():
		$MagicPanel.hide()
		
	if $TalkStreamPlayer.playing == true:
		$TalkStreamPlayer.stop()
		yield($TalkStreamPlayer, "finished")
		$BattleStreamPlayer.play()
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var crit = rng.randf_range(0.0, 1.0)
	
	if crit < 0.15:
		display_text("You viciously swing your sword!")
		yield(self, "textbox_closed")
		
		var DAMAGE = floor((State.damage * 1.5) + (State.damage * rng.randf_range(0.0, 0.3)))
		current_enemy_health = max(0, current_enemy_health - DAMAGE)
		set_health($EnemyHealth, current_enemy_health, enemy.health)
		
		$AnimationPlayer.play("enemy_damaged")
		$SFXPlayerCriticalHit.play()
		yield($AnimationPlayer, "animation_finished")
		
		display_text("You dealt %d damage!" % DAMAGE)
		yield(self, "textbox_closed")
		
	else:
		display_text("You swing your sword!")
		yield(self, "textbox_closed")
		
		var DAMAGE = floor((State.damage) + (State.damage * rng.randf_range(0.0, 0.3)))
		current_enemy_health = max(0, current_enemy_health - DAMAGE)
		set_health($EnemyHealth, current_enemy_health, enemy.health)
		
		$AnimationPlayer.play("enemy_damaged")
		$SFXPlayerBasicAttack.play()
		yield($AnimationPlayer, "animation_finished")
		
		display_text("You dealt %d damage!" % DAMAGE)
		yield(self, "textbox_closed")

	if current_enemy_health < 1:
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
	if $MagicPanel.is_visible_in_tree():
		$MagicPanel.hide()
		
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
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if $MagicPanel.is_visible_in_tree():
		$MagicPanel.hide()
	
	var escape_chance = rng.randf()
	
	get_tree().get_root().set_disable_input(true)
	yield(get_tree().create_timer(0.1), "timeout")
	
	display_text("You try to escape.")
	yield(get_tree().create_timer(1), "timeout")
	display_text("You try to escape..")
	yield(get_tree().create_timer(1), "timeout")
	display_text("You try to escape...")
	yield(get_tree().create_timer(1.5), "timeout")
	
	get_tree().get_root().set_disable_input(false)
	yield(get_tree().create_timer(0.1), "timeout")
	
	if escape_chance < 0.5:
		display_text("You escaped successfully.")
		yield(self, "textbox_closed")
		$EnemyHealth.hide()
		$AnimationPlayer.play("fade_out")
		yield($AnimationPlayer, "animation_finished")
		
		yield(get_tree().create_timer(0.25), "timeout")
		get_tree().quit()
	else:
		display_text("You failed to escape!")
		yield(self, "textbox_closed")
		yield(get_tree().create_timer(0.25), "timeout")
		enemy_turn()

func _on_Magic_pressed():
	if $MagicPanel.is_visible_in_tree():
		$MagicPanel.hide()
	else:
		$MagicPanel.show()

func _on_Heal_pressed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	yield(get_tree().create_timer(0.1), "timeout")
	$ActionsPanel.hide()
	$MagicPanel.hide()
	
	var HEAL = State.magic + (State.magic * rng.randf_range(0.0, 1.0))
	current_player_health = min(State.max_health, (current_player_health + HEAL))
	set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	$SFXHeal.play()
	yield($SFXHeal, "finished")
	display_text("You were healed for %d hitpoints!" % HEAL)
	$ActionsPanel.show()
	yield(self, "textbox_closed")
	
	enemy_turn()
