# ТЗ ДЛЯ CLAUDE CODE: Godot 4 MVP "АнтиОбман"
## Пошаговая инструкция для создания первой локации

**Версия:** 1.0  
**Дата:** 2025-12-03  
**Движок:** Godot 4.3+  
**Язык:** GDScript  

---

# ЧАСТЬ 0: ОБЗОР ДЛЯ CLAUDE CODE

## Что нужно создать

Это образовательная 2D RPG для детей 6-10 лет. Стиль — пиксель-арт top-down (вид сверху), как Soul Knight или Stardew Valley.

**MVP включает:**
1. ✅ Проект Godot с правильной структурой
2. ✅ Передвижение персонажа (виртуальный джойстик для мобильных)
3. ✅ Первая локация "Школа" с тайловой картой
4. ✅ NPC с которыми можно взаимодействовать
5. ✅ Диалоговая система с выборами
6. ✅ Система навыков (6 навыков критического мышления)
7. ✅ Первый квест "Новый шкафчик"
8. ✅ ИИ-ментор "Совёнок" (заглушка + структура для Claude API)
9. ✅ Базовый UI (HUD, диалоговое окно)
10. ✅ Сохранение прогресса

---

# ЧАСТЬ 1: СОЗДАНИЕ ПРОЕКТА

## 1.1 Инициализация проекта Godot

```bash
# Структура папок (создать вручную или через Godot)
antiobman/
├── project.godot
├── .gitignore
├── assets/
├── scenes/
├── scripts/
├── data/
└── export/
```

## 1.2 Файл project.godot

```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly.

config_version=5

[application]
config/name="АнтиОбман"
config/description="Образовательная RPG для детей"
config/version="0.1.0"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.3", "Mobile")
config/icon="res://assets/icon.png"

[autoload]
GameManager="*res://scripts/autoload/game_manager.gd"
DialogueManager="*res://scripts/autoload/dialogue_manager.gd"
SkillManager="*res://scripts/autoload/skill_manager.gd"
QuestManager="*res://scripts/autoload/quest_manager.gd"
SaveManager="*res://scripts/autoload/save_manager.gd"
AIManager="*res://scripts/autoload/ai_manager.gd"
AudioManager="*res://scripts/autoload/audio_manager.gd"

[display]
window/size/viewport_width=1080
window/size/viewport_height=1920
window/size/mode=2
window/size/resizable=false
window/handheld/orientation=1
window/stretch/mode="viewport"
window/stretch/aspect="expand"

[input]
move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194320,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194322,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194319,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194321,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
interact={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":69,"key_label":0,"unicode":101,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":32,"key_label":0,"unicode":32,"location":0,"echo":false,"script":null)
]
}
menu={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194305,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}

[input_devices]
pointing/emulate_touch_from_mouse=true

[layer_names]
2d_physics/layer_1="world"
2d_physics/layer_2="player"
2d_physics/layer_3="npc"
2d_physics/layer_4="interactable"
2d_physics/layer_5="trigger"

[rendering]
textures/canvas_textures/default_texture_filter=0
renderer/rendering_method="mobile"
textures/vram_compression/import_etc2_astc=true
environment/defaults/default_clear_color=Color(0.2, 0.2, 0.25, 1)
2d/snap/snap_2d_transforms_to_pixel=true
2d/snap/snap_2d_vertices_to_pixel=true
```

## 1.3 Файл .gitignore

```gitignore
# Godot 4+ specific ignores
.godot/

# Godot-specific ignores
*.translation

# Imported textures and samples
.import/

# Mono-specific ignores
.mono/
data_*/
mono_crash.*.json

# Export
export/android/*.apk
export/android/*.aab
export/ios/*.ipa

# OS generated
.DS_Store
Thumbs.db

# IDE
.idea/
*.swp
*.swo
*~
```

---

# ЧАСТЬ 2: СТРУКТУРА ПАПОК И ФАЙЛОВ

## 2.1 Полная структура проекта

