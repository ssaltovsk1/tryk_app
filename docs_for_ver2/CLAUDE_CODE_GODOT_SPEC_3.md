
# ЧАСТЬ 8: JSON ДАННЫЕ

## 8.1 Диалог первого квеста (quest_01_locker.json)

```json
{
    "dialogue_id": "quest_01_locker",
    "npc_id": "stranger_helper",
    "npc_name": "Незнакомец",
    "description": "Мошенник притворяется помощником директора и просит пароль от шкафчика",
    
    "nodes": {
        "start": {
            "speaker": "stranger",
            "speaker_name": "Незнакомец",
            "portrait": "stranger_smile",
            "text": "Привет! Я помощник директора. У нас проверка — мне нужен твой пароль от шкафчика.",
            "red_flags": ["asks_password", "unknown_person"],
            "choices": [
                {
                    "id": "give_password",
                    "text": "Конечно! Мой пароль — 1234",
                    "next": "scam_success",
                    "effects": {
                        "flags": {"gave_password": true}
                    }
                },
                {
                    "id": "ask_why",
                    "text": "А зачем вам мой пароль?",
                    "next": "stranger_explains",
                    "required_skill": {"question": 0},
                    "effects": {
                        "skills": {"question": 10}
                    }
                },
                {
                    "id": "refuse",
                    "text": "Нет, пароли никому говорить нельзя",
                    "next": "refuse_success",
                    "effects": {
                        "skills": {"decide": 15, "observe": 10}
                    }
                },
                {
                    "id": "ask_mentor",
                    "text": "🦉 Спросить у Совёнка",
                    "action": "call_mentor",
                    "mentor_context": "stranger_asks_password",
                    "next": "after_mentor"
                }
            ]
        },
        
        "stranger_explains": {
            "speaker": "stranger",
            "speaker_name": "Незнакомец",
            "portrait": "stranger_nervous",
            "text": "Это... это для безопасности! Давай быстрее, у меня мало времени!",
            "red_flags": ["pressure", "no_proof"],
            "choices": [
                {
                    "id": "give_after_pressure",
                    "text": "Ну ладно... вот пароль",
                    "next": "scam_success",
                    "effects": {
                        "flags": {"gave_password": true}
                    }
                },
                {
                    "id": "ask_document",
                    "text": "Покажите документ, что вы помощник директора",
                    "next": "stranger_caught",
                    "required_skill": {"observe": 0},
                    "effects": {
                        "skills": {"observe": 15, "question": 10}
                    }
                },
                {
                    "id": "refuse_after_pressure",
                    "text": "Нет. Я сначала спрошу учителя",
                    "next": "refuse_success",
                    "effects": {
                        "skills": {"decide": 20, "consequence": 10}
                    }
                },
                {
                    "id": "ask_mentor_2",
                    "text": "🦉 Спросить у Совёнка",
                    "action": "call_mentor",
                    "mentor_context": "pressure_tactics",
                    "next": "after_mentor_2"
                }
            ]
        },
        
        "after_mentor": {
            "speaker": "player",
            "speaker_name": "Я",
            "text": "(Совёнок дал мне подсказку... Что же делать?)",
            "choices": [
                {
                    "id": "trust_after_mentor",
                    "text": "Ладно, вот мой пароль...",
                    "next": "scam_success"
                },
                {
                    "id": "question_after_mentor",
                    "text": "А почему именно мой пароль вам нужен?",
                    "next": "stranger_explains",
                    "effects": {
                        "skills": {"question": 5}
                    }
                },
                {
                    "id": "refuse_after_mentor",
                    "text": "Нет, я не буду говорить пароль незнакомцу",
                    "next": "refuse_success",
                    "effects": {
                        "skills": {"decide": 15}
                    }
                }
            ]
        },
        
        "after_mentor_2": {
            "speaker": "player",
            "speaker_name": "Я",
            "text": "(Он меня торопит... Это подозрительно!)",
            "choices": [
                {
                    "id": "give_anyway",
                    "text": "Может, он правда торопится? Вот пароль...",
                    "next": "scam_success"
                },
                {
                    "id": "stand_firm",
                    "text": "Нет. Если торопит — значит, что-то не так!",
                    "next": "refuse_success",
                    "effects": {
                        "skills": {"decide": 20, "consequence": 15}
                    }
                }
            ]
        },
        
        "stranger_caught": {
            "speaker": "stranger",
            "speaker_name": "Незнакомец",
            "portrait": "stranger_caught",
            "text": "Документ? Я... э... он у директора! Мне надо идти!",
            "next": "refuse_success_document",
            "effects": {
                "flags": {"caught_scammer": true},
                "skills": {"observe": 10}
            }
        },
        
        "refuse_success_document": {
            "speaker": "narrator",
            "text": "Незнакомец быстро убежал. Похоже, это был мошенник, и ты его раскусил!",
            "next": "lesson_success",
            "effects": {
                "xp": 40,
                "flags": {"spotted_scammer": true}
            }
        },
        
        "scam_success": {
            "speaker": "narrator",
            "text": "Незнакомец улыбнулся и быстро ушёл. Через час ты открыл шкафчик — там было пусто! Кто-то украл твои вещи...",
            "next": "lesson_failed",
            "effects": {
                "flags": {"locker_robbed": true}
            }
        },
        
        "refuse_success": {
            "speaker": "narrator",
            "text": "Незнакомец замялся и быстро ушёл. Позже учительница сказала, что никакой проверки не было. Это был мошенник!",
            "next": "lesson_success",
            "effects": {
                "xp": 30,
                "flags": {"spotted_scammer": true}
            }
        },
        
        "lesson_failed": {
            "speaker": "mentor",
            "speaker_name": "🦉 Совёнок",
            "portrait": "owl_concerned",
            "text": "Ой-ой! 😟 Это был мошенник. Но не расстраивайся — ошибки помогают учиться! Давай разберём, что случилось.",
            "next": "reflection_failed"
        },
        
        "lesson_success": {
            "speaker": "mentor",
            "speaker_name": "🦉 Совёнок",
            "portrait": "owl_happy",
            "text": "Отлично! 🌟 Ты молодец! Не дал мошеннику себя обмануть. Давай разберём, какие подсказки помогли тебе.",
            "next": "reflection_success"
        },
        
        "reflection_failed": {
            "type": "reflection",
            "question": "Какие красные флаги ты не заметил?",
            "instruction": "Выбери все признаки обмана:",
            "correct_answers": ["asks_password", "unknown_person", "pressure"],
            "options": [
                {"id": "asks_password", "text": "🚩 Просил пароль", "is_correct": true},
                {"id": "unknown_person", "text": "🚩 Это был незнакомец", "is_correct": true},
                {"id": "pressure", "text": "🚩 Торопил меня", "is_correct": true},
                {"id": "polite", "text": "Он был вежливым", "is_correct": false}
            ],
            "explanation": "Мошенники часто: просят личную информацию (пароли), представляются кем-то важным, торопят. Запомни эти красные флаги! 🚩",
            "effects": {
                "xp": 10,
                "skills": {"observe": 5, "consequence": 5}
            },
            "next": "quest_complete_fail"
        },
        
        "reflection_success": {
            "type": "reflection",
            "question": "Почему ты решил не давать пароль?",
            "instruction": "Выбери лучшее объяснение:",
            "options": [
                {"id": "no_reason", "text": "Просто так, не знаю", "xp": 0},
                {"id": "stranger", "text": "Он был незнакомцем", "xp": 10},
                {"id": "password_secret", "text": "Пароли — это секрет", "xp": 15},
                {"id": "multiple_flags", "text": "Незнакомец + пароль + торопил = опасно!", "xp": 25}
            ],
            "best_answer": "multiple_flags",
            "explanation": "Молодец! 🌟 Ты заметил сразу несколько красных флагов и принял правильное решение. Так держать!",
            "effects": {
                "skills": {"explain": 15}
            },
            "next": "quest_complete_success"
        },
        
        "quest_complete_fail": {
            "type": "end",
            "effects": {
                "quest_complete": "quest_01_locker",
                "quest_outcome": "failed"
            },
            "next_quest": "quest_02"
        },
        
        "quest_complete_success": {
            "type": "end",
            "effects": {
                "quest_complete": "quest_01_locker",
                "quest_outcome": "success",
                "xp": 20
            },
            "next_quest": "quest_02"
        }
    }
}
```

