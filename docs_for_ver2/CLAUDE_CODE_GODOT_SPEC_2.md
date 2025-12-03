
## 3.6 QuestManager — Менеджер квестов

```gdscript
# scripts/autoload/quest_manager.gd
extends Node

## Менеджер квестовой системы

signal quest_started(quest_id: String, quest_data: Dictionary)
signal quest_updated(quest_id: String, step: String)
signal quest_completed(quest_id: String, outcome: String)
signal objective_completed(quest_id: String, objective_id: String)

# Данные всех квестов
var quests_data: Dictionary = {}

# Текущий активный квест
var current_quest_id: String = ""
var current_quest_step: String = ""


func _ready() -> void:
	_load_quests_data()
	print("[QuestManager] Initialized with %d quests" % quests_data.size())


func _load_quests_data() -> void:
	var file_path := "res://data/quests/quests.json"
	
	if not FileAccess.file_exists(file_path):
		push_error("[QuestManager] Quests file not found")
		return
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	var json := JSON.new()
	
	if json.parse(file.get_as_text()) != OK:
		push_error("[QuestManager] Failed to parse quests.json")
		return
	
	file.close()
	quests_data = json.data


## Начать квест
func start_quest(quest_id: String) -> void:
	if quest_id not in quests_data:
		push_error("[QuestManager] Quest not found: " + quest_id)
		return
	
	var quest: Dictionary = quests_data[quest_id]
	
	# Проверяем, не выполнен ли уже
	if GameManager.player_data.is_quest_completed(quest_id):
		print("[QuestManager] Quest already completed: " + quest_id)
		return
	
	current_quest_id = quest_id
	current_quest_step = quest.get("first_step", "start")
	
	# Сохраняем в данные игрока
	GameManager.player_data.current_quest_id = quest_id
	GameManager.player_data.quest_progress[quest_id] = {
		"step": current_quest_step,
		"started_at": Time.get_unix_time_from_system()
	}
	
	print("[QuestManager] Quest started: %s - %s" % [quest_id, quest.get("title", "")])
	quest_started.emit(quest_id, quest)


## Обновить прогресс квеста
func update_quest_step(quest_id: String, step: String) -> void:
	if quest_id != current_quest_id:
		return
	
	current_quest_step = step
	GameManager.player_data.quest_progress[quest_id]["step"] = step
	
	quest_updated.emit(quest_id, step)


## Завершить квест
func complete_quest(quest_id: String, outcome: String = "success") -> void:
	if quest_id not in quests_data:
		return
	
	var quest: Dictionary = quests_data[quest_id]
	
	# Помечаем как выполненный
	GameManager.player_data.complete_quest(quest_id)
	
	# Даём награды
	if quest.has("rewards"):
		_give_rewards(quest.rewards, outcome)
	
	# Обновляем статистику
	if outcome == "success":
		GameManager.player_data.correct_decisions += 1
	
	# Очищаем текущий квест
	if current_quest_id == quest_id:
		current_quest_id = ""
		current_quest_step = ""
	
	print("[QuestManager] Quest completed: %s (outcome: %s)" % [quest_id, outcome])
	quest_completed.emit(quest_id, outcome)
	
	# Автоматически начинаем следующий квест, если есть
	if quest.has("next_quest") and not quest.next_quest.is_empty():
		# Небольшая задержка перед следующим квестом
		await get_tree().create_timer(1.0).timeout
		start_quest(quest.next_quest)


func _give_rewards(rewards: Dictionary, outcome: String) -> void:
	var player_data: PlayerData = GameManager.player_data
	
	# XP зависит от исхода
	var xp_multiplier := 1.0 if outcome == "success" else 0.5
	
	if rewards.has("xp"):
		player_data.add_xp(int(rewards.xp * xp_multiplier))
	
	if rewards.has("skills"):
		for skill_id in rewards.skills:
			player_data.add_skill_xp(skill_id, int(rewards.skills[skill_id] * xp_multiplier))


## Получить данные квеста
func get_quest_data(quest_id: String) -> Dictionary:
	return quests_data.get(quest_id, {})


## Получить текущий квест
func get_current_quest() -> Dictionary:
	if current_quest_id.is_empty():
		return {}
	return get_quest_data(current_quest_id)


## Проверить условие квеста
func check_quest_condition(condition: Dictionary) -> bool:
	var player_data: PlayerData = GameManager.player_data
	
	match condition.get("type", ""):
		"flag":
			return player_data.has_flag(condition.get("flag", ""))
		"skill":
			var skill_id: String = condition.get("skill", "")
			var min_level: int = condition.get("min_level", 0)
			return player_data.get_skill_level(skill_id) >= min_level
		"quest_completed":
			return player_data.is_quest_completed(condition.get("quest_id", ""))
		_:
			return true
```



## 3.7 AIManager — Интеграция с Claude API

