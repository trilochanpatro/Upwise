import os
import pytest
from httpx import ASGITransport, AsyncClient

# Isolate automated tests from production Supabase database
os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///./test_upwise.db"

from app.database import engine
from app.models import Base
from app.main import app

AUTH_HEADERS = {"Authorization": "Bearer dev-test-token"}


@pytest.fixture(autouse=True)
async def setup_database():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield


@pytest.mark.asyncio
async def test_health_check():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert data["service"] == "upwise-api"


@pytest.mark.asyncio
async def test_goals_unauthorized():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/goals")
        assert response.status_code == 401


@pytest.mark.asyncio
async def test_profile_persistence_and_clear():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Upsert profile
        payload = {
            "life_stage": "Employed professional",
            "primary_goal_area": "Build key skills & portfolio",
            "daily_time_commitment": "45–60 minutes daily",
            "preferred_style": "Action-oriented & direct",
            "is_completed": True,
        }
        res_put = await client.put("/api/v1/profile", json=payload, headers=AUTH_HEADERS)
        assert res_put.status_code == 200
        data = res_put.json()
        assert data["life_stage"] == payload["life_stage"]
        assert data["is_completed"] is True

        # Get profile
        res_get = await client.get("/api/v1/profile", headers=AUTH_HEADERS)
        assert res_get.status_code == 200
        assert res_get.json()["primary_goal_area"] == payload["primary_goal_area"]

        # Clear profile memory
        res_del = await client.delete("/api/v1/profile", headers=AUTH_HEADERS)
        assert res_del.status_code == 204
        res_after = await client.get("/api/v1/profile", headers=AUTH_HEADERS)
        assert res_after.status_code == 200
        assert res_after.json()["is_completed"] is False


@pytest.mark.asyncio
async def test_goal_crud_lifecycle():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        create_payload = {
            "title": "Master Backend Systems",
            "description": "Learn FastAPI, Supabase, and async PostgreSQL",
            "category": "Career",
        }
        res_create = await client.post("/api/v1/goals", json=create_payload, headers=AUTH_HEADERS)
        assert res_create.status_code == 201
        created_goal = res_create.json()
        goal_id = created_goal["id"]
        assert created_goal["title"] == create_payload["title"]
        assert created_goal["category"] == "Career"
        assert created_goal["progress"] == 0.0

        res_list = await client.get("/api/v1/goals", headers=AUTH_HEADERS)
        assert res_list.status_code == 200
        assert any(g["id"] == goal_id for g in res_list.json())

        res_update = await client.patch(
            f"/api/v1/goals/{goal_id}/progress",
            json={"progress": 45.0},
            headers=AUTH_HEADERS,
        )
        assert res_update.status_code == 200
        assert res_update.json()["progress"] == 45.0

        res_delete = await client.delete(f"/api/v1/goals/{goal_id}", headers=AUTH_HEADERS)
        assert res_delete.status_code == 204


@pytest.mark.asyncio
async def test_task_crud_lifecycle():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        res_goal = await client.post(
            "/api/v1/goals",
            json={"title": "Task Test Goal", "category": "Skills"},
            headers=AUTH_HEADERS,
        )
        goal_id = res_goal.json()["id"]

        task_payload = {
            "title": "Complete 30-min coding sprint",
            "description": "Focus block on API verification",
            "category": "Skills",
            "estimated_minutes": 30,
            "priority": "high",
            "goal_id": goal_id,
        }
        res_task = await client.post("/api/v1/tasks", json=task_payload, headers=AUTH_HEADERS)
        assert res_task.status_code == 201
        created_task = res_task.json()
        task_id = created_task["id"]
        assert created_task["title"] == task_payload["title"]
        assert created_task["is_completed"] is False
        assert created_task["goal_id"] == goal_id

        res_tasks = await client.get("/api/v1/tasks", headers=AUTH_HEADERS)
        assert res_tasks.status_code == 200
        assert any(t["id"] == task_id for t in res_tasks.json())

        res_complete = await client.patch(
            f"/api/v1/tasks/{task_id}/completion",
            json={"is_completed": True},
            headers=AUTH_HEADERS,
        )
        assert res_complete.status_code == 200
        assert res_complete.json()["is_completed"] is True

        res_del_task = await client.delete(f"/api/v1/tasks/{task_id}", headers=AUTH_HEADERS)
        assert res_del_task.status_code == 204


@pytest.mark.asyncio
async def test_coach_chat_history_and_insight():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Clear previous history
        res_clear = await client.delete("/api/v1/coach/history", headers=AUTH_HEADERS)
        assert res_clear.status_code == 204

        # Chat message
        res = await client.post(
            "/api/v1/coach/chat",
            json={"message": "I feel overwhelmed with my career goals today."},
            headers=AUTH_HEADERS,
        )
        assert res.status_code == 200
        data = res.json()
        assert "reply" in data
        assert data["mode"] in ("smart_coach", "live_ai")
        assert data["proposed_task"] is not None
        assert "title" in data["proposed_task"]

        # Verify persisted history (user + assistant)
        res_hist = await client.get("/api/v1/coach/history", headers=AUTH_HEADERS)
        assert res_hist.status_code == 200
        history = res_hist.json()
        assert len(history) == 2
        assert history[0]["is_user"] is True
        assert history[1]["is_user"] is False
        assert history[1]["proposed_task"] is not None

        # Verify daily insight endpoint
        res_insight = await client.get("/api/v1/coach/insight", headers=AUTH_HEADERS)
        assert res_insight.status_code == 200
        insight_data = res_insight.json()
        assert len(insight_data["insight"]) > 0
