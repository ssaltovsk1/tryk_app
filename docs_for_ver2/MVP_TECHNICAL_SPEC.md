# ТЗ: MVP "АнтиОбман" на Godot 4
## Техническое задание для разработки с Claude Code

**Версия:** 1.0
**Дата:** 2025-12-03
**Движок:** Godot 4.2+
**Язык:** GDScript

---

# ЧАСТЬ 1: ОБЗОР MVP

## 1.1 Что делаем

Образовательная 2D RPG для детей 6-10 лет с видом сверху (top-down).
Игрок ходит по локации, общается с NPC, принимает решения, учится критическому мышлению.

## 1.2 Ключевые механики MVP

```
✅ ВКЛЮЧЕНО:
├── Передвижение персонажа (top-down)
├── Диалоговая система с выборами
├── 6 навыков критического мышления
├── Система красных флагов
├── ИИ-ментор (Совёнок) — интеграция с Claude API
├── 1 локация (Школа)
├── 3 квеста
├── Сохранение прогресса
└── Базовый UI

❌ НЕ ВКЛЮЧЕНО:
├── Мультиплеер
├── Видео
├── Дополнительные локации
├── Модульная загрузка контента
└── Родительский кабинет
```

## 1.3 Технические требования

```
Движок:         Godot 4.2+
Язык:           GDScript
Платформы:      Android, iOS, Windows (для тестов)
Ориентация:     Портретная (вертикальная)
Разрешение:     1080x1920 (базовое), адаптивное
Размер APK:     < 50 MB
FPS:            60
```

---

# ЧАСТЬ 2: СТРУКТУРА ПРОЕКТА

## 2.1 Файловая структура Godot

```
antiobman/
├── project.godot
├── .gitignore
│
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   │   ├── player.png
│   │   │   ├── mentor_owl.png
│   │   │   └── npcs/
│   │   │       ├── stranger.png
│   │   │       ├── teacher.png
│   │   │       └── friend.png
│   │   ├── tiles/
│   │   │   └── school_tileset.png
│   │   └── ui/
│   │       ├── dialogue_box.png
│   │       ├── buttons/
│   │       └── icons/
│   │           ├── skill_observe.png
│   │           ├── skill_question.png
│   │           ├── skill_explain.png
│   │           ├── skill_compare.png
│   │           ├── skill_decide.png
│   │           └── skill_consequence.png
│   ├── fonts/
│   │   └── main_font.ttf
│   └── audio/
│       ├── music/
│       └── sfx/
│
├── scenes/
│   ├── main.tscn                    # Главная сцена
│   ├── game_world.tscn              # Игровой мир
│   │
│   ├── player/
│   │   └── player.tscn              # Игрок
│   │
│   ├── npcs/
│   │   ├── npc_base.tscn            # Базовый NPC
│   │   ├── mentor.tscn              # Совёнок
│   │   └── stranger.tscn            # Мошенник
│   │
│   ├── ui/
│   │   ├── hud.tscn                 # Интерфейс игры
│   │   ├── dialogue_box.tscn        # Окно диалога
│   │   ├── choice_button.tscn       # Кнопка выбора
│   │   ├── skill_panel.tscn         # Панель навыков
│   │   ├── mentor_panel.tscn        # Панель ментора
│   │   └── reflection_popup.tscn    # Окно рефлексии
│   │
│   └── locations/
│       └── school/
│           ├── school.tscn          # Локация школы
│           └── zones/
│               ├── hallway.tscn     # Коридор
│               ├── classroom.tscn   # Класс
│               └── yard.tscn        # Двор
│
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd          # Глобальный менеджер
│   │   ├── dialogue_manager.gd      # Менеджер диалогов
│   │   ├── skill_manager.gd         # Менеджер навыков
│   │   ├── quest_manager.gd         # Менеджер квестов
│   │   ├── save_manager.gd          # Сохранение
│   │   └── ai_manager.gd            # Интеграция с Claude
│   │
│   ├── player/
│   │   ├── player_controller.gd     # Управление игроком
│   │   └── player_data.gd           # Данные игрока
│   │
│   ├── npc/
│   │   ├── npc_base.gd              # Базовый NPC
│   │   └── npc_interactable.gd      # Взаимодействие
│   │
│   ├── dialogue/
│   │   ├── dialogue_parser.gd       # Парсер JSON диалогов
│   │   └── dialogue_ui.gd           # UI диалогов
│   │
│   ├── skills/
│   │   └── skill_system.gd          # Система навыков
│   │
│   └── quests/
│       └── quest_system.gd          # Система квестов
│
├── data/
│   ├── dialogues/
│   │   ├── quest_01_locker.json     # Диалоги квеста 1
│   │   ├── quest_02_helper.json     # Диалоги квеста 2
│   │   └── quest_03_deal.json       # Диалоги квеста 3
│   │
│   ├── quests/
│   │   └── quests.json              # Описание квестов
│   │
│   └── skills/
│       └── skills.json              # Описание навыков
│
└── export/
    ├── android/
    └── ios/
```