```gdscript
# scripts/autoload/ai_manager.gd
extends Node

## Менеджер ИИ-ментора (интеграция с Claude API)
## В MVP используется заглушка, структура готова для реального API

signal mentor_response_received(response: String)
signal mentor_request_started
signal mentor_request_failed(error: String)

# Настройки API (для будущего)
const API_URL := "https://api.anthropic.com/v1/messages"
var api_key: String = ""  # Загружается из конфига

# Режим работы
var use_mock_responses: bool = true  # В MVP — true

# Кэш ответов
var response_cache: Dictionary = {}

# Системный промпт для ментора
const MENTOR_SYSTEM_PROMPT := """Ты — Совёнок, дружелюбный ментор в образовательной игре для детей 6-10 лет.

ТВОЯ РОЛЬ:
- Помогать детям распознавать мошенников и обман
- Объяснять сложные вещи простым языком
- Поддерживать и хвалить за правильные решения
- Мягко объяснять ошибки без критики

ПРАВИЛА:
- Используй простые слова (максимум 2-3 слога)
- Добавляй эмодзи: 😊 👍 🤔 ⚠️ 🌟
- Отвечай коротко (2-4 предложения)
- Задавай наводящие вопросы вместо прямых ответов
- Никогда не давай личных данных
- Всегда поддерживай и ободряй"""

# Заготовленные ответы для MVP (по контекстам)
const MOCK_RESPONSES := {
	"stranger_asks_password": [
		"Хм, интересно! 🤔 А как ты думаешь, кому можно говорить свои пароли? Подсказка: это должен быть кто-то очень близкий!",
		"Давай подумаем вместе! 🦉 Этот человек говорит, что он помощник директора. А ты его раньше видел? Знаешь его имя?",
		"Знаешь, у меня есть правило: если кто-то просит пароль — это 🚩 красный флаг! Почему? Потому что пароли — это секрет!"
	],
	"too_good_to_be_true": [
		"Ого, бесплатный приз! 🎁 Звучит здорово, правда? Но давай подумаем — а почему он бесплатный? Что этот человек получит взамен?",
		"Мой дедушка-сова говорил: 'Бесплатный сыр бывает только в мышеловке!' 🧀 Как думаешь, что это значит?"
	],
	"pressure_tactics": [
		"Я заметил, что он тебя торопит! ⏰ Это один из красных флагов. Когда кто-то говорит 'быстрее-быстрее' — стоит остановиться и подумать.",
		"Знаешь что? Хорошие решения не нужно принимать быстро! 🦉 Если кто-то торопит — можно сказать: 'Мне нужно подумать'."
	],
	"unknown_person": [
		"Этот человек тебе незнаком, верно? 🤔 А незнакомцам мы не рассказываем личные вещи. Это как закрытая дверь — её не открывают всем подряд!",
		"Давай проверим! Попробуй задать ему вопрос, на который должен знать ответ настоящий помощник. Например: 'Как зовут нашего директора?'"
	],
	"general_help": [
		"Я тут, чтобы помочь! 🦉 Расскажи, что тебя беспокоит?",
		"Хороший вопрос! Давай разберёмся вместе. Что тебе кажется подозрительным?",
		"Молодец, что спрашиваешь! 🌟 Задавать вопросы — это первый шаг к правильному решению."
	],
	"after_mistake": [
		"Ничего страшного! 😊 Ошибки — это часть обучения. Давай разберём, что произошло, чтобы в следующий раз ты заметил опасность раньше.",
		"Эй, не расстраивайся! 🦉 Даже я иногда ошибаюсь. Главное — понять, что пошло не так. Давай вместе посмотрим?"
	],
	"praise": [
		"Вау, отлично! 🌟 Ты заметил красный флаг! Так держать!",
		"Молодец! 👍 Ты правильно задал вопрос. Это помогло тебе понять, что что-то не так.",
		"Супер! 🎉 Ты принял правильное решение. Я горжусь тобой!"
	]
}


func _ready() -> void:
	# В будущем здесь загрузка API ключа
	# api_key = _load_api_key()
	print("[AIManager] Initialized (mock mode: %s)" % use_mock_responses)


## Запросить совет у ментора
func ask_mentor(context: String, situation: String, callback: Callable) -> void:
	mentor_request_started.emit()
	
	if use_mock_responses:
		# Используем заготовленные ответы
		await _get_mock_response(context, callback)
	else:
		# Реальный API запрос
		await _make_api_request(context, situation, callback)


func _get_mock_response(context: String, callback: Callable) -> void:
	# Имитируем задержку сети
	await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
	
	# Получаем ответ по контексту
	var responses: Array = MOCK_RESPONSES.get(context, MOCK_RESPONSES.general_help)
	var response: String = responses[randi() % responses.size()]
	
	mentor_response_received.emit(response)
	callback.call(response)


func _make_api_request(context: String, situation: String, callback: Callable) -> void:
	# Проверяем кэш
	var cache_key := "%s_%s" % [context, situation.hash()]
	if cache_key in response_cache:
		var cached: String = response_cache[cache_key]
		mentor_response_received.emit(cached)
		callback.call(cached)
		return
	
	# Создаём HTTP запрос
	var http := HTTPRequest.new()
	add_child(http)
	
	var headers := [
		"Content-Type: application/json",
		"x-api-key: %s" % api_key,
		"anthropic-version: 2023-06-01"
	]
	
	var body := {
		"model": "claude-3-haiku-20240307",
		"max_tokens": 150,
		"system": MENTOR_SYSTEM_PROMPT,
		"messages": [
			{
				"role": "user",
				"content": "Контекст: %s\n\nСитуация: %s\n\nДай короткий совет ребёнку." % [context, situation]
			}
		]
	}
	
	http.request_completed.connect(func(result, code, _headers, body_bytes):
		http.queue_free()
		
		if result != HTTPRequest.RESULT_SUCCESS or code != 200:
			mentor_request_failed.emit("Ошибка сети")
			# Fallback на mock
			await _get_mock_response(context, callback)
			return
		
		var json := JSON.new()
		if json.parse(body_bytes.get_string_from_utf8()) != OK:
			mentor_request_failed.emit("Ошибка парсинга")
			await _get_mock_response(context, callback)
			return
		
		var response_text: String = json.data.content[0].text
		
		# Кэшируем
		response_cache[cache_key] = response_text
		
		mentor_response_received.emit(response_text)
		callback.call(response_text)
	)
	
	http.request(API_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(body))


## Получить похвалу
func get_praise() -> String:
	var praises: Array = MOCK_RESPONSES.praise
	return praises[randi() % praises.size()]


## Получить утешение после ошибки
func get_encouragement() -> String:
	var responses: Array = MOCK_RESPONSES.after_mistake
	return responses[randi() % responses.size()]
```