```
antiobman/
├── project.godot
├── .gitignore
│
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   │   ├── player/
│   │   │   │   ├── player_idle.png          # 64x64, 4 направления
│   │   │   │   └── player_walk.png          # 64x64, 4 направления x 4 кадра
│   │   │   ├── mentor/
│   │   │   │   └── owl_mentor.png           # 48x48, эмоции
│   │   │   └── npcs/
│   │   │       ├── stranger.png             # 64x64
│   │   │       ├── teacher.png              # 64x64
│   │   │       └── student.png              # 64x64
│   │   │
│   │   ├── tiles/
│   │   │   ├── school_floor.png             # 32x32 тайлы
│   │   │   ├── school_walls.png             # 32x32 тайлы
│   │   │   └── school_objects.png           # Мебель, шкафчики
│   │   │
│   │   ├── ui/
│   │   │   ├── dialogue_box.png             # 9-slice панель
│   │   │   ├── button_normal.png
│   │   │   ├── button_pressed.png
│   │   │   ├── joystick_base.png            # 128x128
│   │   │   ├── joystick_knob.png            # 64x64
│   │   │   └── icons/
│   │   │       ├── skill_observe.png        # 32x32
│   │   │       ├── skill_question.png
│   │   │       ├── skill_explain.png
│   │   │       ├── skill_compare.png
│   │   │       ├── skill_decide.png
│   │   │       ├── skill_consequence.png
│   │   │       ├── red_flag.png
│   │   │       └── interact_hint.png
│   │   │
│   │   └── effects/
│   │       ├── highlight.png
│   │       └── particles/
│   │
│   ├── fonts/
│   │   ├── main_font.ttf                    # Основной шрифт (русский)
│   │   └── main_font.tres                   # FontFile ресурс
│   │
│   └── audio/
│       ├── music/
│       │   └── school_theme.ogg
│       └── sfx/
│           ├── step.wav
│           ├── interact.wav
│           ├── dialogue_char.wav
│           ├── choice_select.wav
│           └── skill_up.wav
│
├── scenes/
│   ├── main.tscn                            # Главная сцена
│   ├── game_world.tscn                      # Игровой мир
│   │
│   ├── player/
│   │   └── player.tscn                      # Игрок
│   │
│   ├── npcs/
│   │   ├── npc_base.tscn                    # Базовый NPC
│   │   ├── mentor.tscn                      # Совёнок
│   │   ├── stranger.tscn                    # Мошенник (квест 1)
│   │   └── teacher.tscn                     # Учитель
│   │
│   ├── ui/
│   │   ├── hud.tscn                         # Игровой интерфейс
│   │   ├── dialogue_box.tscn                # Окно диалога
│   │   ├── choice_button.tscn               # Кнопка выбора
│   │   ├── virtual_joystick.tscn            # Мобильный джойстик
│   │   ├── skill_panel.tscn                 # Панель навыков
│   │   ├── mentor_panel.tscn                # Окно ментора
│   │   ├── reflection_popup.tscn            # Окно рефлексии
│   │   ├── pause_menu.tscn                  # Меню паузы
│   │   └── main_menu.tscn                   # Главное меню
│   │
│   ├── locations/
│   │   └── school/
│   │       ├── school.tscn                  # Полная локация школы
│   │       ├── school_hallway.tscn          # Коридор (зона квеста 1)
│   │       └── school_tileset.tres          # TileSet для школы
│   │
│   └── objects/
│       ├── locker.tscn                      # Шкафчик (интерактивный)
│       ├── door.tscn                        # Дверь
│       └── interactable_base.tscn           # Базовый интерактивный объект
│
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   ├── dialogue_manager.gd
│   │   ├── skill_manager.gd
│   │   ├── quest_manager.gd
│   │   ├── save_manager.gd
│   │   ├── ai_manager.gd
│   │   └── audio_manager.gd
│   │
│   ├── player/
│   │   ├── player_controller.gd
│   │   └── player_data.gd
│   │
│   ├── npc/
│   │   ├── npc_base.gd
│   │   └── mentor_npc.gd
│   │
│   ├── dialogue/
│   │   ├── dialogue_ui.gd
│   │   └── choice_button.gd
│   │
│   ├── ui/
│   │   ├── hud.gd
│   │   ├── virtual_joystick.gd
│   │   ├── skill_panel.gd
│   │   └── main_menu.gd
│   │
│   ├── objects/
│   │   ├── interactable.gd
│   │   └── locker.gd
│   │
│   └── resources/
│       ├── player_data_resource.gd
│       ├── quest_resource.gd
│       └── dialogue_resource.gd
│
├── data/
│   ├── dialogues/
│   │   ├── quest_01_locker.json             # Квест "Новый шкафчик"
│   │   ├── npc_teacher_intro.json           # Знакомство с учителем
│   │   └── mentor_hints.json                # Подсказки Совёнка
│   │
│   ├── quests/
│   │   └── quests.json                      # Все квесты
│   │
│   └── skills/
│       └── skills.json                      # Описание навыков
│
└── export/
    ├── android/
    │   └── export_presets.cfg
    └── ios/
```

---

