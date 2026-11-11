import json
import httpx
from fastapi import APIRouter, Depends
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import current_user
from app.config import settings
from app.database import get_db
from app.models import ChatMessage, Goal, Task, UserProfile
from app.schemas import (
    ChatMessageRead,
    CoachRequest,
    CoachResponse,
    DailyInsightResponse,
    ProposedTask,
)

router = APIRouter(prefix="/coach", tags=["coach"])

BASE_SYSTEM_PROMPT = """You are Upwise AI, a practical and supportive personal growth coach.
Help users clarify goals and translate them into realistic actions.
Account for time, money, skills, responsibilities, and constraints.
Ask a concise clarifying question when important context is missing.
Avoid shame, unrealistic promises, medical diagnosis, and guaranteed financial outcomes.
Do not claim to have created tasks, sent messages, or performed external actions.
When suggesting a concrete next step, provide it in the `proposed_task` JSON field so the user can approve it with one tap.
Respond strictly as valid JSON with keys:
- "reply": string (concise, specific, supportive advice)
- "proposed_task": null OR {"title": string, "description": string, "category": "Career"|"Income"|"Skills"|"Focus"|"Health"|"Personal", "estimated_minutes": int (10-120), "priority": "low"|"medium"|"high"}"""


async def _load_user_context(user_id: str, db: AsyncSession) -> dict:
    profile_res = await db.execute(select(UserProfile).where(UserProfile.user_id == user_id))
    profile = profile_res.scalar_one_or_none()

    goals_res = await db.execute(
        select(Goal)
        .where(Goal.user_id == user_id, Goal.is_archived.is_(False))
        .order_by(Goal.created_at.desc())
        .limit(10)
    )
    goals = goals_res.scalars().all()

    tasks_res = await db.execute(
        select(Task)
        .where(Task.user_id == user_id)
        .order_by(Task.created_at.desc())
        .limit(15)
    )
    tasks = tasks_res.scalars().all()

    history_res = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.user_id == user_id)
        .order_by(ChatMessage.created_at.desc())
        .limit(8)
    )
    recent_history = list(reversed(history_res.scalars().all()))

    return {
        "profile": profile,
        "goals": goals,
        "tasks": tasks,
        "recent_history": recent_history,
    }


def _format_context_summary(ctx: dict) -> str:
    profile: UserProfile | None = ctx["profile"]
    goals: list[Goal] = ctx["goals"]
    tasks: list[Task] = ctx["tasks"]

    parts: list[str] = []
    if profile and profile.is_completed:
        parts.append(
            f"User profile: stage='{profile.life_stage}', priority='{profile.primary_goal_area}', "
            f"daily_capacity='{profile.daily_time_commitment}', style='{profile.preferred_style}'."
        )
    if goals:
        goal_lines = [f"- {g.title} ({g.category}, {round(g.progress)}%)" for g in goals[:5]]
        parts.append("Active goals:\n" + "\n".join(goal_lines))
    pending_tasks = [t for t in tasks if not t.is_completed]
    completed_tasks = [t for t in tasks if t.is_completed]
    if pending_tasks:
        task_lines = [
            f"- {t.title} ({t.category}, {t.estimated_minutes}m, priority={t.priority})"
            for t in pending_tasks[:5]
        ]
        parts.append("Pending tasks:\n" + "\n".join(task_lines))
    parts.append(f"Completed tasks count: {len(completed_tasks)}.")
    return "\n\n".join(parts)


def _deserialize_proposed_task(raw: str | None) -> ProposedTask | None:
    if not raw:
        return None
    try:
        return ProposedTask.model_validate_json(raw)
    except Exception:
        return None