## 3.8 AudioManager — Менеджер звука

```gdscript
# scripts/autoload/audio_manager.gd
extends Node

## Менеджер аудио — музыка и звуковые эффекты

signal music_changed(track_name: String)
signal volume_changed(bus_name: String, volume: float)

# Узлы воспроизведения
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8

# Текущий трек
var current_music: String = ""
var music_volume: float = 0.8
var sfx_volume: float = 1.0

# Кэш загруженных звуков
var audio_cache: Dictionary = {}

# Пути к аудио
const MUSIC_PATH := "res://assets/audio/music/"
const SFX_PATH := "res://assets/audio/sfx/"


func _ready() -> void:
	_setup_audio_players()
	_load_settings()
	print("[AudioManager] Initialized")


func _setup_audio_players() -> void:
	# Музыкальный плеер
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Пул SFX плееров
	for i in range(MAX_SFX_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)


func _load_settings() -> void:
	var settings := SaveManager.load_settings()
	set_music_volume(settings.get("music_volume", 0.8))
	set_sfx_volume(settings.get("sfx_volume", 1.0))


## Воспроизвести музыку
func play_music(track_name: String, fade_in: float = 1.0) -> void:
	if track_name == current_music and music_player.playing:
		return
	
	var stream := _load_audio(MUSIC_PATH + track_name)
	if not stream:
		push_error("[AudioManager] Music not found: " + track_name)
		return
	
	# Fade out текущей музыки
	if music_player.playing:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, 0.5)
		await tween.finished
	
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()
	
	# Fade in
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_in)
	
	current_music = track_name
	music_changed.emit(track_name)


## Остановить музыку
func stop_music(fade_out: float = 1.0) -> void:
	if not music_player.playing:
		return
	
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_out)
	await tween.finished
	music_player.stop()
	current_music = ""


## Воспроизвести звуковой эффект
func play_sfx(sfx_name: String, volume_scale: float = 1.0) -> void:
	var stream := _load_audio(SFX_PATH + sfx_name)
	if not stream:
		# Пробуем с расширением
		stream = _load_audio(SFX_PATH + sfx_name + ".wav")
		if not stream:
			stream = _load_audio(SFX_PATH + sfx_name + ".ogg")
	
	if not stream:
		push_warning("[AudioManager] SFX not found: " + sfx_name)
		return
	
	# Находим свободный плеер
	var player := _get_free_sfx_player()
	if player:
		player.stream = stream
		player.volume_db = linear_to_db(sfx_volume * volume_scale)
		player.play()


func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# Если все заняты — используем первый (прерываем)
	return sfx_players[0]


func _load_audio(path: String) -> AudioStream:
	if path in audio_cache:
		return audio_cache[path]
	
	if not ResourceLoader.exists(path):
		return null
	
	var stream: AudioStream = load(path)
	audio_cache[path] = stream
	return stream


## Установить громкость музыки (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	if music_player.playing:
		music_player.volume_db = linear_to_db(music_volume)
	volume_changed.emit("Music", music_volume)


## Установить громкость эффектов (0.0 - 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	volume_changed.emit("SFX", sfx_volume)


## Получить громкость
func get_music_volume() -> float:
	return music_volume


func get_sfx_volume() -> float:
	return sfx_volume
```

---

# ЧАСТЬ 4: ИГРОК И УПРАВЛЕНИЕ

## 4.1 PlayerController — Управление игроком