# ЧАСТЬ 3: AUTOLOAD СКРИПТЫ (ГЛОБАЛЬНЫЕ)

## 3.1 GameManager — Главный менеджер игры


```gdscript
# scripts/autoload/game_manager.gd
extends Node

## Глобальный менеджер игры
## Управляет состоянием игры, данными игрока, переходами между сценами

signal game_state_changed(old_state: GameState, new_state: GameState)
signal game_paused
signal game_resumed
signal player_data_loaded
signal scene_changed(scene_name: String)

enum GameState {
	MENU,           # Главное меню
	PLAYING,        # Игровой процесс
	DIALOGUE,       # Диалог (движение отключено)
	PAUSED,         # Пауза
	CUTSCENE,       # Кат-сцена
	LOADING         # Загрузка
}

# Текущее состояние
var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.MENU

# Данные игрока (загружаются из сохранения)
var player_data: PlayerData = null

# Текущая локация
var current_location: String = ""

# Ссылка на игрока (устанавливается при загрузке сцены)
var player_node: CharacterBody2D = null

# Константы
const SAVE_FILE_PATH := "user://save_data.json"
const AUTO_SAVE_INTERVAL := 60.0  # секунд

# Таймер автосохранения
var auto_save_timer: Timer


func _ready() -> void:
	# Создаём или загружаем данные игрока
	_load_or_create_player_data()
	
	# Настраиваем автосохранение
	_setup_auto_save()
	
	print("[GameManager] Initialized")


func _setup_auto_save() -> void:
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	auto_save_timer.autostart = false
	auto_save_timer.timeout.connect(_on_auto_save)
	add_child(auto_save_timer)


func _load_or_create_player_data() -> void:
	# Пытаемся загрузить сохранение
	var loaded_data = SaveManager.load_game()
	
	if loaded_data:
		player_data = loaded_data
		print("[GameManager] Player data loaded")
	else:
		# Создаём новые данные
		player_data = PlayerData.new()
		print("[GameManager] New player data created")
	
	player_data_loaded.emit()


## Изменить состояние игры
func change_state(new_state: GameState) -> void:
	if new_state == current_state:
		return
	
	previous_state = current_state
	current_state = new_state
	
	match new_state:
		GameState.MENU:
			get_tree().paused = false
			auto_save_timer.stop()
		
		GameState.PLAYING:
			get_tree().paused = false
			auto_save_timer.start()
			game_resumed.emit()
		
		GameState.DIALOGUE:
			# Диалог не ставит игру на паузу, но блокирует движение
			get_tree().paused = false
		
		GameState.PAUSED:
			get_tree().paused = true
			game_paused.emit()
		
		GameState.CUTSCENE:
			get_tree().paused = false
		
		GameState.LOADING:
			get_tree().paused = false
	
	game_state_changed.emit(previous_state, new_state)
	print("[GameManager] State changed: %s -> %s" % [
		GameState.keys()[previous_state], 
		GameState.keys()[new_state]
	])


## Загрузить локацию
func load_location(location_path: String) -> void:
	change_state(GameState.LOADING)
	
	# Сохраняем перед переходом
	save_game()
	
	# Загружаем сцену
	var packed_scene = load(location_path)
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
		current_location = location_path
		scene_changed.emit(location_path)
		
		# Небольшая задержка для инициализации сцены
		await get_tree().create_timer(0.1).timeout
		change_state(GameState.PLAYING)
	else:
		push_error("[GameManager] Failed to load location: " + location_path)
		change_state(previous_state)


## Сохранить игру
func save_game() -> void:
	if player_data:
		SaveManager.save_game(player_data)
		print("[GameManager] Game saved")


## Начать новую игру
func new_game() -> void:
	player_data = PlayerData.new()
	player_data.is_new_game = false
	
	# Запускаем первый квест
	QuestManager.start_quest("quest_01_locker")
	
	# Загружаем первую локацию
	load_location("res://scenes/locations/school/school_hallway.tscn")


## Продолжить игру
func continue_game() -> void:
	if player_data and not player_data.current_location.is_empty():
		load_location(player_data.current_location)
	else:
		new_game()


## Вернуться в меню
func return_to_menu() -> void:
	save_game()
	change_state(GameState.MENU)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


## Установить ссылку на игрока
func set_player_reference(player: CharacterBody2D) -> void:
	player_node = player


## Проверить, можно ли двигаться
func can_player_move() -> bool:
	return current_state == GameState.PLAYING


func _on_auto_save() -> void:
	if current_state == GameState.PLAYING:
		save_game()


func _notification(what: int) -> void:
	# Сохраняем при сворачивании приложения
	if what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()
```

