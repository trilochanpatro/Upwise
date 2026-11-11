import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth import current_user
from app.database import get_db
from app.models import Goal
from app.schemas import GoalCreate, GoalProgressUpdate, GoalRead

router = APIRouter(prefix="/goals", tags=["goals"])


@router.get("", response_model=list[GoalRead])
async def list_goals(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Goal).where(Goal.user_id == user["id"]).order_by(Goal.created_at.desc()))
    return result.scalars().all()


@router.post("", response_model=GoalRead, status_code=201)
async def create_goal(payload: GoalCreate, user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    goal = Goal(user_id=user["id"], **payload.model_dump())
    db.add(goal)
    await db.commit()
    await db.refresh(goal)
    return goal


@router.patch("/{goal_id}/progress", response_model=GoalRead)
async def update_goal_progress(goal_id: uuid.UUID, payload: GoalProgressUpdate, user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Goal).where(Goal.id == goal_id, Goal.user_id == user["id"]))
    goal = result.scalar_one_or_none()
    if goal is None:
        raise HTTPException(status_code=404, detail="Goal not found")
    goal.progress = payload.progress
    await db.commit()
    await db.refresh(goal)
    return goal


@router.delete("/{goal_id}", status_code=204)
async def delete_goal(goal_id: uuid.UUID, user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Goal).where(Goal.id == goal_id, Goal.user_id == user["id"]))
    goal = result.scalar_one_or_none()
    if goal is None:
        raise HTTPException(status_code=404, detail="Goal not found")
    await db.delete(goal)
    await db.commit()