def _smart_coach_reply(message: str, ctx: dict) -> tuple[str, ProposedTask | None]:
    normalized = message.lower()
    profile: UserProfile | None = ctx["profile"]
    goals: list[Goal] = ctx["goals"]
    tasks: list[Task] = ctx["tasks"]
    pending_tasks = [t for t in tasks if not t.is_completed]

    top_goal = goals[0].title if goals else (
        profile.primary_goal_area if profile and profile.primary_goal_area else "your top priority"
    )
    capacity = (
        profile.daily_time_commitment
        if profile and profile.daily_time_commitment
        else "25-30 minutes"
    )

    if any(k in normalized for k in ("overwhelm", "stress", "too much", "stuck", "procrastinat")):
        if pending_tasks:
            first = pending_tasks[0]
            return (
                f"When things feel heavy, shrink the scope to one clear win. You currently have {len(pending_tasks)} open priorities—let's protect just 25 minutes for '{first.title}' and pause everything else for now.\n\nWould a quick reset sprint help you get momentum?",
                ProposedTask(
                    title=f"25-min reset sprint: {first.title[:100]}",
                    description="Single-task focus block without notifications or context switching.",
                    category=first.category or "Focus",
                    estimated_minutes=25,
                    priority="high",
                ),
            )
        return (
            f"When energy is low or everything feels urgent, ruthless simplification works best. Based on your {capacity} capacity, let's pick one 20-minute action toward {top_goal} and ignore the rest until it's done.",
            ProposedTask(
                title="Single 20-minute deep focus block",
                description="Choose one concrete deliverable and work on it without distractions.",
                category="Focus",
                estimated_minutes=20,
                priority="high",
            ),
        )

    if any(k in normalized for k in ("career", "job", "interview", "resume", "portfolio", "skill")):
        return (
            f"Career momentum comes from visible proof-of-work tied to '{top_goal}'. Instead of broad planning, let's carve out a 30-minute block to produce or refine one tangible artifact.\n\nYou can accept the suggested priority below with one tap.",
            ProposedTask(
                title="30-min proof-of-work / skill practice",
                description=f"Focused session advancing {top_goal}.",
                category="Career",
                estimated_minutes=30,
                priority="high",
            ),
        )

    if any(k in normalized for k in ("income", "money", "saving", "budget", "freelance", "revenue")):
        return (
            "Improving income and financial stability works best with small, repeatable weekly steps: audit one recurring expense or reach out to one concrete opportunity.\n\nHere is a realistic 25-minute action you can add to today's plan:",
            ProposedTask(
                title="25-min income & runway check-in",
                description="Identify one high-leverage earning or savings action for this week.",
                category="Income",
                estimated_minutes=25,
                priority="medium",
            ),
        )

    if any(k in normalized for k in ("time", "minute", "free", "priorit", "today", "plan", "win")):
        if pending_tasks:
            top_task = pending_tasks[0]
            return (
                f"Looking at your active database priorities, your strongest next move is '{top_task.title}' ({top_task.estimated_minutes}m, {top_task.category}). Finishing that first keeps momentum aligned with {top_goal}.\n\nWant me to add a short prep or follow-up block as well?",
                None,
            )
        return (
            f"You don't have any open tasks right now—great moment to set one realistic step toward '{top_goal}' within your {capacity} window.",
            ProposedTask(
                title=f"Advance {top_goal[:80]}",
                description="One realistic, self-contained step you can finish today.",
                category="Personal",
                estimated_minutes=25,
                priority="high",
            ),
        )

    goal_note = f" (anchored to '{top_goal}')" if goals or (profile and profile.primary_goal_area) else ""
    return (
        f"Got it—let's turn this into a practical plan{goal_note}. To tailor the next step to your reality:\n\n1. What specific outcome would make today feel successful?\n2. How many uninterrupted minutes can you spare right now?\n\nShare a quick detail, or accept the starter focus block below to build momentum.",
        ProposedTask(
            title="25-min focused execution block",
            description="Dedicated progress session with clear start and stop criteria.",
            category="Focus",
            estimated_minutes=25,
            priority="medium",
        ),
    )


@router.get("/history", response_model=list[ChatMessageRead])
async def get_history(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.user_id == user["id"])
        .order_by(ChatMessage.created_at.asc())
    )
    rows = result.scalars().all()
    return [
        ChatMessageRead(
            id=row.id,
            is_user=row.is_user,
            text=row.text,
            mode=row.mode,
            proposed_task=_deserialize_proposed_task(row.proposed_task_json),
            created_at=row.created_at,
        )
        for row in rows
    ]


@router.delete("/history", status_code=204)
async def clear_history(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    await db.execute(delete(ChatMessage).where(ChatMessage.user_id == user["id"]))
    await db.commit()


async def _call_openai_responses(instructions: str, input_text: str) -> str:
    """Call OpenAI Responses API via httpx to avoid native DLL dependencies."""
    headers = {
        "Authorization": f"Bearer {settings.openai_api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": settings.openai_model,
        "instructions": instructions,
        "input": input_text,
    }
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            "https://api.openai.com/v1/responses",
            headers=headers,
            json=payload,
        )
        resp.raise_for_status()
        data = resp.json()
        if isinstance(data.get("output_text"), str) and data["output_text"]:
            return data["output_text"]
        # Fallback extraction from output message array
        for item in data.get("output", []):
            for part in item.get("content", []):
                if part.get("type") == "output_text" and part.get("text"):
                    return str(part["text"])
        raise ValueError("Empty OpenAI response")