## 8.2 Файл квестов (quests.json)

```json
{
    "quest_01_locker": {
        "id": "quest_01_locker",
        "title": "Новый шкафчик",
        "description": "Твой первый день в школе! Найди свой шкафчик и познакомься с ним.",
        "location": "school_hallway",
        "first_step": "find_locker",
        "objectives": [
            {
                "id": "find_locker",
                "text": "Найди свой шкафчик",
                "type": "reach_location"
            },
            {
                "id": "handle_stranger",
                "text": "Разберись с незнакомцем",
                "type": "complete_dialogue"
            }
        ],
        "rewards": {
            "xp": 50,
            "skills": {
                "observe": 10,
                "decide": 10
            }
        },
        "next_quest": "quest_02_friend"
    },
    
    "quest_02_friend": {
        "id": "quest_02_friend",
        "title": "Новый друг?",
        "description": "Кто-то хочет с тобой подружиться. Но можно ли ему доверять?",
        "location": "school_yard",
        "first_step": "meet_new_kid",
        "prerequisites": ["quest_01_locker"],
        "objectives": [
            {
                "id": "meet_new_kid",
                "text": "Познакомься с новеньким",
                "type": "talk_to_npc"
            }
        ],
        "rewards": {
            "xp": 60,
            "skills": {
                "question": 15,
                "consequence": 10
            }
        }
    }
}
```

