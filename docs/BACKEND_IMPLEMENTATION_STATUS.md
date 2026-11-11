# Backend Implementation Status

## Decision
Backend architecture: **Supabase + FastAPI**.

## Scaffold & Local Verification
- **FastAPI Core**: Versioned API routes (`/api/v1/`) with proper lifespans and `/health` monitoring.
- **Supabase Auth Integration**: Token verification via Supabase Auth `/auth/v1/user`, with offline development and test support (`dev-test-token`).
- **Database Engine**: Async SQLAlchemy models for `Goal` and `Task` using universal `Uuid` mapping compatible with both Supabase PostgreSQL and SQLite.
- **Config & Environment**: Structured Pydantic `Settings` loading from `backend/.env`.
- **AI Coach Endpoint**: `/api/v1/coach/chat` connected with server-side OpenAI orchestration and graceful placeholder fallback when key is not provided.
- **Automated Verification**: Complete test suite in `backend/tests/test_api.py` covering:
  - `GET /health` (200 OK)
  - `GET /api/v1/goals` unauthenticated check (401 Unauthorized)
  - `POST /api/v1/goals` and `PATCH /api/v1/goals/{id}/progress` (201 Created & 200 OK)
  - `POST /api/v1/tasks` and `PATCH /api/v1/tasks/{id}/completion` (201 Created & 200 OK)
  - `POST /api/v1/coach/chat` (200 OK)

## Production Supabase Configuration Checklist
To connect the backend to your live Supabase project:
1. Create a project in the [Supabase Dashboard](https://supabase.com).
2. Go to **Project Settings -> API** and copy:
   - `Project URL` -> Paste into `SUPABASE_URL` in `backend/.env`.
   - `Project API Keys (anon public)` -> Paste into `SUPABASE_ANON_KEY` in `backend/.env`.
3. Go to **Project Settings -> Database** and copy:
   - Connection String (URI, asyncpg format) -> Set as `DATABASE_URL` in `backend/.env`:
     `postgresql+asyncpg://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres`
4. Set `DEBUG=false` in production.

## Flutter Integration
- Supabase Auth email sign-up/sign-in is connected to the existing Flutter app.
- The app loads and saves goals and tasks through the authenticated FastAPI endpoints.
- Configure `UPWISE_API_URL` when launching Flutter; the Android Emulator default is `http://10.0.2.2:8000`.
- Set the actual Supabase URL, public key, and PostgreSQL connection string in `backend/.env` before running against the project.

## Next Checkpoint
Configure and deploy the API against the Supabase PostgreSQL database, then validate the authenticated mobile flow with a real Supabase account. Add migrations and production RLS policies before deployment.