## 3.2 PlayerData — Данные игрока (Resource)

```gdscript
# scripts/resources/player_data_resource.gd
# Также создать файл scripts/player/player_data.gd как class_name
class_name PlayerData
extends Resource

## Данные игрока — сохраняемый ресурс

# Базовая информация
@export var player_name: String = "Игрок"
@export var avatar_id: int = 0

# Прогресс
@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next_level: int = 100

# 6 навыков критического мышления (0-100)
@export var skills: Dictionary = {
	"observe": 0,       # 👁️ Замечать различия
	"question": 0,      # ❓ Задавать вопросы
	"explain": 0,       # 💬 Объяснять действия
	"compare": 0,       # ⚖️ Сравнивать
	"decide": 0,        # 🎯 Принимать решения
	"consequence": 0    # 🔗 Понимать последствия
}

# Игровые флаги (для отслеживания событий)
@export var flags: Dictionary = {}

# Квесты
@export var completed_quests: Array[String] = []
@export var current_quest_id: String = ""
@export var quest_progress: Dictionary = {}  # quest_id -> {step, data}

# Позиция в мире
@export var current_location: String = ""
@export var last_position: Vector2 = Vector2.ZERO

# Статистика
@export var play_time_seconds: int = 0
@export var dialogues_completed: int = 0
@export var correct_decisions: int = 0
@export var red_flags_noticed: int = 0

# Технические
@export var is_new_game: bool = true
@export var last_save_timestamp: int = 0


## Добавить опыт
func add_xp(amount: int) -> bool:
	xp += amount
	var leveled_up := false
	
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = _calculate_next_level_xp()
		leveled_up = true
	
	return leveled_up


func _calculate_next_level_xp() -> int:
	# Формула: 100 + (уровень * 50)
	return 100 + (level * 50)


## Добавить XP к навыку
func add_skill_xp(skill_name: String, amount: int) -> void:
	if skill_name in skills:
		skills[skill_name] = mini(100, skills[skill_name] + amount)
		print("[PlayerData] Skill '%s' +%d -> %d" % [skill_name, amount, skills[skill_name]])


## Получить уровень навыка
func get_skill_level(skill_name: String) -> int:
	return skills.get(skill_name, 0)


## Установить флаг
func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value


## Проверить флаг
func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)


## Получить значение флага
func get_flag(flag_name: String, default = null):
	return flags.get(flag_name, default)


## Завершить квест
func complete_quest(quest_id: String) -> void:
	if quest_id not in completed_quests:
		completed_quests.append(quest_id)
	
	if current_quest_id == quest_id:
		current_quest_id = ""


## Проверить, выполнен ли квест
func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests


## Сериализация в Dictionary для JSON
func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"avatar_id": avatar_id,
		"level": level,
		"xp": xp,
		"xp_to_next_level": xp_to_next_level,
		"skills": skills.duplicate(),
		"flags": flags.duplicate(),
		"completed_quests": completed_quests.duplicate(),
		"current_quest_id": current_quest_id,
		"quest_progress": quest_progress.duplicate(),
		"current_location": current_location,
		"last_position": {"x": last_position.x, "y": last_position.y},
		"play_time_seconds": play_time_seconds,
		"dialogues_completed": dialogues_completed,
		"correct_decisions": correct_decisions,
		"red_flags_noticed": red_flags_noticed,
		"is_new_game": is_new_game,
		"last_save_timestamp": Time.get_unix_time_from_system()
	}


## Десериализация из Dictionary
static func from_dict(data: Dictionary) -> PlayerData:
	var player_data := PlayerData.new()
	
	player_data.player_name = data.get("player_name", "Игрок")
	player_data.avatar_id = data.get("avatar_id", 0)
	player_data.level = data.get("level", 1)
	player_data.xp = data.get("xp", 0)
	player_data.xp_to_next_level = data.get("xp_to_next_level", 100)
	player_data.skills = data.get("skills", {
		"observe": 0, "question": 0, "explain": 0,
		"compare": 0, "decide": 0, "consequence": 0
	})
	player_data.flags = data.get("flags", {})
	player_data.completed_quests.assign(data.get("completed_quests", []))
	player_data.current_quest_id = data.get("current_quest_id", "")
	player_data.quest_progress = data.get("quest_progress", {})
	player_data.current_location = data.get("current_location", "")
	
	var pos = data.get("last_position", {"x": 0, "y": 0})
	player_data.last_position = Vector2(pos.get("x", 0), pos.get("y", 0))
	
	player_data.play_time_seconds = data.get("play_time_seconds", 0)
	player_data.dialogues_completed = data.get("dialogues_completed", 0)
	player_data.correct_decisions = data.get("correct_decisions", 0)
	player_data.red_flags_noticed = data.get("red_flags_noticed", 0)
	player_data.is_new_game = data.get("is_new_game", true)
	player_data.last_save_timestamp = data.get("last_save_timestamp", 0)
	
	return player_data
```