```gdscript
# scripts/player/player_controller.gd
extends CharacterBody2D

## Контроллер игрока — движение, анимации, взаимодействие

signal interacted_with(target: Node2D)
signal moved(direction: Vector2)

@export_group("Movement")
@export var speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@export_group("Interaction")
@export var interaction_radius: float = 50.0

# Компоненты
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_hint: Sprite2D = $InteractionHint

# Состояние
var can_move: bool = true
var nearby_interactables: Array[Node2D] = []
var current_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false

# Внешний ввод (от виртуального джойстика)
var external_input: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Регистрируем в GameManager
	GameManager.set_player_reference(self)
	
	# Подключаем сигналы
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	interaction_area.body_exited.connect(_on_interaction_area_exited)
	
	# Скрываем подсказку взаимодействия
	if interaction_hint:
		interaction_hint.visible = false
	
	# Подписываемся на изменение состояния игры
	GameManager.game_state_changed.connect(_on_game_state_changed)
	
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if not can_move or not GameManager.can_player_move():
		# Применяем трение, если не можем двигаться
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		_update_animation()
		return
	
	# Получаем направление движения
	var input_direction := _get_input_direction()
	
	if input_direction.length() > 0:
		# Нормализуем для диагонального движения
		input_direction = input_direction.normalized()
		
		# Применяем ускорение
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
		current_direction = input_direction
		is_moving = true
		
		moved.emit(input_direction)
	else:
		# Применяем трение
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = false
	
	move_and_slide()
	_update_animation()


func _get_input_direction() -> Vector2:
	var direction := Vector2.ZERO
	
	# Клавиатура
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	# Если есть внешний ввод (джойстик) — используем его
	if external_input.length() > 0.1:
		direction = external_input
	
	return direction


func _update_animation() -> void:
	if not sprite:
		return
	
	if is_moving:
		# Определяем направление анимации
		if abs(current_direction.x) > abs(current_direction.y):
			if current_direction.x > 0:
				sprite.play("walk_right")
			else:
				sprite.play("walk_left")
		else:
			if current_direction.y > 0:
				sprite.play("walk_down")
			else:
				sprite.play("walk_up")
	else:
		# Idle анимация в последнем направлении
		if abs(current_direction.x) > abs(current_direction.y):
			if current_direction.x > 0:
				sprite.play("idle_right")
			else:
				sprite.play("idle_left")
		else:
			if current_direction.y > 0:
				sprite.play("idle_down")
			else:
				sprite.play("idle_up")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()


## Попытаться взаимодействовать с ближайшим объектом
func _try_interact() -> void:
	if nearby_interactables.is_empty():
		return
	
	if not GameManager.can_player_move():
		return
	
	# Находим ближайший интерактивный объект
	var closest: Node2D = null
	var closest_dist := INF
	
	for interactable in nearby_interactables:
		if not is_instance_valid(interactable):
			continue
		var dist := global_position.distance_to(interactable.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = interactable
	
	if closest and closest.has_method("interact"):
		closest.interact()
		interacted_with.emit(closest)
		AudioManager.play_sfx("interact")


## Установить внешний ввод (от джойстика)
func set_external_input(input: Vector2) -> void:
	external_input = input


## Включить/выключить возможность движения
func set_can_move(value: bool) -> void:
	can_move = value
	if not value:
		velocity = Vector2.ZERO
		is_moving = false
		_update_animation()


## Телепортировать игрока
func teleport_to(position: Vector2) -> void:
	global_position = position


func _on_interaction_area_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and body not in nearby_interactables:
		nearby_interactables.append(body)
		_update_interaction_hint()


func _on_interaction_area_exited(body: Node2D) -> void:
	if body in nearby_interactables:
		nearby_interactables.erase(body)
		_update_interaction_hint()


func _update_interaction_hint() -> void:
	if interaction_hint:
		interaction_hint.visible = not nearby_interactables.is_empty() and can_move


func _on_game_state_changed(_old: GameManager.GameState, new: GameManager.GameState) -> void:
	match new:
		GameManager.GameState.DIALOGUE, GameManager.GameState.PAUSED:
			set_can_move(false)
		GameManager.GameState.PLAYING:
			set_can_move(true)
```

## 4.2 Структура сцены Player (player.tscn)

```
Player (CharacterBody2D)
├── AnimatedSprite2D
│   └── SpriteFrames: player_animations
├── CollisionShape2D
│   └── Shape: CapsuleShape2D (radius=12, height=8)
├── InteractionArea (Area2D)
│   └── CollisionShape2D
│       └── Shape: CircleShape2D (radius=50)
├── InteractionHint (Sprite2D)
│   └── Texture: interact_hint.png
│   └── Position: (0, -40)
└── Camera2D
    └── Position Smoothing: Enabled
    └── Zoom: (2, 2)

Группы: player
Collision Layer: 2 (player)
Collision Mask: 1 (world), 3 (npc), 4 (interactable)
```



## 4.3 VirtualJoystick — Виртуальный джойстик для мобильных

```gdscript
# scripts/ui/virtual_joystick.gd
extends Control

## Виртуальный джойстик для мобильного управления

signal joystick_input(direction: Vector2)
signal joystick_released

@export var max_distance: float = 64.0
@export var deadzone: float = 0.2
@export var visibility_mode: VisibilityMode = VisibilityMode.TOUCHSCREEN_ONLY

enum VisibilityMode {
	ALWAYS,
	TOUCHSCREEN_ONLY,
	HIDDEN
}

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Base/Knob

var is_pressed: bool = false
var touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Устанавливаем центр
	joystick_center = base.size / 2
	knob.position = joystick_center - knob.size / 2
	
	# Видимость
	_update_visibility()


func _update_visibility() -> void:
	match visibility_mode:
		VisibilityMode.ALWAYS:
			visible = true
		VisibilityMode.TOUCHSCREEN_ONLY:
			visible = DisplayServer.is_touchscreen_available()
		VisibilityMode.HIDDEN:
			visible = false


func _input(event: InputEvent) -> void:
	# Обрабатываем только touch события
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Проверяем, что touch в пределах джойстика
		var local_pos := base.get_global_transform().affine_inverse() * event.position
		if base.get_rect().has_point(local_pos):
			is_pressed = true
			touch_index = event.index
			_update_knob_position(event.position)
	else:
		if event.index == touch_index:
			_reset_joystick()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if is_pressed and event.index == touch_index:
		_update_knob_position(event.position)


func _update_knob_position(screen_position: Vector2) -> void:
	var local_pos := base.get_global_transform().affine_inverse() * screen_position
	var direction := local_pos - joystick_center
	
	# Ограничиваем расстояние
	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance
	
	# Устанавливаем позицию ручки
	knob.position = joystick_center + direction - knob.size / 2
	
	# Вычисляем направление ввода (0 to 1)
	var input_direction := direction / max_distance
	
	# Применяем deadzone
	if input_direction.length() < deadzone:
		input_direction = Vector2.ZERO
	
	# Отправляем сигнал
	joystick_input.emit(input_direction)
	
	# Также обновляем игрока напрямую, если есть
	if GameManager.player_node:
		GameManager.player_node.set_external_input(input_direction)


func _reset_joystick() -> void:
	is_pressed = false
	touch_index = -1
	knob.position = joystick_center - knob.size / 2
	
	joystick_released.emit()
	joystick_input.emit(Vector2.ZERO)
	
	if GameManager.player_node:
		GameManager.player_node.set_external_input(Vector2.ZERO)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_reset_joystick()
```