## 8.3 Файл навыков (skills.json)

```json
{
    "skills": [
        {
            "id": "observe",
            "name": "Наблюдательность",
            "icon": "👁️",
            "description": "Замечать детали и находить несоответствия",
            "color": "#3399FF",
            "unlock_bonuses": {
                "25": "Получаешь подсказку 'Что-то не так...'",
                "50": "Видишь красные флаги в диалогах",
                "75": "Автоматически замечаешь все признаки обмана",
                "100": "Мастер наблюдения!"
            }
        },
        {
            "id": "question",
            "name": "Любознательность",
            "icon": "❓",
            "description": "Задавать правильные вопросы",
            "color": "#FFCC00",
            "unlock_bonuses": {
                "25": "Открывается 1 дополнительный вопрос",
                "50": "Открывается 2 дополнительных вопроса",
                "75": "Открывается 3 дополнительных вопроса",
                "100": "Мастер вопросов!"
            }
        },
        {
            "id": "explain",
            "name": "Красноречие",
            "icon": "💬",
            "description": "Объяснять свои решения и мысли",
            "color": "#33CC66",
            "unlock_bonuses": {
                "25": "Получаешь больше XP за объяснения",
                "50": "Можешь объяснить решение друзьям NPC",
                "75": "Твои объяснения вдохновляют других",
                "100": "Мастер объяснений!"
            }
        },
        {
            "id": "compare",
            "name": "Анализ",
            "icon": "⚖️",
            "description": "Сравнивать варианты и видеть плюсы/минусы",
            "color": "#CC66FF",
            "unlock_bonuses": {
                "25": "Видишь подсказки о выгодности сделок",
                "50": "Можешь сравнить предложения",
                "75": "Видишь скрытые недостатки",
                "100": "Мастер анализа!"
            }
        },
        {
            "id": "decide",
            "name": "Решительность",
            "icon": "🎯",
            "description": "Принимать осознанные решения",
            "color": "#FF6666",
            "unlock_bonuses": {
                "25": "Видишь вероятность успеха решений",
                "50": "Можешь отменить поспешное решение",
                "75": "Устойчивость к давлению",
                "100": "Мастер решений!"
            }
        },
        {
            "id": "consequence",
            "name": "Предусмотрительность",
            "icon": "🔗",
            "description": "Предвидеть последствия действий",
            "color": "#FF9933",
            "unlock_bonuses": {
                "25": "Видишь ближайшие последствия",
                "50": "Видишь среднесрочные последствия",
                "75": "Видишь долгосрочные последствия",
                "100": "Мастер предвидения!"
            }
        }
    ]
}
```



---

# ЧАСТЬ 9: HUD И МЕНЮ

## 9.1 HUD — Игровой интерфейс