## 3.3 SaveManager — Сохранение/загрузка

```gdscript
# scripts/autoload/save_manager.gd
extends Node

## Менеджер сохранений
## Отвечает за сохранение и загрузку данных игрока

const SAVE_PATH := "user://antiobman_save.json"
const SETTINGS_PATH := "user://settings.json"
const BACKUP_PATH := "user://antiobman_save_backup.json"


## Сохранить игру
func save_game(player_data: PlayerData) -> bool:
	if not player_data:
		push_error("[SaveManager] Cannot save: player_data is null")
		return false
	
	# Обновляем timestamp
	var data := player_data.to_dict()
	
	# Создаём бэкап предыдущего сохранения
	_create_backup()
	
	# Сохраняем
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string := JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("[SaveManager] Game saved successfully")
		return true
	else:
		push_error("[SaveManager] Failed to open save file for writing")
		return false


## Загрузить игру
func load_game() -> PlayerData:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file found")
		return null
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[SaveManager] Failed to open save file for reading")
		return _try_load_backup()
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	
	if error != OK:
		push_error("[SaveManager] JSON parse error: %s" % json.get_error_message())
		return _try_load_backup()
	
	var data: Dictionary = json.data
	return PlayerData.from_dict(data)


## Проверить, существует ли сохранение
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Удалить сохранение
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveManager] Save file deleted")
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(BACKUP_PATH)


## Сохранить настройки
func save_settings(settings: Dictionary) -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))
		file.close()


## Загрузить настройки
func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return _get_default_settings()
	
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return _get_default_settings()
	
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return _get_default_settings()
	
	file.close()
	return json.data


func _get_default_settings() -> Dictionary:
	return {
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"dialogue_speed": 1.0,
		"show_hints": true,
		"vibration": true,
		"language": "ru"
	}


func _create_backup() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var source := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var dest := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if source and dest:
			dest.store_string(source.get_as_text())
			source.close()
			dest.close()


func _try_load_backup() -> PlayerData:
	if not FileAccess.file_exists(BACKUP_PATH):
		return null
	
	print("[SaveManager] Trying to load backup...")
	var file := FileAccess.open(BACKUP_PATH, FileAccess.READ)
	if not file:
		return null
	
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return null
	
	file.close()
	return PlayerData.from_dict(json.data)
```



## 3.4 DialogueManager — Менеджер диалогов