---

# ЧАСТЬ 3: АВТОЗАГРУЖАЕМЫЕ СКРИПТЫ (AUTOLOAD)

## 3.1 Настройка в project.godot

```ini
[autoload]
GameManager="*res://scripts/autoload/game_manager.gd"
DialogueManager="*res://scripts/autoload/dialogue_manager.gd"
SkillManager="*res://scripts/autoload/skill_manager.gd"
QuestManager="*res://scripts/autoload/quest_manager.gd"
SaveManager="*res://scripts/autoload/save_manager.gd"
AIManager="*res://scripts/autoload/ai_manager.gd"
```

## 3.2 GameManager — Главный менеджер

```gdscript
# scripts/autoload/game_manager.gd
extends Node

signal game_paused
signal game_resumed

enum GameState { PLAYING, DIALOGUE, PAUSED, MENU }

var current_state: GameState = GameState.MENU
var player_data: PlayerData

func _ready():
    player_data = PlayerData.new()
    load_game()

func change_state(new_state: GameState):
    current_state = new_state
    match new_state:
        GameState.PLAYING:
            get_tree().paused = false
            game_resumed.emit()
        GameState.DIALOGUE:
            get_tree().paused = false  # Диалоги не останавливают игру
        GameState.PAUSED:
            get_tree().paused = true
            game_paused.emit()

func load_game():
    player_data = SaveManager.load_player_data()

func save_game():
    SaveManager.save_player_data(player_data)
```

## 3.3 PlayerData — Данные игрока

```gdscript
# scripts/player/player_data.gd
class_name PlayerData
extends Resource

@export var player_name: String = "Игрок"
@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next_level: int = 100

# 6 навыков критического мышления (0-100)
@export var skills: Dictionary = {
    "observe": 0,      # Замечать различия
    "question": 0,     # Задавать вопросы
    "explain": 0,      # Объяснять действия
    "compare": 0,      # Сравнивать
    "decide": 0,       # Принимать решения
    "consequence": 0   # Понимать последствия
}

# Флаги прогресса
@export var flags: Dictionary = {}

# Выполненные квесты
@export var completed_quests: Array[String] = []

# Текущий квест
@export var current_quest: String = ""

func add_xp(amount: int):
    xp += amount
    while xp >= xp_to_next_level:
        xp -= xp_to_next_level
        level += 1
        xp_to_next_level = calculate_next_level_xp()

func calculate_next_level_xp() -> int:
    return 100 + (level * 50)

func add_skill_xp(skill_name: String, amount: int):
    if skill_name in skills:
        skills[skill_name] = min(100, skills[skill_name] + amount)

func get_skill_level(skill_name: String) -> int:
    return skills.get(skill_name, 0)

func set_flag(flag_name: String, value: bool = true):
    flags[flag_name] = value

func has_flag(flag_name: String) -> bool:
    return flags.get(flag_name, false)
```

---

# ЧАСТЬ 4: СИСТЕМА ПЕРЕДВИЖЕНИЯ

## 4.1 Player Controller