```gdscript
# scripts/ui/hud.gd
extends Control

## Игровой интерфейс — навыки, квест, кнопки

@onready var skill_panel: Control = $SkillPanel
@onready var quest_indicator: Control = $QuestIndicator
@onready var quest_label: Label = $QuestIndicator/QuestLabel
@onready var menu_button: Button = $TopBar/MenuButton
@onready var mentor_button: Button = $BottomBar/MentorButton

# Skill progress bars
@onready var skill_bars: Dictionary = {
    "observe": $SkillPanel/ObserveBar,
    "question": $SkillPanel/QuestionBar,
    "explain": $SkillPanel/ExplainBar,
    "compare": $SkillPanel/CompareBar,
    "decide": $SkillPanel/DecideBar,
    "consequence": $SkillPanel/ConsequenceBar
}


func _ready() -> void:
    # Подключаем кнопки
    menu_button.pressed.connect(_on_menu_pressed)
    mentor_button.pressed.connect(_on_mentor_pressed)
    
    # Подписываемся на события
    SkillManager.skill_changed.connect(_on_skill_changed)
    QuestManager.quest_started.connect(_on_quest_started)
    QuestManager.quest_updated.connect(_on_quest_updated)
    QuestManager.quest_completed.connect(_on_quest_completed)
    
    # Обновляем UI
    _update_skills_display()
    _update_quest_display()


func _update_skills_display() -> void:
    for skill_id in skill_bars:
        var bar: ProgressBar = skill_bars[skill_id]
        if bar:
            bar.value = SkillManager.get_player_skill_level(skill_id)


func _update_quest_display() -> void:
    var current_quest: Dictionary = QuestManager.get_current_quest()
    
    if current_quest.is_empty():
        quest_indicator.visible = false
    else:
        quest_indicator.visible = true
        quest_label.text = current_quest.get("title", "Квест")


func _on_skill_changed(skill_id: String, _old: int, new_value: int) -> void:
    if skill_id in skill_bars:
        var bar: ProgressBar = skill_bars[skill_id]
        if bar:
            # Анимация изменения
            var tween := create_tween()
            tween.tween_property(bar, "value", new_value, 0.5)


func _on_quest_started(_quest_id: String, quest_data: Dictionary) -> void:
    quest_indicator.visible = true
    quest_label.text = quest_data.get("title", "Новый квест")
    
    # Анимация появления
    quest_indicator.modulate.a = 0.0
    var tween := create_tween()
    tween.tween_property(quest_indicator, "modulate:a", 1.0, 0.3)


func _on_quest_updated(_quest_id: String, _step: String) -> void:
    # Можно добавить анимацию обновления
    pass


func _on_quest_completed(_quest_id: String, _outcome: String) -> void:
    # Анимация завершения
    var tween := create_tween()
    tween.tween_property(quest_indicator, "modulate:a", 0.0, 0.3)
    await tween.finished
    quest_indicator.visible = false


func _on_menu_pressed() -> void:
    GameManager.change_state(GameManager.GameState.PAUSED)
    # Открыть меню паузы
    # get_tree().change_scene_to_file("res://scenes/ui/pause_menu.tscn")


func _on_mentor_pressed() -> void:
    # Вызвать ментора
    AIManager.ask_mentor("general_help", "Игрок попросил помощь", func(response):
        # Показать ответ в отдельном окне
        print("Mentor says: " + response)
    )
```

## 9.2 Главное меню (main_menu.gd)

```gdscript
# scripts/ui/main_menu.gd
extends Control

## Главное меню игры

@onready var new_game_button: Button = $VBox/NewGameButton
@onready var continue_button: Button = $VBox/ContinueButton
@onready var settings_button: Button = $VBox/SettingsButton
@onready var quit_button: Button = $VBox/QuitButton
@onready var version_label: Label = $VersionLabel


func _ready() -> void:
    # Подключаем кнопки
    new_game_button.pressed.connect(_on_new_game)
    continue_button.pressed.connect(_on_continue)
    settings_button.pressed.connect(_on_settings)
    quit_button.pressed.connect(_on_quit)
    
    # Проверяем наличие сохранения
    continue_button.disabled = not SaveManager.has_save()
    
    # Версия
    version_label.text = "v" + ProjectSettings.get_setting("application/config/version", "0.1.0")
    
    # Устанавливаем состояние
    GameManager.change_state(GameManager.GameState.MENU)
    
    # Музыка меню
    AudioManager.play_music("menu_theme.ogg")


func _on_new_game() -> void:
    # Подтверждение, если есть сохранение
    if SaveManager.has_save():
        # TODO: Показать диалог подтверждения
        pass
    
    GameManager.new_game()


func _on_continue() -> void:
    GameManager.continue_game()


func _on_settings() -> void:
    # TODO: Открыть настройки
    pass


func _on_quit() -> void:
    get_tree().quit()
```