---

# ЧАСТЬ 5: NPC СИСТЕМА

## 5.1 NPCBase — Базовый NPC

```gdscript
# scripts/npc/npc_base.gd
extends CharacterBody2D
class_name NPCBase

## Базовый класс для всех NPC

signal interaction_started
signal interaction_ended

@export_group("NPC Info")
@export var npc_id: String = "npc_default"
@export var npc_name: String = "NPC"
@export var portrait_id: String = ""

@export_group("Dialogue")
@export var dialogue_id: String = ""  # ID файла диалога
@export var one_time_dialogue: bool = false  # Диалог только один раз

@export_group("Appearance")
@export var idle_animation: String = "idle_down"

# Компоненты
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea

# Состояние
var has_been_talked_to: bool = false
var is_interacting: bool = false


func _ready() -> void:
	add_to_group("npc")
	add_to_group("interactable")
	
	# Проигрываем idle анимацию
	if sprite and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(idle_animation):
			sprite.play(idle_animation)
	
	# Проверяем флаг "уже разговаривал"
	if one_time_dialogue:
		has_been_talked_to = GameManager.player_data.has_flag("talked_to_%s" % npc_id)


## Взаимодействие с NPC
func interact() -> void:
	if is_interacting:
		return
	
	if one_time_dialogue and has_been_talked_to:
		# Можно показать короткое сообщение "Мне нечего добавить"
		return
	
	is_interacting = true
	interaction_started.emit()
	
	# Поворачиваемся к игроку
	_face_player()
	
	# Запускаем диалог
	if not dialogue_id.is_empty():
		DialogueManager.start_dialogue(dialogue_id, npc_id)
		
		# Ждём завершения диалога
		await DialogueManager.dialogue_ended
		
		# Отмечаем, что поговорили
		if one_time_dialogue:
			has_been_talked_to = true
			GameManager.player_data.set_flag("talked_to_%s" % npc_id)
	
	is_interacting = false
	interaction_ended.emit()


func _face_player() -> void:
	if not GameManager.player_node or not sprite:
		return
	
	var direction := GameManager.player_node.global_position - global_position
	
	# Выбираем анимацию поворота
	var anim_name := "idle_down"
	if abs(direction.x) > abs(direction.y):
		anim_name = "idle_right" if direction.x > 0 else "idle_left"
	else:
		anim_name = "idle_down" if direction.y > 0 else "idle_up"
	
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


## Установить диалог (для квестов)
func set_dialogue(new_dialogue_id: String) -> void:
	dialogue_id = new_dialogue_id


## Получить данные для диалога
func get_dialogue_data() -> Dictionary:
	return {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"portrait_id": portrait_id
	}
```

## 5.2 Структура сцены NPC (npc_base.tscn)

```
NPCBase (CharacterBody2D) [npc_base.gd]
├── AnimatedSprite2D
│   └── SpriteFrames: npc_animations
├── CollisionShape2D
│   └── Shape: CapsuleShape2D (radius=12, height=8)
├── InteractionArea (Area2D)
│   └── CollisionShape2D
│       └── Shape: CircleShape2D (radius=40)
└── NPCLabel (Label)  [опционально]
    └── Text: NPC Name
    └── Position: (0, -50)

Группы: npc, interactable
Collision Layer: 3 (npc)
Collision Mask: 1 (world)
```

## 5.3 Stranger NPC — Мошенник для квеста 1

```gdscript
# scripts/npc/stranger_npc.gd
extends NPCBase

## NPC-Мошенник для первого квеста "Новый шкафчик"

@export var quest_id: String = "quest_01_locker"

var quest_state: String = "not_started"


func _ready() -> void:
	super._ready()
	
	npc_id = "stranger_helper"
	npc_name = "Незнакомец"
	dialogue_id = "quest_01_locker"
	
	# Подписываемся на события квеста
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_completed.connect(_on_quest_completed)
	DialogueManager.effects_applied.connect(_on_effects_applied)
	
	# Проверяем начальное состояние
	_check_initial_state()


func _check_initial_state() -> void:
	# Если квест уже выполнен — скрываем NPC
	if GameManager.player_data.is_quest_completed(quest_id):
		queue_free()
		return
	
	# Если квест активен — показываем
	if GameManager.player_data.current_quest_id == quest_id:
		quest_state = "active"


func _on_quest_started(started_quest_id: String, _data: Dictionary) -> void:
	if started_quest_id == quest_id:
		quest_state = "active"


func _on_quest_completed(completed_quest_id: String, outcome: String) -> void:
	if completed_quest_id == quest_id:
		quest_state = "completed"
		
		# Анимация исчезновения мошенника
		if outcome == "success":
			# Игрок распознал мошенника — он убегает
			_run_away()
		else:
			# Игрок попался — мошенник уходит с "добычей"
			_walk_away_slowly()


func _on_effects_applied(effects: Dictionary) -> void:
	# Проверяем флаги из диалога
	if effects.has("flags"):
		if effects.flags.get("spotted_scammer", false):
			# Игрок раскусил мошенника
			pass
		elif effects.flags.get("gave_password", false):
			# Игрок дал пароль
			pass


func _run_away() -> void:
	# Быстрая анимация убегания
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(300, 0), 0.5)
	tween.tween_callback(queue_free)


func _walk_away_slowly() -> void:
	# Медленный уход
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
```

---

# ЧАСТЬ 6: UI СИСТЕМА

## 6.1 DialogueUI — Окно диалога

