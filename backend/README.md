# Upwise Backend — FastAPI + Supabase

## Included
- FastAPI application and `/health` endpoint.
- Supabase Auth access-token validation through Supabase Auth `/user`.
- PostgreSQL async SQLAlchemy models for goals and tasks.
- User-scoped goal and task endpoints.
- AI Coach endpoint using the OpenAI Responses API.
- Safe placeholder response when the OpenAI key is not configured.

## Setup

1. Create a Supabase project.
2. Copy `.env.example` to `.env` and fill in:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `DATABASE_URL` (use a PostgreSQL connection string compatible with asyncpg)
   - `OPENAI_API_KEY` (optional until live AI testing)
3. Create and activate a Python virtual environment.
4. Install dependencies:

```bash
python -m venv .venv
# macOS/Linux
source .venv/bin/activate
# Windows PowerShell
# .venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Open `http://localhost:8000/docs` for interactive API documentation.

## API endpoints

All endpoints except `/health` require `Authorization: Bearer <Supabase access token>`.

- `GET /health`
- `GET /api/v1/goals`
- `POST /api/v1/goals`
- `PATCH /api/v1/goals/{goal_id}/progress`
- `GET /api/v1/tasks`
- `POST /api/v1/tasks`
- `PATCH /api/v1/tasks/{task_id}/completion`
- `POST /api/v1/coach/chat`

## Security notes

- Keep `.env` out of version control.
- Never put the OpenAI API key in Flutter.
- The API validates the access token with Supabase Auth and uses the authenticated user ID for all goal/task queries.
- This starter uses application-level ownership filters. Before production, add and test PostgreSQL Row Level Security policies, migrations, rate limits, request logging with sensitive-data redaction, and stricter operational controls.
- The `create_all` startup hook is for local development only. Use Alembic migrations for production.
- Do not expose raw AI provider errors to clients.

## Current limitations

- No chat history persistence yet.
- No user profile or AI memory tables/endpoints yet.
- No task generation endpoint: AI suggestions are text only and do not silently create records.
- No automated tests or production deployment configuration yet.
- No CORS allowlist configured; add the exact app/web origins if needed.

## Next steps

1. Run locally with Supabase credentials.
2. Add Alembic migrations and automated tests.
3. Add chat persistence and explicit user-approved plan/task creation.
4. Connect Flutter authentication and API client.
5. Add rate limits, monitoring, and production secrets management.