```gdscript
# scripts/autoload/dialogue_manager.gd
extends Node

## Менеджер диалоговой системы
## Загружает JSON диалоги, управляет потоком диалога, обрабатывает выборы

signal dialogue_started(dialogue_id: String, npc_id: String)
signal dialogue_ended(dialogue_id: String)
signal node_displayed(node_data: Dictionary)
signal choices_displayed(choices: Array)
signal choice_made(choice_index: int, choice_data: Dictionary)
signal reflection_started(reflection_data: Dictionary)
signal effects_applied(effects: Dictionary)

# Текущий диалог
var current_dialogue: Dictionary = {}
var current_dialogue_id: String = ""
var current_node_id: String = ""
var dialogue_active: bool = false

# История выборов в текущем диалоге
var dialogue_history: Array[Dictionary] = []

# Кэш загруженных диалогов
var dialogue_cache: Dictionary = {}


func _ready() -> void:
	print("[DialogueManager] Initialized")


## Начать диалог по ID файла
func start_dialogue(dialogue_id: String, npc_id: String = "") -> void:
	var dialogue_data := _load_dialogue(dialogue_id)
	
	if dialogue_data.is_empty():
		push_error("[DialogueManager] Dialogue not found: " + dialogue_id)
		return
	
	current_dialogue = dialogue_data
	current_dialogue_id = dialogue_id
	dialogue_active = true
	dialogue_history.clear()
	
	# Меняем состояние игры
	GameManager.change_state(GameManager.GameState.DIALOGUE)
	
	# Отправляем сигнал
	dialogue_started.emit(dialogue_id, npc_id if not npc_id.is_empty() else dialogue_data.get("npc_id", ""))
	
	# Показываем первую ноду
	show_node("start")


## Загрузить диалог из JSON
func _load_dialogue(dialogue_id: String) -> Dictionary:
	# Проверяем кэш
	if dialogue_id in dialogue_cache:
		return dialogue_cache[dialogue_id]
	
	var file_path := "res://data/dialogues/%s.json" % dialogue_id
	
	if not FileAccess.file_exists(file_path):
		push_error("[DialogueManager] File not found: " + file_path)
		return {}
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[DialogueManager] Cannot open file: " + file_path)
		return {}
	
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()
	
	if error != OK:
		push_error("[DialogueManager] JSON parse error in %s: %s" % [file_path, json.get_error_message()])
		return {}
	
	# Кэшируем
	dialogue_cache[dialogue_id] = json.data
	return json.data


## Показать ноду диалога
func show_node(node_id: String) -> void:
	if current_dialogue.is_empty():
		push_error("[DialogueManager] No active dialogue")
		return
	
	var nodes: Dictionary = current_dialogue.get("nodes", {})
	
	if node_id not in nodes:
		push_error("[DialogueManager] Node not found: " + node_id)
		end_dialogue()
		return
	
	current_node_id = node_id
	var node: Dictionary = nodes[node_id]
	
	# Обрабатываем тип ноды
	var node_type: String = node.get("type", "dialogue")
	
	match node_type:
		"dialogue":
			_process_dialogue_node(node)
		"reflection":
			_process_reflection_node(node)
		"mentor_ai":
			_process_mentor_node(node)
		"end":
			_process_end_node(node)
		_:
			_process_dialogue_node(node)


func _process_dialogue_node(node: Dictionary) -> void:
	# Применяем эффекты, если есть
	if node.has("effects"):
		_apply_effects(node.effects)
	
	# Отправляем ноду для отображения
	node_displayed.emit(node)
	
	# Если есть выборы — показываем их
	if node.has("choices") and node.choices.size() > 0:
		var available_choices := _filter_choices(node.choices)
		choices_displayed.emit(available_choices)
	# Иначе ждём клика для продолжения


func _process_reflection_node(node: Dictionary) -> void:
	reflection_started.emit(node)


func _process_mentor_node(node: Dictionary) -> void:
	var context: String = node.get("context", "")
	var situation: String = node.get("situation", "")
	var after_node: String = node.get("after", "start")
	
	# Вызываем AI Manager
	AIManager.ask_mentor(context, situation, func(response: String):
		# Показываем ответ ментора
		var mentor_node := {
			"speaker": "mentor",
			"speaker_name": "🦉 Совёнок",
			"portrait": "owl_thinking",
			"text": response,
			"type": "dialogue"
		}
		node_displayed.emit(mentor_node)
		
		# Сохраняем следующую ноду для возврата
		current_dialogue["_pending_after"] = after_node
	)


func _process_end_node(node: Dictionary) -> void:
	# Проверяем, есть ли следующий квест
	if node.has("next_quest"):
		QuestManager.start_quest(node.next_quest)
	
	end_dialogue()


## Фильтрация выборов по требованиям навыков
func _filter_choices(choices: Array) -> Array:
	var available: Array = []
	var player_data: PlayerData = GameManager.player_data
	
	for choice in choices:
		# Проверяем требования навыка
		if choice.has("required_skill"):
			var skill_req: Dictionary = choice.required_skill
			var skill_name: String = skill_req.keys()[0]
			var required_level: int = skill_req[skill_name]
			
			if player_data.get_skill_level(skill_name) < required_level:
				# Навык недостаточен — пропускаем или показываем заблокированным
				var locked_choice := choice.duplicate()
				locked_choice["is_locked"] = true
				locked_choice["lock_reason"] = "Требуется навык: %s %d%%" % [
					_get_skill_display_name(skill_name), 
					required_level
				]
				available.append(locked_choice)
				continue
		
		# Проверяем требования флагов
		if choice.has("required_flag"):
			var flag_name: String = choice.required_flag
			if not player_data.has_flag(flag_name):
				continue  # Пропускаем, если флаг не установлен
		
		available.append(choice)
	
	return available


func _get_skill_display_name(skill_id: String) -> String:
	var names := {
		"observe": "👁️ Наблюдательность",
		"question": "❓ Любознательность",
		"explain": "💬 Красноречие",
		"compare": "⚖️ Анализ",
		"decide": "🎯 Решительность",
		"consequence": "🔗 Предусмотрительность"
	}
	return names.get(skill_id, skill_id)


## Выбрать вариант ответа
func select_choice(choice_index: int) -> void:
	var nodes: Dictionary = current_dialogue.get("nodes", {})
	var node: Dictionary = nodes.get(current_node_id, {})
	var choices: Array = _filter_choices(node.get("choices", []))
	
	if choice_index < 0 or choice_index >= choices.size():
		push_error("[DialogueManager] Invalid choice index: %d" % choice_index)
		return
	
	var choice: Dictionary = choices[choice_index]
	
	# Проверяем, не заблокирован ли выбор
	if choice.get("is_locked", false):
		print("[DialogueManager] Choice is locked")
		return
	
	# Сохраняем в историю
	dialogue_history.append({
		"node_id": current_node_id,
		"choice_index": choice_index,
		"choice_id": choice.get("id", "")
	})
	
	# Применяем эффекты выбора
	if choice.has("effects"):
		_apply_effects(choice.effects)
	
	# Отправляем сигнал
	choice_made.emit(choice_index, choice)
	
	# Выполняем действие, если есть
	if choice.has("action"):
		_execute_action(choice.action, choice)
	
	# Переходим к следующей ноде
	if choice.has("next"):
		show_node(choice.next)
	else:
		end_dialogue()


## Продолжить диалог (после текста без выборов)
func continue_dialogue() -> void:
	# Проверяем pending after (для ментора)
	if current_dialogue.has("_pending_after"):
		var after_node: String = current_dialogue["_pending_after"]
		current_dialogue.erase("_pending_after")
		show_node(after_node)
		return
	
	var nodes: Dictionary = current_dialogue.get("nodes", {})
	var node: Dictionary = nodes.get(current_node_id, {})
	
	if node.has("next"):
		show_node(node.next)
	else:
		end_dialogue()


## Применить эффекты
func _apply_effects(effects: Dictionary) -> void:
	var player_data: PlayerData = GameManager.player_data
	
	# XP общий
	if effects.has("xp"):
		var leveled_up := player_data.add_xp(effects.xp)
		if leveled_up:
			print("[DialogueManager] Level up!")
	
	# XP навыков
	if effects.has("skills"):
		for skill_name in effects.skills:
			player_data.add_skill_xp(skill_name, effects.skills[skill_name])
	
	# Флаги
	if effects.has("flags"):
		for flag_name in effects.flags:
			player_data.set_flag(flag_name, effects.flags[flag_name])
	
	# Квесты
	if effects.has("quest_complete"):
		player_data.complete_quest(effects.quest_complete)
	
	if effects.has("quest_progress"):
		var quest_id: String = effects.quest_progress.get("quest_id", "")
		var step: String = effects.quest_progress.get("step", "")
		if not quest_id.is_empty():
			player_data.quest_progress[quest_id] = {"step": step}
	
	# Отправляем сигнал
	effects_applied.emit(effects)
	
	# Сохраняем
	GameManager.save_game()


## Выполнить действие
func _execute_action(action: String, choice: Dictionary) -> void:
	match action:
		"call_mentor":
			# Обрабатывается в _process_mentor_node
			pass
		"play_sound":
			if choice.has("sound"):
				AudioManager.play_sfx(choice.sound)
		"trigger_event":
			if choice.has("event"):
				# Можно добавить систему событий
				pass
		_:
			print("[DialogueManager] Unknown action: " + action)


## Завершить диалог
func end_dialogue() -> void:
	dialogue_active = false
	
	# Обновляем статистику
	GameManager.player_data.dialogues_completed += 1
	
	var dialogue_id := current_dialogue_id
	
	# Очищаем
	current_dialogue = {}
	current_dialogue_id = ""
	current_node_id = ""
	
	# Возвращаем состояние игры
	GameManager.change_state(GameManager.GameState.PLAYING)
	
	# Отправляем сигнал
	dialogue_ended.emit(dialogue_id)


## Проверить, активен ли диалог
func is_dialogue_active() -> bool:
	return dialogue_active


## Очистить кэш диалогов
func clear_cache() -> void:
	dialogue_cache.clear()
```