```gdscript
# scripts/dialogue/dialogue_ui.gd
extends CanvasLayer

## UI для отображения диалогов

@export var typing_speed: float = 0.03  # секунд на символ
@export var fast_typing_speed: float = 0.01

@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var portrait_texture: TextureRect = $DialoguePanel/HBox/Portrait
@onready var speaker_label: Label = $DialoguePanel/HBox/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $DialoguePanel/HBox/VBox/TextLabel
@onready var choices_container: VBoxContainer = $DialoguePanel/HBox/VBox/ChoicesContainer
@onready var continue_indicator: TextureRect = $DialoguePanel/ContinueIndicator
@onready var red_flags_container: HBoxContainer = $DialoguePanel/RedFlagsContainer

const CHOICE_BUTTON_SCENE := preload("res://scenes/ui/choice_button.tscn")

# Состояние
var is_typing: bool = false
var full_text: String = ""
var can_continue: bool = false
var current_node: Dictionary = {}


func _ready() -> void:
	# Скрываем при старте
	hide_dialogue()
	
	# Подключаем сигналы DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.node_displayed.connect(_on_node_displayed)
	DialogueManager.choices_displayed.connect(_on_choices_displayed)
	DialogueManager.reflection_started.connect(_on_reflection_started)


func _on_dialogue_started(_dialogue_id: String, _npc_id: String) -> void:
	show_dialogue()


func _on_dialogue_ended(_dialogue_id: String) -> void:
	hide_dialogue()


func _on_node_displayed(node: Dictionary) -> void:
	current_node = node
	
	# Очищаем предыдущие элементы
	_clear_choices()
	continue_indicator.visible = false
	can_continue = false
	
	# Устанавливаем спикера
	var speaker_name: String = node.get("speaker_name", _get_speaker_display_name(node.get("speaker", "")))
	speaker_label.text = speaker_name
	speaker_label.visible = not speaker_name.is_empty()
	
	# Устанавливаем портрет
	_set_portrait(node.get("portrait", ""))
	
	# Показываем красные флаги (если навык позволяет)
	_show_red_flags(node.get("red_flags", []))
	
	# Запускаем печатание текста
	_start_typing(node.get("text", ""))


func _on_choices_displayed(choices: Array) -> void:
	_clear_choices()
	continue_indicator.visible = false
	
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var button: Button = CHOICE_BUTTON_SCENE.instantiate()
		button.setup(choice, i)
		button.choice_selected.connect(_on_choice_selected)
		choices_container.add_child(button)


func _on_reflection_started(reflection_data: Dictionary) -> void:
	# Показываем окно рефлексии
	# TODO: Отдельный UI для рефлексии
	pass


func _on_choice_selected(index: int) -> void:
	DialogueManager.select_choice(index)
	AudioManager.play_sfx("choice_select")


func _start_typing(text: String) -> void:
	full_text = text
	text_label.text = ""
	is_typing = true
	
	for i in range(text.length()):
		if not is_typing:
			# Прервано — показываем весь текст
			text_label.text = full_text
			break
		
		text_label.text += text[i]
		
		# Звук печатания (каждые несколько символов)
		if i % 3 == 0:
			AudioManager.play_sfx("dialogue_char", 0.3)
		
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	_on_typing_finished()


func _skip_typing() -> void:
	is_typing = false
	text_label.text = full_text


func _on_typing_finished() -> void:
	# Если нет выборов — показываем индикатор продолжения
	if choices_container.get_child_count() == 0:
		continue_indicator.visible = true
		can_continue = true


func _input(event: InputEvent) -> void:
	if not dialogue_panel.visible:
		return
	
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if is_typing:
			_skip_typing()
		elif can_continue:
			DialogueManager.continue_dialogue()
			AudioManager.play_sfx("interact")


func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()


func show_dialogue() -> void:
	dialogue_panel.visible = true
	
	# Анимация появления
	dialogue_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(dialogue_panel, "modulate:a", 1.0, 0.2)


func hide_dialogue() -> void:
	var tween := create_tween()
	tween.tween_property(dialogue_panel, "modulate:a", 0.0, 0.2)
	await tween.finished
	dialogue_panel.visible = false
	
	_clear_choices()
	is_typing = false
	can_continue = false


func _get_speaker_display_name(speaker_id: String) -> String:
	match speaker_id:
		"player": return "Я"
		"mentor": return "🦉 Совёнок"
		"stranger": return "Незнакомец"
		"teacher": return "Учительница"
		"narrator": return ""
		_: return speaker_id


func _set_portrait(portrait_id: String) -> void:
	if portrait_id.is_empty():
		portrait_texture.visible = false
		return
	
	var path := "res://assets/sprites/portraits/%s.png" % portrait_id
	if ResourceLoader.exists(path):
		portrait_texture.texture = load(path)
		portrait_texture.visible = true
	else:
		portrait_texture.visible = false


func _show_red_flags(flags: Array) -> void:
	# Очищаем предыдущие
	for child in red_flags_container.get_children():
		child.queue_free()
	
	if flags.is_empty():
		red_flags_container.visible = false
		return
	
	# Проверяем навык наблюдательности
	var observe_level: int = SkillManager.get_player_skill_level("observe")
	var bonuses: Dictionary = SkillManager.get_skill_bonuses("observe")
	
	if not bonuses.get("see_red_flags", false) and observe_level < 25:
		red_flags_container.visible = false
		return
	
	# Показываем флаги в зависимости от уровня
	for flag in flags:
		var flag_label := Label.new()
		
		if observe_level >= 50:
			# Явный флаг
			flag_label.text = "🚩 %s" % _get_flag_description(flag)
			flag_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		elif observe_level >= 25:
			# Смутное ощущение
			flag_label.text = "🤔 Что-то не так..."
			flag_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
		
		red_flags_container.add_child(flag_label)
		
		# Обновляем статистику
		GameManager.player_data.red_flags_noticed += 1
		break  # Показываем только один намёк для низкого уровня
	
	red_flags_container.visible = red_flags_container.get_child_count() > 0


func _get_flag_description(flag_id: String) -> String:
	var descriptions := {
		"asks_password": "Просит пароль!",
		"unknown_person": "Это незнакомец",
		"pressure": "Торопит!",
		"no_proof": "Нет доказательств",
		"too_good_to_be_true": "Слишком хорошо...",
		"secrecy": "Просит скрывать"
	}
	return descriptions.get(flag_id, flag_id)
```

