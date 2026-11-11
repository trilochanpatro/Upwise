import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth import current_user
from app.database import get_db
from app.models import Goal, Task
from app.schemas import TaskCompletionUpdate, TaskCreate, TaskRead

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.get("", response_model=list[TaskRead])
async def list_tasks(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Task).where(Task.user_id == user["id"]).order_by(Task.created_at.desc()))
    return result.scalars().all()


@router.post("", response_model=TaskRead, status_code=201)
async def create_task(payload: TaskCreate, user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    data = payload.model_dump()
    if data["goal_id"] is not None:
        result = await db.execute(select(Goal).where(Goal.id == data["goal_id"], Goal.user_id == user["id"]))
        if result.scalar_one_or_none() is None:
            raise HTTPException(status_code=404, detail="Goal not found")
    task = Task(user_id=user["id"], **data)
    db.add(task)
    await db.commit()
    await db.refresh(task)
    return task


@router.patch("/{task_id}/completion", response_model=TaskRead)
async def update_task_completion(task_id: uuid.UUID, payload: TaskCompletionUpdate, user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Task).where(Task.id == task_id, Task.user_id == user["id"]))
    task = result.scalar_one_or_none()
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    task.is_completed = payload.is_completed
    await db.commit()
    await db.refresh(task)
    return task


@router.delete("/{task_id}", status_code=204)
async def delete_task(task_id: uuid.UUID, user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Task).where(Task.id == task_id, Task.user_id == user["id"]))
    task = result.scalar_one_or_none()
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    await db.delete(task)
    await db.commit()
