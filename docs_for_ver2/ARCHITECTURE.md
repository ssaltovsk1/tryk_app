# Техническая архитектура: Образовательная RPG "АнтиОбман"

## 1. Обзор системы

### 1.1 Цель проекта
Мобильная образовательная RPG для детей 6-10 лет, обучающая критическому мышлению и противодействию мошенникам через игровые механики.

### 1.2 Ключевые требования
- Кроссплатформенность (iOS + Android)
- Модульная загрузка контента (уровни, герои, квесты)
- ИИ-ментор для обучения
- Мультиплеер с модерацией (в будущем)
- Интеграция видео-контента

### 1.3 Технологический стек

| Компонент | Технология | Обоснование |
|-----------|------------|-------------|
| Игровой движок | Unity 2022 LTS | Кроссплатформа, Addressables, большое сообщество |
| Язык клиента | C# | Нативный для Unity |
| Backend | Node.js + NestJS | Высокая производительность, TypeScript |
| База данных | PostgreSQL + Redis | Надёжность + кэширование |
| Real-time | Socket.IO | Чат и синхронизация |
| ИИ | Claude API / OpenAI | Качество + безопасность для детей |
| CDN/Storage | AWS S3 + CloudFront | Доставка контент-паков |
| Аутентификация | Firebase Auth | Простота + родительский контроль |

---

## 2. Архитектура высокого уровня

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              КЛИЕНТ (Unity)                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   UI/UX     │  │  Gameplay   │  │  Dialogue   │  │  Content Manager    │ │
│  │   Layer     │  │   Core      │  │   System    │  │  (Addressables)     │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Player    │  │  Quest      │  │  Skill Tree │  │  Network Manager    │ │
│  │   System    │  │  System     │  │   System    │  │  (API + WebSocket)  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS / WSS
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API GATEWAY                                    │
│                         (Kong / AWS API Gateway)                            │
│                    Rate Limiting, Auth, Logging                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────────┐
│    GAME SERVER        │ │    AI SERVICE     │ │    CONTENT SERVICE        │
│    (NestJS)           │ │    (Python/Node)  │ │    (NestJS)               │
├───────────────────────┤ ├───────────────────┤ ├───────────────────────────┤
│ • Auth & Sessions     │ │ • AI Mentor API   │ │ • Content Pack Manager    │
│ • Player Progress     │ │ • Input Filter    │ │ • Asset Versioning        │
│ • Quest Management    │ │ • Output Filter   │ │ • Download Manager        │
│ • Leaderboards        │ │ • Prompt Engine   │ │ • Validation              │
│ • Chat (future)       │ │ • Response Cache  │ │                           │
└───────────────────────┘ └───────────────────┘ └───────────────────────────┘
          │                       │                         │
          ▼                       ▼                         ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────────┐
│     PostgreSQL        │ │   Claude/OpenAI   │ │      AWS S3 + CDN         │
│     + Redis           │ │       API         │ │                           │
└───────────────────────┘ └───────────────────┘ └───────────────────────────┘
```

---

## 3. Клиентская архитектура (Unity)

### 3.1 Структура проекта

```
Assets/
├── _Core/                      # Ядро (не меняется)
│   ├── Scripts/
│   │   ├── Core/
│   │   │   ├── GameManager.cs
│   │   │   ├── ServiceLocator.cs
│   │   │   └── EventBus.cs
│   │   ├── Player/
│   │   │   ├── PlayerController.cs
│   │   │   ├── PlayerData.cs
│   │   │   └── PlayerMovement.cs
│   │   ├── Dialogue/
│   │   │   ├── DialogueManager.cs
│   │   │   ├── DialogueUI.cs
│   │   │   └── ChoiceHandler.cs
│   │   ├── Quest/
│   │   │   ├── QuestManager.cs
│   │   │   ├── QuestData.cs
│   │   │   └── QuestTracker.cs
│   │   ├── SkillTree/
│   │   │   ├── SkillTreeManager.cs
│   │   │   ├── SkillNode.cs
│   │   │   └── SkillTreeUI.cs
│   │   ├── AI/
│   │   │   ├── AIMentorService.cs
│   │   │   ├── AIRequestHandler.cs
│   │   │   └── AIResponseParser.cs
│   │   ├── Network/
│   │   │   ├── NetworkManager.cs
│   │   │   ├── APIClient.cs
│   │   │   └── WebSocketClient.cs
│   │   ├── Content/
│   │   │   ├── ContentManager.cs
│   │   │   ├── ContentPackLoader.cs
│   │   │   └── ContentValidator.cs
│   │   └── UI/
│   │       ├── UIManager.cs
│   │       ├── Screens/
│   │       └── Components/
│   ├── Prefabs/
│   └── Resources/
│
├── _Content/                   # Контент по умолчанию
│   ├── Levels/
│   ├── Characters/
│   ├── Dialogues/
│   └── Quests/
│
└── AddressableAssets/          # Для Addressables
    └── ContentPacks/