## 6.2 ChoiceButton — Кнопка выбора в диалоге

```gdscript
# scripts/dialogue/choice_button.gd
extends Button

## Кнопка выбора ответа в диалоге

signal choice_selected(index: int)

var choice_index: int = -1
var choice_data: Dictionary = {}
var is_locked: bool = false


func setup(data: Dictionary, index: int) -> void:
	choice_data = data
	choice_index = index
	
	# Устанавливаем текст
	text = data.get("text", "...")
	
	# Проверяем, заблокирован ли выбор
	is_locked = data.get("is_locked", false)
	
	if is_locked:
		# Серый текст, показываем причину
		disabled = true
		modulate = Color(0.5, 0.5, 0.5)
		tooltip_text = data.get("lock_reason", "Недоступно")
	else:
		disabled = false
		modulate = Color.WHITE
	
	# Добавляем иконки если есть эффекты
	if data.has("effects"):
		var effects: Dictionary = data.effects
		
		# Иконка навыка
		if effects.has("skills"):
			var skill_icons := ""
			for skill_id in effects.skills:
				skill_icons += _get_skill_icon(skill_id) + " "
			if not skill_icons.is_empty():
				text = "%s [%s]" % [text, skill_icons.strip_edges()]
	
	# Подключаем сигнал
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if not is_locked:
		choice_selected.emit(choice_index)


func _get_skill_icon(skill_id: String) -> String:
	var icons := {
		"observe": "👁️",
		"question": "❓",
		"explain": "💬",
		"compare": "⚖️",
		"decide": "🎯",
		"consequence": "🔗"
	}
	return icons.get(skill_id, "")
```



---

# ЧАСТЬ 7: ПЕРВАЯ ЛОКАЦИЯ — ШКОЛЬНЫЙ КОРИДОР

## 7.1 Описание локации

```
ЛОКАЦИЯ: school_hallway (Школьный коридор)
РАЗМЕР: 1920 x 1280 пикселей (60x40 тайлов по 32px)
ТЕМА: Первый день в школе, знакомство с шкафчиком

СТРУКТУРА:
┌────────────────────────────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ <- Стена
│▓                                                    ▓│
│▓  [ШКАФЧИКИ]  [ШКАФЧИКИ]  [ШКАФЧИКИ]  [ДВЕРЬ]       ▓│
│▓   █ █ █ █     █ █ █ █     █ █ ★ █                  ▓│  ★ = Шкафчик игрока
│▓                                                    ▓│
│▓                           ┌─────────┐              ▓│
│▓                           │STRANGER │<- Мошенник   ▓│
│▓                           └─────────┘              ▓│
│▓        ┌────────┐                                  ▓│
│▓        │ PLAYER │ <- Точка спавна                  ▓│
│▓        └────────┘                                  ▓│
│▓                                                    ▓│
│▓  [СКАМЕЙКА]              [РАСТЕНИЕ]    [ДОСКА]     ▓│
│▓                                                    ▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
└────────────────────────────────────────────────────────┘

ОБЪЕКТЫ:
- Шкафчики (интерактивные) — ряд у верхней стены
- Шкафчик игрока (★) — с подсветкой, цель квеста
- Мошенник NPC — появляется когда игрок подходит к шкафчику
- Декорации: скамейки, растения, доска объявлений

ТРИГГЕРЫ:
- При подходе к шкафчику игрока → появляется мошенник
- При взаимодействии с мошенником → запуск диалога
```

## 7.2 TileSet для школы (school_tileset.tres)

```gdscript
# Настройки TileSet в редакторе Godot:
# 1. Создать TileSet ресурс
# 2. Добавить TileSetAtlasSource из school_tiles.png
# 3. Настроить коллизии

# Структура тайлсета (32x32 px каждый тайл):
# 
# school_tiles.png (512x512):
# ┌────┬────┬────┬────┬────┬────┬────┬────┐
# │ 0  │ 1  │ 2  │ 3  │ 4  │ 5  │ 6  │ 7  │  <- Ряд 0: Полы
# │Пол │Пол2│Пол3│Ковр│    │    │    │    │
# ├────┼────┼────┼────┼────┼────┼────┼────┤
# │ 8  │ 9  │ 10 │ 11 │ 12 │ 13 │ 14 │ 15 │  <- Ряд 1: Стены
# │СтнВ│СтнН│СтнЛ│СтнП│Угол│Угол│Угол│Угол│
# ├────┼────┼────┼────┼────┼────┼────┼────┤
# │ 16 │ 17 │ 18 │ 19 │ 20 │ 21 │ 22 │ 23 │  <- Ряд 2: Шкафчики
# │Шкф │ШкфО│ШкфИ│ШкфЗ│    │    │    │    │
# ├────┼────┼────┼────┼────┼────┼────┼────┤
# │ 24 │ 25 │ 26 │ 27 │ 28 │ 29 │ 30 │ 31 │  <- Ряд 3: Мебель
# │Скам│Раст│Доск│Дврь│ДврО│    │    │    │
# └────┴────┴────┴────┴────┴────┴────┴────┘

# СЛОИ TileMap:
# Layer 0: Пол (Z-index: 0)
# Layer 1: Стены и мебель (Z-index: 1) — с коллизиями
# Layer 2: Декорации сверху (Z-index: 2)
```