```gdscript
# scripts/player/player_controller.gd
extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var can_move: bool = true
var nearby_interactable: Node2D = null

func _ready():
    interaction_area.body_entered.connect(_on_interaction_area_entered)
    interaction_area.body_exited.connect(_on_interaction_area_exited)

func _physics_process(delta):
    if not can_move or GameManager.current_state == GameManager.GameState.DIALOGUE:
        velocity = Vector2.ZERO
        return
    
    # Получаем направление
    var direction = Vector2.ZERO
    direction.x = Input.get_axis("move_left", "move_right")
    direction.y = Input.get_axis("move_up", "move_down")
    
    if direction.length() > 0:
        direction = direction.normalized()
        velocity = direction * speed
        update_animation(direction)
    else:
        velocity = Vector2.ZERO
        sprite.play("idle")
    
    move_and_slide()

func update_animation(direction: Vector2):
    if abs(direction.x) > abs(direction.y):
        if direction.x > 0:
            sprite.play("walk_right")
        else:
            sprite.play("walk_left")
    else:
        if direction.y > 0:
            sprite.play("walk_down")
        else:
            sprite.play("walk_up")

func _input(event):
    if event.is_action_pressed("interact") and nearby_interactable:
        interact_with(nearby_interactable)

func interact_with(target: Node2D):
    if target.has_method("interact"):
        target.interact()

func _on_interaction_area_entered(body):
    if body.is_in_group("interactable"):
        nearby_interactable = body
        # Показать подсказку взаимодействия
        show_interaction_hint(true)

func _on_interaction_area_exited(body):
    if body == nearby_interactable:
        nearby_interactable = null
        show_interaction_hint(false)

func show_interaction_hint(show: bool):
    # TODO: Показать/скрыть иконку взаимодействия
    pass

func set_can_move(value: bool):
    can_move = value
    if not value:
        velocity = Vector2.ZERO
```

## 4.2 Настройка Input Map

```
# В project.godot или через Project Settings -> Input Map

move_up:     W, Up Arrow, Touch (виртуальный джойстик)
move_down:   S, Down Arrow
move_left:   A, Left Arrow
move_right:  D, Right Arrow
interact:    E, Space, Touch (tap)
menu:        Escape, Touch (кнопка меню)
```

---

# ЧАСТЬ 5: СИСТЕМА ДИАЛОГОВ

## 5.1 Формат JSON диалога

