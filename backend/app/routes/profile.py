from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth import current_user
from app.database import get_db
from app.models import UserProfile, now_utc
from app.schemas import ProfileRead, ProfileUpsert

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("", response_model=ProfileRead)
async def get_profile(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserProfile).where(UserProfile.user_id == user["id"]))
    profile = result.scalar_one_or_none()
    if profile is None:
        return ProfileRead(
            user_id=user["id"],
            life_stage="",
            primary_goal_area="",
            daily_time_commitment="",
            preferred_style="",
            additional_context=None,
            is_completed=False,
            updated_at=now_utc(),
        )
    return profile


@router.put("", response_model=ProfileRead)
async def upsert_profile(
    payload: ProfileUpsert, user=Depends(current_user), db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(UserProfile).where(UserProfile.user_id == user["id"]))
    profile = result.scalar_one_or_none()
    if profile is None:
        profile = UserProfile(user_id=user["id"], **payload.model_dump())
        db.add(profile)
    else:
        for key, value in payload.model_dump().items():
            setattr(profile, key, value)
        profile.updated_at = now_utc()
    await db.commit()
    await db.refresh(profile)
    return profile


@router.delete("", status_code=204)
async def clear_profile_memory(user=Depends(current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserProfile).where(UserProfile.user_id == user["id"]))
    profile = result.scalar_one_or_none()
    if profile is not None:
        profile.life_stage = ""
        profile.primary_goal_area = ""
        profile.daily_time_commitment = ""
        profile.preferred_style = ""
        profile.additional_context = None
        profile.is_completed = False
        profile.updated_at = now_utc()
        await db.commit()