```

### 3.2 Модульная система (Addressables)

**Структура контент-пака:**
```
ContentPack_Level01_v1.0/
├── manifest.json          # Метаданные пака
├── level_data.json        # Конфигурация уровня
├── dialogues/             # Диалоги в JSON
├── quests/                # Квесты
├── sprites/               # Графика
├── audio/                 # Звуки
└── prefabs/               # Unity prefabs
```

**manifest.json пример:**
```json
{
  "packId": "level_01_city",
  "version": "1.0.0",
  "minGameVersion": "1.0.0",
  "displayName": "Город: Первые шаги",
  "description": "Обучение базовым навыкам безопасности",
  "targetAge": "6-8",
  "skills": ["basic_recognition", "saying_no"],
  "dependencies": [],
  "size": 15000000,
  "checksum": "sha256:abc123..."
}
```

### 3.3 Система диалогов

**Формат диалога (JSON):**
```json
{
  "dialogueId": "scammer_fake_prize",
  "npcId": "mysterious_stranger",
  "trigger": "on_approach",
  "nodes": [
    {
      "id": "start",
      "speaker": "stranger",
      "emotion": "excited",
      "text": "Поздравляю! Ты выиграл редкий меч! Просто скажи пароль от сундука!",
      "redFlags": ["too_good_to_be_true", "asks_for_password"],
      "choices": [
        {
          "text": "Вау, круто! Мой пароль...",
          "outcome": "fell_for_scam",
          "next": "scam_success"
        },
        {
          "text": "Почему тебе нужен мой пароль?",
          "skillBonus": "critical_thinking",
          "next": "question_scammer"
        },
        {
          "text": "Нет, пароли нельзя говорить никому",
          "outcome": "resisted_scam",
          "next": "resist_success"
        },
        {
          "text": "Спросить у Совёнка",
          "action": "call_ai_mentor",
          "context": "stranger_asks_password",
          "next": "after_mentor"
        }
      ]
    }
  ]
}
```

### 3.4 Древо умений

**Структура навыков:**
```json
{
  "branches": [
    {
      "id": "recognition",
      "name": "Распознавание",
      "skills": [
        {
          "id": "spot_fake_friend",
          "name": "Фейковые друзья",
          "prerequisites": [],
          "unlockCost": 100,
          "bonuses": [
            {
              "type": "dialogue_hint",
              "trigger": "npc_asks_for_items",
              "hint": "🤔 Настоящие друзья не просят твои вещи сразу"
            }
          ]
        }
      ]
    },
    {
      "id": "resistance",
      "name": "Устойчивость",
      "skills": [
        {
          "id": "say_no",
          "name": "Умение отказывать",
          "prerequisites": [],
          "unlockCost": 100
        }
      ]
    }
  ]
}
```

---

## 4. Серверная архитектура

### 4.1 AI Service (Детальная архитектура)

```
INPUT FILTER
    ↓
  1. Удаление личных данных (имена, адреса, телефоны)
  2. Блокировка неуместного контента
  3. Нормализация текста
    ↓
CONTEXT BUILDER
    ↓
  • Системный промпт (роль ментора)
  • Контекст диалога
  • Уровень ребёнка
  • История общения
    ↓
AI PROVIDER (Claude / OpenAI)
    ↓
OUTPUT FILTER
    ↓
  1. Проверка на неуместный контент
  2. Добавление эмодзи для детей
  3. Fallback при ошибке
    ↓
RESPONSE CACHE (Redis)
```

**Системный промпт для ментора:**
```
Ты — Совёнок, дружелюбный ментор в образовательной игре для детей 6-10 лет.

ТВОЯ РОЛЬ:
- Помогать детям распознавать мошенников и обман
- Объяснять сложные вещи простым языком
- Поддерживать и хвалить за правильные решения
- Мягко объяснять ошибки без критики