```json
{
    "dialogue_id": "quest_01_locker_stranger",
    "npc_id": "stranger_helper",
    "npc_name": "Незнакомец",
    
    "nodes": {
        "start": {
            "speaker": "stranger",
            "portrait": "stranger_smile",
            "text": "Привет! Я помощник директора. Мне нужен твой пароль от шкафчика для проверки.",
            "red_flags": ["asks_password", "unknown_person", "no_proof"],
            "choices": [
                {
                    "id": "choice_give",
                    "text": "Конечно, вот мой пароль!",
                    "next": "scam_success",
                    "effects": {
                        "flags": {"gave_password": true},
                        "skills": {}
                    }
                },
                {
                    "id": "choice_question",
                    "text": "А почему вам нужен мой пароль?",
                    "next": "stranger_pressures",
                    "required_skill": {"question": 0},
                    "effects": {
                        "skills": {"question": 10}
                    }
                },
                {
                    "id": "choice_refuse",
                    "text": "Нет, пароли нельзя говорить никому",
                    "next": "refuse_success",
                    "effects": {
                        "skills": {"decide": 15, "observe": 10}
                    }
                },
                {
                    "id": "choice_mentor",
                    "text": "Спросить у Совёнка",
                    "next": "mentor_help",
                    "action": "call_mentor",
                    "mentor_context": "stranger_asks_password"
                }
            ]
        },
        
        "stranger_pressures": {
            "speaker": "stranger",
            "portrait": "stranger_nervous",
            "text": "Это... это правила! Давай быстрее, у меня мало времени!",
            "red_flags": ["pressure", "no_explanation"],
            "choices": [
                {
                    "id": "choice_give_after",
                    "text": "Ну ладно, вот пароль...",
                    "next": "scam_success"
                },
                {
                    "id": "choice_refuse_after",
                    "text": "Нет, я сначала спрошу учителя",
                    "next": "refuse_success",
                    "effects": {
                        "skills": {"decide": 20, "consequence": 15}
                    }
                }
            ]
        },
        
        "scam_success": {
            "speaker": "narrator",
            "text": "Незнакомец убежал с твоим паролем! Когда ты открыл шкафчик, там было пусто...",
            "effects": {
                "flags": {"locker_robbed": true},
                "items": {"coins": -50}
            },
            "next": "lesson_failed"
        },
        
        "refuse_success": {
            "speaker": "narrator",
            "text": "Незнакомец растерялся и быстро ушёл. Кажется, это был мошенник!",
            "effects": {
                "xp": 30,
                "flags": {"spotted_scammer": true}
            },
            "next": "lesson_success"
        },
        
        "lesson_failed": {
            "speaker": "mentor",
            "portrait": "owl_concerned",
            "text": "Ой-ой! 😟 Это был мошенник. Давай разберём, что пошло не так...",
            "next": "reflection_failed"
        },
        
        "lesson_success": {
            "speaker": "mentor",
            "portrait": "owl_happy",
            "text": "Молодец! 🌟 Ты правильно поступил! Давай разберём, почему это был мошенник.",
            "next": "reflection_success"
        },
        
        "reflection_failed": {
            "type": "reflection",
            "question": "Какие были красные флаги?",
            "correct_flags": ["asks_password", "unknown_person", "pressure"],
            "explanation": "Незнакомец просил пароль, торопил тебя и не показал документы. Это три красных флага!",
            "next": "end"
        },
        
        "reflection_success": {
            "type": "reflection",
            "question": "Почему ты решил отказать?",
            "options": [
                {"text": "Не знаю, просто так", "xp": 0},
                {"text": "Он был незнакомцем", "xp": 10},
                {"text": "Он просил пароль, а это секрет", "xp": 15},
                {"text": "Незнакомец + пароль + торопил = опасно!", "xp": 25}
            ],
            "next": "end"
        },
        
        "mentor_help": {
            "type": "mentor_ai",
            "context": "stranger_asks_password",
            "situation": "Незнакомец представился помощником директора и просит пароль от шкафчика",
            "after": "start"
        },
        
        "end": {
            "type": "end",
            "next_quest": "quest_02"
        }
    }
}
```


## 5.2 DialogueManager

