from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine
from app.models import Base
from app.routes import goals, tasks, coach, profile


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Auto-create tables for local development. In production, prefer managed migrations (Alembic).
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()


app = FastAPI(
    title="Upwise API",
    version="0.1.0",
    description="Backend API for the Upwise Personal Growth Platform.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(goals.router, prefix="/api/v1")
app.include_router(tasks.router, prefix="/api/v1")
app.include_router(coach.router, prefix="/api/v1")
app.include_router(profile.router, prefix="/api/v1")


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "service": "upwise-api",
        "debug": settings.debug,
    }
