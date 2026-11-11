import uuid
from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class ProfileUpsert(BaseModel):
    life_stage: str = Field(default="", max_length=120)
    primary_goal_area: str = Field(default="", max_length=120)
    daily_time_commitment: str = Field(default="", max_length=120)
    preferred_style: str = Field(default="", max_length=120)
    additional_context: str | None = Field(default=None, max_length=2000)
    is_completed: bool = False


class ProfileRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    user_id: str
    life_stage: str
    primary_goal_area: str
    daily_time_commitment: str
    preferred_style: str
    additional_context: str | None
    is_completed: bool
    updated_at: datetime


class GoalCreate(BaseModel):
    title: str = Field(min_length=1, max_length=180)
    description: str | None = Field(default=None, max_length=4000)
    category: str = Field(default="personal", max_length=40)


class GoalRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    title: str
    description: str | None
    category: str
    progress: float
    is_archived: bool
    created_at: datetime


class GoalProgressUpdate(BaseModel):
    progress: float = Field(ge=0, le=100)


class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=180)
    description: str | None = Field(default=None, max_length=4000)
    category: str = Field(default="personal", max_length=40)
    estimated_minutes: int = Field(default=25, ge=5, le=480)
    priority: str = Field(default="medium", pattern="^(low|medium|high)$")
    goal_id: uuid.UUID | None = None


class TaskRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    title: str
    description: str | None
    category: str
    estimated_minutes: int
    priority: str
    is_completed: bool
    goal_id: uuid.UUID | None
    created_at: datetime


class TaskCompletionUpdate(BaseModel):
    is_completed: bool


class ProposedTask(BaseModel):
    title: str
    description: str | None = None
    category: str = "Personal"
    estimated_minutes: int = 25
    priority: str = "medium"


class CoachRequest(BaseModel):
    message: str = Field(min_length=1, max_length=6000)


class CoachResponse(BaseModel):
    id: uuid.UUID
    reply: str
    mode: str
    proposed_task: ProposedTask | None = None
    created_at: datetime


class ChatMessageRead(BaseModel):
    id: uuid.UUID
    is_user: bool
    text: str
    mode: str
    proposed_task: ProposedTask | None = None
    created_at: datetime


class DailyInsightResponse(BaseModel):
    insight: str
    focus_task_title: str | None = None
    mode: str