```gdscript
# scripts/autoload/dialogue_manager.gd
extends Node

signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String)
signal node_displayed(node_data: Dictionary)
signal choices_displayed(choices: Array)
signal reflection_started(reflection_data: Dictionary)

var current_dialogue: Dictionary = {}
var current_node_id: String = ""
var dialogue_active: bool = false

func start_dialogue(dialogue_id: String):
    var dialogue_data = load_dialogue(dialogue_id)
    if dialogue_data.is_empty():
        push_error("Dialogue not found: " + dialogue_id)
        return
    
    current_dialogue = dialogue_data
    dialogue_active = true
    GameManager.change_state(GameManager.GameState.DIALOGUE)
    dialogue_started.emit(dialogue_id)
    
    show_node("start")

func load_dialogue(dialogue_id: String) -> Dictionary:
    var file_path = "res://data/dialogues/" + dialogue_id + ".json"
    if not FileAccess.file_exists(file_path):
        return {}
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    file.close()
    
    if error != OK:
        push_error("JSON parse error: " + json.get_error_message())
        return {}
    
    return json.data

func show_node(node_id: String):
    if node_id not in current_dialogue.nodes:
        end_dialogue()
        return
    
    current_node_id = node_id
    var node = current_dialogue.nodes[node_id]
    
    # Проверяем тип ноды
    match node.get("type", "dialogue"):
        "dialogue":
            display_dialogue_node(node)
        "reflection":
            start_reflection(node)
        "mentor_ai":
            call_mentor_ai(node)
        "end":
            end_dialogue()
            if node.has("next_quest"):
                QuestManager.start_quest(node.next_quest)

func display_dialogue_node(node: Dictionary):
    # Применяем эффекты
    if node.has("effects"):
        apply_effects(node.effects)
    
    # Отправляем сигнал для отображения
    node_displayed.emit(node)
    
    # Если есть выборы — показываем их
    if node.has("choices") and node.choices.size() > 0:
        var available_choices = filter_choices(node.choices)
        choices_displayed.emit(available_choices)
    # Если нет выборов, но есть next — переходим
    elif node.has("next"):
        # Ждём клика для продолжения
        pass

func filter_choices(choices: Array) -> Array:
    var available = []
    for choice in choices:
        # Проверяем требования навыка
        if choice.has("required_skill"):
            var skill_name = choice.required_skill.keys()[0]
            var required_level = choice.required_skill[skill_name]
            if GameManager.player_data.get_skill_level(skill_name) < required_level:
                continue
        available.append(choice)
    return available

func select_choice(choice_index: int):
    var node = current_dialogue.nodes[current_node_id]
    var choices = filter_choices(node.choices)
    
    if choice_index >= choices.size():
        return
    
    var choice = choices[choice_index]
    
    # Применяем эффекты выбора
    if choice.has("effects"):
        apply_effects(choice.effects)
    
    # Выполняем действие
    if choice.has("action"):
        execute_action(choice.action, choice)
    
    # Переходим к следующей ноде
    if choice.has("next"):
        show_node(choice.next)

func apply_effects(effects: Dictionary):
    var player = GameManager.player_data
    
    # XP
    if effects.has("xp"):
        player.add_xp(effects.xp)
    
    # Навыки
    if effects.has("skills"):
        for skill_name in effects.skills:
            player.add_skill_xp(skill_name, effects.skills[skill_name])
    
    # Флаги
    if effects.has("flags"):
        for flag_name in effects.flags:
            player.set_flag(flag_name, effects.flags[flag_name])
    
    # Предметы
    if effects.has("items"):
        for item_name in effects.items:
            # TODO: Система предметов
            pass
    
    # Сохраняем
    GameManager.save_game()

func execute_action(action: String, choice: Dictionary):
    match action:
        "call_mentor":
            call_mentor_ai(choice)

func call_mentor_ai(data: Dictionary):
    var context = data.get("mentor_context", data.get("context", ""))
    var situation = data.get("situation", "")
    
    # Вызываем AI Manager
    AIManager.ask_mentor(context, situation, func(response):
        # Показываем ответ ментора
        var mentor_node = {
            "speaker": "mentor",
            "portrait": "owl_thinking",
            "text": response
        }
        node_displayed.emit(mentor_node)
        
        # После ответа возвращаемся к диалогу
        if data.has("after"):
            show_node(data.after)
    )

func start_reflection(node: Dictionary):
    reflection_started.emit(node)

func continue_dialogue():
    var node = current_dialogue.nodes[current_node_id]
    if node.has("next"):
        show_node(node.next)
    else:
        end_dialogue()

func end_dialogue():
    dialogue_active = false
    current_dialogue = {}
    current_node_id = ""
    GameManager.change_state(GameManager.GameState.PLAYING)
    dialogue_ended.emit("")
```

## 5.3 DialogueUI