## 3.5 SkillManager — Менеджер навыков

```gdscript
# scripts/autoload/skill_manager.gd
extends Node

## Менеджер системы навыков критического мышления

signal skill_changed(skill_id: String, old_value: int, new_value: int)
signal skill_milestone_reached(skill_id: String, milestone: int)

# Описание навыков
const SKILLS_DATA := {
	"observe": {
		"id": "observe",
		"name": "Наблюдательность",
		"icon": "👁️",
		"description": "Замечать детали, находить несоответствия",
		"color": Color(0.2, 0.6, 1.0),  # Синий
		"milestones": [25, 50, 75, 100]
	},
	"question": {
		"id": "question",
		"name": "Любознательность",
		"icon": "❓",
		"description": "Задавать вопросы, уточнять информацию",
		"color": Color(1.0, 0.8, 0.2),  # Жёлтый
		"milestones": [25, 50, 75, 100]
	},
	"explain": {
		"id": "explain",
		"name": "Красноречие",
		"icon": "💬",
		"description": "Объяснять свои решения",
		"color": Color(0.2, 0.8, 0.4),  # Зелёный
		"milestones": [25, 50, 75, 100]
	},
	"compare": {
		"id": "compare",
		"name": "Анализ",
		"icon": "⚖️",
		"description": "Сравнивать варианты, видеть плюсы и минусы",
		"color": Color(0.8, 0.4, 1.0),  # Фиолетовый
		"milestones": [25, 50, 75, 100]
	},
	"decide": {
		"id": "decide",
		"name": "Решительность",
		"icon": "🎯",
		"description": "Принимать осознанные решения",
		"color": Color(1.0, 0.4, 0.4),  # Красный
		"milestones": [25, 50, 75, 100]
	},
	"consequence": {
		"id": "consequence",
		"name": "Предусмотрительность",
		"icon": "🔗",
		"description": "Понимать последствия действий",
		"color": Color(1.0, 0.6, 0.2),  # Оранжевый
		"milestones": [25, 50, 75, 100]
	}
}


## Получить данные навыка
func get_skill_data(skill_id: String) -> Dictionary:
	return SKILLS_DATA.get(skill_id, {})


## Получить все навыки
func get_all_skills() -> Dictionary:
	return SKILLS_DATA


## Получить текущий уровень навыка игрока
func get_player_skill_level(skill_id: String) -> int:
	if not GameManager.player_data:
		return 0
	return GameManager.player_data.get_skill_level(skill_id)


## Добавить XP к навыку (с проверкой milestone)
func add_skill_xp(skill_id: String, amount: int) -> void:
	if not GameManager.player_data:
		return
	
	var old_value: int = GameManager.player_data.get_skill_level(skill_id)
	GameManager.player_data.add_skill_xp(skill_id, amount)
	var new_value: int = GameManager.player_data.get_skill_level(skill_id)
	
	if old_value != new_value:
		skill_changed.emit(skill_id, old_value, new_value)
		
		# Проверяем milestones
		var skill_data: Dictionary = get_skill_data(skill_id)
		var milestones: Array = skill_data.get("milestones", [])
		
		for milestone in milestones:
			if old_value < milestone and new_value >= milestone:
				skill_milestone_reached.emit(skill_id, milestone)
				_show_milestone_notification(skill_id, milestone)


func _show_milestone_notification(skill_id: String, milestone: int) -> void:
	var skill_data: Dictionary = get_skill_data(skill_id)
	var skill_name: String = skill_data.get("name", skill_id)
	var icon: String = skill_data.get("icon", "")
	
	print("[SkillManager] Milestone! %s %s reached %d%%" % [icon, skill_name, milestone])
	# TODO: Показать UI уведомление


## Проверить, достаточен ли навык для действия
func check_skill_requirement(skill_id: String, required_level: int) -> bool:
	return get_player_skill_level(skill_id) >= required_level


## Получить бонусы от навыка (для диалогов)
func get_skill_bonuses(skill_id: String) -> Dictionary:
	var level: int = get_player_skill_level(skill_id)
	
	# Бонусы в зависимости от уровня
	var bonuses := {}
	
	match skill_id:
		"observe":
			# На 25% — видит подсказку "что-то не так"
			# На 50% — видит красные флаги
			# На 75% — автоматически замечает все флаги
			bonuses["hint_level"] = _get_hint_level(level)
			bonuses["see_red_flags"] = level >= 50
			bonuses["auto_detect"] = level >= 75
		
		"question":
			# Разблокирует дополнительные вопросы в диалогах
			bonuses["extra_questions"] = level / 25  # 0, 1, 2, 3 доп. вопроса
		
		"decide":
			# Показывает вероятности исходов
			bonuses["show_probabilities"] = level >= 50
	
	return bonuses


func _get_hint_level(skill_level: int) -> int:
	if skill_level >= 75:
		return 3  # Явные подсказки
	elif skill_level >= 50:
		return 2  # Средние подсказки
	elif skill_level >= 25:
		return 1  # Слабые подсказки
	return 0  # Без подсказок
```