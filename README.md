# Upwise — Flutter Android Starter

Upwise is an AI-powered personal growth and life-management application for students, professionals, freelancers, and entrepreneurs. It helps translate ambitions into realistic daily actions, tracks multidimensional progress, and adapts plans through proactive AI coaching.

---

## What is Included

### Flutter Frontend (`lib/`)
- **Modular Feature Architecture**: Structured clean architecture decomposing the application into `app/`, `core/`, and `features/`.
- **Conversational Onboarding Flow** (`features/onboarding/`): Multi-step progressive discovery asking one contextual question at a time (life stage, primary focus, daily time capacity, coaching style), with skip support and an AI confirmation summary screen.
- **Design System & Theme Tokens** (`app/theme/`): Dedicated `AppColors`, `AppTypography`, and `AppTheme` with custom purple-seeded Material 3 tokens.
- **Core Reusable Components** (`core/widgets/`): `UpwiseCard`, `ProgressBar`, and `SectionHeader`.
- **Home Dashboard** (`features/home/`): Daily overview, dynamic task completion metrics, quick priority creation dialog, and contextual AI insights.
- **Goals & Milestones** (`features/goals/`): Category-badged goals, visual completion bars, creation dialog, and bottom sheet progress adjusters.
- **AI Coach Experience** (`features/ai_coach/`): Adaptive conversational coaching service, quick prompt suggestions, and 1-tap accept proposed tasks into daily priorities.
- **Connected Growth Grid** (`features/growth/`): 6-dimensional growth modules (Career, Income, Skills, Mental Focus, Health, Future Scenarios) with diagnostic bottom sheets.
- **Profile & Governance** (`features/profile/`): Active user context, AI memory transparency dialog, redo onboarding, and privacy preferences.
- **Main Navigation Shell** (`features/shell/`): 5-tab Material 3 navigation bar maintaining state across features.

### Backend Scaffold (`backend/`)
- FastAPI application with `/health` and versioned API (`/api/v1/`).
- Supabase Auth bearer token validation.
- Async SQLAlchemy PostgreSQL models and Pydantic schemas for goals, tasks, and coach requests.
- OpenAI Responses API integration scaffolding with server-side keys.

---

## Directory Structure

```text
upwise/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       ├── app_typography.dart
│   │       └── app_theme.dart
│   ├── core/
│   │   └── widgets/
│   │       ├── upwise_card.dart
│   │       ├── progress_bar.dart
│   │       └── section_header.dart
│   └── features/
│       ├── onboarding/
│       ├── home/
│       ├── goals/
│       ├── tasks/
│       ├── ai_coach/
│       ├── growth/
│       ├── profile/
│       └── shell/
├── backend/
│   ├── app/
│   │   ├── routes/
│   │   ├── auth.py
│   │   ├── database.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   └── main.py
│   └── requirements.txt
├── docs/
│   └── BACKEND_IMPLEMENTATION_STATUS.md
└── Upwise_PRD_and_Development_Handoff.md
```

---

## Running Locally

### Mobile (Flutter)
```bash
flutter pub get
flutter run
```

To create an Android debug APK:
```bash
flutter build apk --debug
```

### Backend (FastAPI)
Before starting the backend, copy `backend/.env.example` to `backend/.env` and set
the Supabase URL, public key, and PostgreSQL connection string from your Supabase
project. Keep the database password in the backend environment file; never put it
in Flutter.

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Or on Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

For Android Emulator development:

```powershell
flutter run --dart-define=UPWISE_API_URL=http://10.0.2.2:8000
```

For a physical device or production build, set `UPWISE_API_URL` to a reachable
backend URL; production URLs should use HTTPS.

---

## Next Engineering Steps

1. Configure Supabase project credentials and PostgreSQL connection in `backend/.env`.
2. Deploy the FastAPI backend and configure the mobile app's `UPWISE_API_URL`.
3. Run Alembic database migrations and set up PostgreSQL Row Level Security (RLS) policies.