## 9.3 Структура сцены главного меню (main_menu.tscn)

```
MainMenu (Control) [main_menu.gd]
├── Background (TextureRect)
│   └── Texture: menu_background.png
│
├── Logo (TextureRect)
│   └── Texture: game_logo.png
│   └── Position: center top
│
├── VBox (VBoxContainer)
│   └── Anchors: center
│   ├── NewGameButton (Button)
│   │   └── Text: "Новая игра"
│   ├── ContinueButton (Button)
│   │   └── Text: "Продолжить"
│   ├── SettingsButton (Button)
│   │   └── Text: "Настройки"
│   └── QuitButton (Button)
│       └── Text: "Выход"
│
├── VersionLabel (Label)
│   └── Anchors: bottom right
│   └── Text: "v0.1.0"
│
└── MentorIntro (Control)  [опционально]
    └── Owl animation for new players
```

---

# ЧАСТЬ 10: ИНСТРУКЦИИ ДЛЯ CLAUDE CODE

## 10.1 Порядок создания проекта

```markdown
## ШАГ 1: Инициализация проекта
1. Создать папку проекта `antiobman`
2. Создать файл `project.godot` из раздела 1.2
3. Создать структуру папок из раздела 2.1
4. Создать `.gitignore`

## ШАГ 2: Autoload скрипты (КРИТИЧНО — создать первыми!)
1. game_manager.gd
2. save_manager.gd  
3. dialogue_manager.gd
4. skill_manager.gd
5. quest_manager.gd
6. ai_manager.gd
7. audio_manager.gd
8. player_data.gd (class_name PlayerData)

## ШАГ 3: Данные (JSON файлы)
1. data/quests/quests.json
2. data/skills/skills.json
3. data/dialogues/quest_01_locker.json

## ШАГ 4: Игрок
1. scripts/player/player_controller.gd
2. scenes/player/player.tscn

## ШАГ 5: NPC
1. scripts/npc/npc_base.gd
2. scripts/npc/stranger_npc.gd
3. scenes/npcs/npc_base.tscn
4. scenes/npcs/stranger.tscn

## ШАГ 6: UI
1. scripts/dialogue/dialogue_ui.gd
2. scripts/dialogue/choice_button.gd
3. scripts/ui/virtual_joystick.gd
4. scripts/ui/hud.gd
5. scenes/ui/dialogue_box.tscn
6. scenes/ui/choice_button.tscn
7. scenes/ui/virtual_joystick.tscn
8. scenes/ui/hud.tscn

## ШАГ 7: Локация
1. Создать TileSet для школы
2. scenes/locations/school/school_hallway.tscn
3. Скрипт локации

## ШАГ 8: Главные сцены
1. scenes/ui/main_menu.tscn
2. scenes/main.tscn (запуск main_menu)

## ШАГ 9: Тестирование
1. Запустить проект
2. Проверить переход меню -> игра
3. Проверить движение игрока
4. Проверить диалог с мошенником
5. Проверить сохранение
```

## 10.2 Заглушки для ассетов

```markdown
## Временные ассеты (placeholder)

Пока нет графики, используй:
- Sprite2D с ColorRect вместо текстур
- Простые формы для персонажей (квадрат = NPC, круг = игрок)
- Label с эмодзи для иконок навыков

Пример создания placeholder игрока:
```gdscript
# В player.tscn вместо AnimatedSprite2D:
var placeholder = ColorRect.new()
placeholder.size = Vector2(32, 32)
placeholder.color = Color.BLUE
add_child(placeholder)
```

## Placeholder для портретов:
```gdscript
# Создать простые цветные квадраты:
# stranger_smile.png -> красный квадрат 64x64
# owl_happy.png -> синий квадрат 64x64
```
```