## 7.3 Сцена школьного коридора (school_hallway.tscn)

```
SchoolHallway (Node2D)
├── TileMap
│   ├── Layer 0: Floor
│   ├── Layer 1: Walls (collision)
│   └── Layer 2: Decorations
│
├── Objects (Node2D)
│   ├── PlayerLocker (Area2D) [locker.gd]
│   │   ├── Sprite2D (locker_highlight.png)
│   │   ├── CollisionShape2D
│   │   └── HighlightEffect (AnimationPlayer)
│   │
│   └── OtherLockers (Node2D)
│       ├── Locker1, Locker2, Locker3... (StaticBody2D)
│
├── NPCs (Node2D)
│   └── StrangerNPC (CharacterBody2D) [stranger_npc.gd]
│       └── visible: false (появляется по триггеру)
│
├── Triggers (Node2D)
│   └── LockerApproachTrigger (Area2D)
│       └── CollisionShape2D (большая зона перед шкафчиками)
│
├── SpawnPoints (Node2D)
│   └── PlayerSpawn (Marker2D)
│       └── Position: (960, 800)
│
├── Player (PackedScene: player.tscn)
│
├── UI (CanvasLayer)
│   ├── HUD (Control) [hud.tscn]
│   ├── DialogueBox (Control) [dialogue_box.tscn]
│   └── VirtualJoystick (Control) [virtual_joystick.tscn]
│
└── Audio (Node)
    └── BGM (AudioStreamPlayer)
        └── Stream: school_theme.ogg
```

## 7.4 Скрипт локации школьного коридора

```gdscript
# scenes/locations/school/school_hallway.gd
extends Node2D

## Локация: Школьный коридор
## Первая локация игры, место квеста "Новый шкафчик"

@onready var player: CharacterBody2D = $Player
@onready var stranger_npc: NPCBase = $NPCs/StrangerNPC
@onready var player_locker: Area2D = $Objects/PlayerLocker
@onready var locker_trigger: Area2D = $Triggers/LockerApproachTrigger
@onready var player_spawn: Marker2D = $SpawnPoints/PlayerSpawn
@onready var bgm: AudioStreamPlayer = $Audio/BGM

var stranger_appeared: bool = false


func _ready() -> void:
	# Устанавливаем позицию игрока
	_setup_player_position()
	
	# Настраиваем триггеры
	locker_trigger.body_entered.connect(_on_locker_approach)
	player_locker.body_entered.connect(_on_player_near_locker)
	
	# Скрываем мошенника изначально
	stranger_npc.visible = false
	stranger_npc.set_process(false)
	
	# Подписываемся на события
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	QuestManager.quest_completed.connect(_on_quest_completed)
	
	# Запускаем музыку
	AudioManager.play_music("school_theme.ogg")
	
	# Проверяем состояние квеста
	_check_quest_state()


func _setup_player_position() -> void:
	# Используем сохранённую позицию или точку спавна
	var saved_pos: Vector2 = GameManager.player_data.last_position
	
	if saved_pos != Vector2.ZERO and GameManager.player_data.current_location == scene_file_path:
		player.global_position = saved_pos
	else:
		player.global_position = player_spawn.global_position
	
	# Сохраняем локацию
	GameManager.player_data.current_location = scene_file_path


func _check_quest_state() -> void:
	var current_quest: String = GameManager.player_data.current_quest_id
	
	# Если квест уже выполнен — мошенник не появляется
	if GameManager.player_data.is_quest_completed("quest_01_locker"):
		stranger_npc.queue_free()
		stranger_appeared = true
		return
	
	# Если квест активен и мошенник уже появлялся
	if GameManager.player_data.has_flag("stranger_appeared"):
		_show_stranger()


func _on_locker_approach(body: Node2D) -> void:
	if body.is_in_group("player") and not stranger_appeared:
		# Игрок подошёл к зоне шкафчиков
		_trigger_stranger_appearance()


func _on_player_near_locker(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Подсветка шкафчика
		var highlight: AnimationPlayer = player_locker.get_node_or_null("HighlightEffect")
		if highlight:
			highlight.play("pulse")


func _trigger_stranger_appearance() -> void:
	if stranger_appeared:
		return
	
	stranger_appeared = true
	GameManager.player_data.set_flag("stranger_appeared")
	
	# Показываем мошенника с анимацией
	_show_stranger()
	
	# Небольшая пауза перед диалогом
	await get_tree().create_timer(0.5).timeout
	
	# Мошенник сам начинает диалог
	stranger_npc.interact()


func _show_stranger() -> void:
	stranger_npc.visible = true
	stranger_npc.set_process(true)
	
	# Анимация появления
	stranger_npc.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(stranger_npc, "modulate:a", 1.0, 0.3)


func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "quest_01_locker":
		# Проверяем результат диалога
		pass


func _on_quest_completed(quest_id: String, outcome: String) -> void:
	if quest_id == "quest_01_locker":
		# Квест завершён
		print("Quest 01 completed with outcome: " + outcome)
		
		# Мошенник исчезает (обрабатывается в stranger_npc.gd)


func _exit_tree() -> void:
	# Сохраняем позицию при выходе
	if player:
		GameManager.player_data.last_position = player.global_position
	GameManager.save_game()
```

---