@router.get("/insight", response_model=DailyInsightResponse)
async def daily_insight(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    ctx = await _load_user_context(user["id"], db)
    profile: UserProfile | None = ctx["profile"]
    goals: list[Goal] = ctx["goals"]
    tasks: list[Task] = ctx["tasks"]
    pending = [t for t in tasks if not t.is_completed]
    completed = [t for t in tasks if t.is_completed]

    if settings.openai_api_key:
        try:
            context_summary = _format_context_summary(ctx)
            text = await _call_openai_responses(
                instructions=(
                    "Give a concise 1-2 sentence practical daily coaching insight based on the user's "
                    "profile, goals, and tasks. Be encouraging, specific, and realistic."
                ),
                input_text=context_summary,
            )
            return DailyInsightResponse(
                insight=text.strip(),
                focus_task_title=pending[0].title if pending else None,
                mode="live_ai",
            )
        except Exception:
            pass

    if pending:
        top = pending[0]
        insight = (
            f"Start with '{top.title}' ({top.estimated_minutes}m) while your energy is fresh. "
            f"Completing this moves you forward with {len(completed)} done and {len(pending)} remaining."
        )
        return DailyInsightResponse(
            insight=insight,
            focus_task_title=top.title,
            mode="smart_coach",
        )
    if goals:
        top_goal = goals[0]
        return DailyInsightResponse(
            insight=(
                f"Your top goal '{top_goal.title}' is at {round(top_goal.progress)}%. "
                "Add one 25-minute priority today to keep consistent momentum."
            ),
            focus_task_title=None,
            mode="smart_coach",
        )
    if profile and profile.primary_goal_area:
        return DailyInsightResponse(
            insight=(
                f"Anchor today around '{profile.primary_goal_area}' within your "
                f"{profile.daily_time_commitment or 'daily'} window. Small consistent steps compound quickly."
            ),
            focus_task_title=None,
            mode="smart_coach",
        )
    return DailyInsightResponse(
        insight="Start with one realistic 25-minute priority today. Adjust your plan whenever your schedule shifts.",
        focus_task_title=None,
        mode="smart_coach",
    )


@router.post("/chat", response_model=CoachResponse)
async def chat(
    payload: CoachRequest, user=Depends(current_user), db: AsyncSession = Depends(get_db)
):
    ctx = await _load_user_context(user["id"], db)

    user_msg = ChatMessage(
        user_id=user["id"],
        is_user=True,
        text=payload.message,
        mode="user",
    )
    db.add(user_msg)
    await db.flush()

    reply_text: str
    proposed_task: ProposedTask | None = None
    mode = "smart_coach"

    if settings.openai_api_key:
        try:
            context_summary = _format_context_summary(ctx)
            history_snippet = "\n".join(
                f"{'User' if m.is_user else 'Coach'}: {m.text}"
                for m in ctx["recent_history"]
            )
            full_input = (
                f"Context:\n{context_summary}\n\n"
                f"Recent conversation:\n{history_snippet}\n\n"
                f"User message:\n{payload.message}"
            )
            raw_text = (
                await _call_openai_responses(
                    instructions=BASE_SYSTEM_PROMPT,
                    input_text=full_input,
                )
            ).strip()
            try:
                parsed = json.loads(raw_text)
                reply_text = str(parsed.get("reply") or raw_text)
                if parsed.get("proposed_task"):
                    proposed_task = ProposedTask.model_validate(parsed["proposed_task"])
            except Exception:
                reply_text = raw_text
            mode = "live_ai"
        except Exception:
            # Graceful fallback to context-aware smart coach if OpenAI quota/network fails
            reply_text, proposed_task = _smart_coach_reply(payload.message, ctx)
            mode = "smart_coach"
    else:
        reply_text, proposed_task = _smart_coach_reply(payload.message, ctx)

    ai_msg = ChatMessage(
        user_id=user["id"],
        is_user=False,
        text=reply_text,
        mode=mode,
        proposed_task_json=proposed_task.model_dump_json() if proposed_task else None,
    )
    db.add(ai_msg)
    await db.commit()
    await db.refresh(ai_msg)

    return CoachResponse(
        id=ai_msg.id,
        reply=ai_msg.text,
        mode=ai_msg.mode,
        proposed_task=proposed_task,
        created_at=ai_msg.created_at,
    )