ПРАВИЛА:
- Используй простые слова (максимум 2 слога)
- Добавляй эмодзи: 😊 👍 🤔 ⚠️
- Отвечай коротко (2-4 предложения)
- Никогда не давай личных данных
- Перенаправляй к родителям при сложных вопросах
```

### 4.2 Content Service API

```
GET  /api/v1/content/packs              # Список доступных паков
GET  /api/v1/content/packs/{id}/download # Скачать пак
POST /api/v1/content/check-updates      # Проверить обновления
```

### 4.3 База данных

```sql
-- Пользователи
CREATE TABLE users (
    id UUID PRIMARY KEY,
    firebase_uid VARCHAR(128) UNIQUE,
    display_name VARCHAR(50),
    age INT,
    parent_email VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Прогресс игрока
CREATE TABLE player_progress (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    current_level VARCHAR(50),
    experience_points INT DEFAULT 0,
    play_time_minutes INT DEFAULT 0
);

-- Навыки
CREATE TABLE player_skills (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    skill_id VARCHAR(50),
    is_unlocked BOOLEAN DEFAULT FALSE,
    progress INT DEFAULT 0
);

-- Выполненные квесты
CREATE TABLE completed_quests (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    quest_id VARCHAR(50),
    outcome VARCHAR(50),
    choices_made JSONB,
    completed_at TIMESTAMP DEFAULT NOW()
);

-- История AI-общения
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    context VARCHAR(100),
    user_input TEXT,
    ai_response TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Контент-паки
CREATE TABLE content_packs (
    id UUID PRIMARY KEY,
    pack_id VARCHAR(50) UNIQUE,
    version VARCHAR(20),
    display_name VARCHAR(100),
    cdn_url VARCHAR(500),
    checksum VARCHAR(64),
    is_active BOOLEAN DEFAULT TRUE
);
```

---

## 5. Система безопасности

### 5.1 Защита детей (COPPA compliance)

**Регистрация:**
- Email родителя обязателен
- Подтверждение родителем через email
- Возраст вводится при регистрации
- Минимальные личные данные

**Чат (будущее):**
- Только готовые фразы ИЛИ модерируемый текст
- AI-фильтр всех сообщений
- Блокировка личных данных
- Репорт система
- Родительский контроль

**AI-общение:**
- Строгий системный промпт
- Двойная фильтрация (вход + выход)
- Лимит сообщений в день
- Логирование для review
- Fallback на безопасные заготовки

---

## 6. DevOps и инфраструктура

### 6.1 CI/CD Pipeline

**Unity Client:**
```
Git Push → Unity Cloud Build → Tests → APK/IPA
    → Firebase App Distribution (тестеры)
    → App Store / Google Play (релиз)
```

**Backend:**
```
Git Push → GitHub Actions → Tests → Docker Build
    → Push to ECR → Deploy to ECS (staging → prod)
```

**Content Packs:**
```
Git Push → Validate JSON/Assets → Build Bundle
    → Upload to S3 → Invalidate CloudFront → Update DB
```

### 6.2 AWS Infrastructure

```
CloudFront (CDN) — раздача контент-паков
       ↓
Application Load Balancer (SSL)
       ↓
┌──────────────┬──────────────┬──────────────┐
│ ECS: Game API│ ECS: AI Svc  │ ECS: Content │
└──────────────┴──────────────┴──────────────┘
       ↓              ↓              ↓
   PostgreSQL      Claude API      AWS S3
   + Redis
```

---

## 7. Масштабирование

### 7.1 Метрики производительности

| Метрика | Цель | Критично |
|---------|------|----------|
| API Response | < 200ms | < 500ms |
| AI Response | < 3s | < 5s |
| Content Download | < 30s/10MB | < 60s/10MB |
| App Start | < 5s | < 10s |
| Concurrent Users | 10,000 | 50,000 |

### 7.2 Кэширование

**CLIENT (Unity):**
- Addressables cache — скачанные паки
- Player prefs — настройки, прогресс
- Memory cache — текущая сессия

**CDN (CloudFront):**
- Content packs — TTL 7 дней
- Static assets — TTL 30 дней

**SERVER (Redis):**
- AI responses — TTL 24 часа
- User sessions — TTL 1 час
- Rate limiting — TTL 1 минута

---

*Документ создан: 2025-12-03*
*Версия: 1.0*