## 10.3 Команды для проверки

```bash
# Запуск проекта из командной строки
godot --path /path/to/antiobman --editor

# Запуск игры
godot --path /path/to/antiobman

# Экспорт для Android (требует настройки)
godot --path /path/to/antiobman --export-release "Android" antiobman.apk
```

## 10.4 Частые ошибки и решения

```markdown
## Ошибка: "Cannot find autoload script"
→ Проверь путь в project.godot, должен быть res://scripts/autoload/

## Ошибка: "Invalid call to function 'add_xp'"
→ PlayerData не инициализирован. Проверь GameManager._load_or_create_player_data()

## Ошибка: "Cannot load scene"
→ Проверь путь к сцене, используй res:// prefix

## Диалог не запускается
→ Проверь JSON файл на валидность (jsonlint.com)
→ Проверь что dialogue_id совпадает с именем файла

## Игрок не двигается
→ Проверь GameManager.current_state == PLAYING
→ Проверь Input Map в project.godot

## Сохранение не работает
→ Проверь права на user:// директорию
→ Проверь что to_dict() возвращает сериализуемые данные
```

## 10.5 Минимальный тестовый запуск

```gdscript
# Для быстрого теста создай scenes/test.tscn:

extends Node2D

func _ready():
    print("=== ANTIOBMAN TEST ===")
    
    # Тест GameManager
    print("GameManager state: ", GameManager.current_state)
    print("Player data: ", GameManager.player_data != null)
    
    # Тест SaveManager
    print("Has save: ", SaveManager.has_save())
    
    # Тест SkillManager
    print("Skills loaded: ", SkillManager.get_all_skills().size())
    
    # Тест QuestManager
    QuestManager.start_quest("quest_01_locker")
    print("Current quest: ", QuestManager.current_quest_id)
    
    # Тест DialogueManager
    DialogueManager.dialogue_started.connect(func(id, npc): 
        print("Dialogue started: ", id)
    )
    
    print("=== ALL SYSTEMS OK ===")
```

---

# ЧАСТЬ 11: ЧЕКЛИСТ ГОТОВНОСТИ MVP

```markdown
## Функциональность

### Core Systems
- [ ] GameManager работает, состояния переключаются
- [ ] SaveManager сохраняет/загружает данные
- [ ] PlayerData корректно сериализуется
- [ ] DialogueManager парсит JSON и показывает диалоги
- [ ] SkillManager отслеживает навыки
- [ ] QuestManager управляет квестами
- [ ] AIManager возвращает ответы (mock)
- [ ] AudioManager проигрывает звуки

### Gameplay
- [ ] Игрок двигается (клавиатура)
- [ ] Игрок двигается (виртуальный джойстик)
- [ ] Игрок взаимодействует с NPC
- [ ] Диалоги отображаются корректно
- [ ] Выборы в диалогах работают
- [ ] Красные флаги показываются (при навыке 50%+)
- [ ] Эффекты применяются (XP, навыки, флаги)
- [ ] Квест завершается

### UI
- [ ] Главное меню работает
- [ ] HUD показывает навыки
- [ ] Диалоговое окно появляется/исчезает
- [ ] Кнопки выбора кликабельны
- [ ] Виртуальный джойстик работает на touch

### Первый квест "Новый шкафчик"
- [ ] Мошенник появляется при подходе к шкафчику
- [ ] Диалог загружается и отображается
- [ ] Все ветки диалога проходимы
- [ ] Рефлексия работает
- [ ] Квест завершается с правильным outcome
- [ ] Сохранение фиксирует результат

## Технические требования
- [ ] Проект запускается без ошибок
- [ ] FPS стабильный (60)
- [ ] Нет утечек памяти
- [ ] Сохранение не превышает 1 MB
- [ ] Работает на мобильном разрешении (1080x1920)
```

---

**Документ создан:** 2025-12-03  
**Версия:** 1.0  
**Для:** Claude Code / Godot 4.3+