```gdscript
# scripts/dialogue/dialogue_ui.gd
extends CanvasLayer

@onready var dialogue_panel: Panel = $DialoguePanel
@onready var portrait: TextureRect = $DialoguePanel/Portrait
@onready var speaker_label: Label = $DialoguePanel/SpeakerLabel
@onready var text_label: RichTextLabel = $DialoguePanel/TextLabel
@onready var choices_container: VBoxContainer = $DialoguePanel/ChoicesContainer
@onready var continue_button: Button = $DialoguePanel/ContinueButton
@onready var red_flags_container: HBoxContainer = $DialoguePanel/RedFlagsContainer

const CHOICE_BUTTON_SCENE = preload("res://scenes/ui/choice_button.tscn")

var typing_speed: float = 0.03
var is_typing: bool = false
var full_text: String = ""

func _ready():
    hide_dialogue()
    
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    DialogueManager.node_displayed.connect(_on_node_displayed)
    DialogueManager.choices_displayed.connect(_on_choices_displayed)
    
    continue_button.pressed.connect(_on_continue_pressed)

func _on_dialogue_started(_dialogue_id: String):
    dialogue_panel.visible = true

func _on_dialogue_ended(_dialogue_id: String):
    hide_dialogue()

func _on_node_displayed(node: Dictionary):
    # Очищаем выборы
    clear_choices()
    continue_button.visible = false
    
    # Устанавливаем спикера
    speaker_label.text = get_speaker_name(node.get("speaker", ""))
    
    # Устанавливаем портрет
    set_portrait(node.get("portrait", ""))
    
    # Показываем красные флаги (если навык достаточный)
    show_red_flags(node.get("red_flags", []))
    
    # Запускаем печатание текста
    start_typing(node.get("text", ""))

func start_typing(text: String):
    full_text = text
    text_label.text = ""
    is_typing = true
    
    for i in range(text.length()):
        if not is_typing:
            text_label.text = full_text
            break
        text_label.text += text[i]
        await get_tree().create_timer(typing_speed).timeout
    
    is_typing = false
    on_typing_finished()

func skip_typing():
    is_typing = false
    text_label.text = full_text

func on_typing_finished():
    # Если нет выборов — показываем кнопку продолжения
    if choices_container.get_child_count() == 0:
        continue_button.visible = true

func _on_choices_displayed(choices: Array):
    clear_choices()
    continue_button.visible = false
    
    for i in range(choices.size()):
        var choice = choices[i]
        var button = CHOICE_BUTTON_SCENE.instantiate()
        button.setup(choice, i)
        button.choice_selected.connect(_on_choice_selected)
        choices_container.add_child(button)

func _on_choice_selected(index: int):
    DialogueManager.select_choice(index)

func _on_continue_pressed():
    if is_typing:
        skip_typing()
    else:
        DialogueManager.continue_dialogue()

func _input(event):
    if event.is_action_pressed("interact") and dialogue_panel.visible:
        if is_typing:
            skip_typing()
        elif continue_button.visible:
            DialogueManager.continue_dialogue()

func clear_choices():
    for child in choices_container.get_children():
        child.queue_free()

func hide_dialogue():
    dialogue_panel.visible = false

func get_speaker_name(speaker_id: String) -> String:
    match speaker_id:
        "mentor": return "🦉 Совёнок"
        "stranger": return "Незнакомец"
        "narrator": return ""
        _: return speaker_id

func set_portrait(portrait_id: String):
    if portrait_id.is_empty():
        portrait.visible = false
        return
    
    var path = "res://assets/sprites/portraits/" + portrait_id + ".png"
    if ResourceLoader.exists(path):
        portrait.texture = load(path)
        portrait.visible = true
    else:
        portrait.visible = false

func show_red_flags(flags: Array):
    # Очищаем
    for child in red_flags_container.get_children():
        child.queue_free()
    
    if flags.is_empty():
        red_flags_container.visible = false
        return
    
    # Проверяем навык наблюдательности
    var observe_skill = GameManager.player_data.get_skill_level("observe")
    
    for flag in flags:
        # Показываем флаг в зависимости от уровня навыка
        if observe_skill >= 50:
            add_red_flag_icon(flag, true)  # Явный флаг
        elif observe_skill >= 25:
            add_red_flag_icon(flag, false)  # "Что-то не так..."
    
    red_flags_container.visible = red_flags_container.get_child_count() > 0

func add_red_flag_icon(flag: String, explicit: bool):
    var label = Label.new()
    if explicit:
        label.text = "🚩 " + get_flag_description(flag)
    else:
        label.text = "🤔 Что-то не так..."
    label.add_theme_color_override("font_color", Color.RED)
    red_flags_container.add_child(label)

func get_flag_description(flag: String) -> String:
    match flag:
        "asks_password": return "Просит пароль"
        "unknown_person": return "Незнакомец"
        "pressure": return "Торопит"
        "no_proof": return "Нет доказательств"
        "too_good": return "Слишком хорошо"
        _: return flag
```
