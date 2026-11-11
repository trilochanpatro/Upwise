import httpx
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from app.config import settings

bearer = HTTPBearer(auto_error=False)


async def current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
) -> dict:
    """Validate the Supabase access token by asking Supabase Auth for its user.

    This avoids trusting unverified client-supplied user IDs. The Flutter app must
    send the Supabase access token as: Authorization: Bearer <access_token>.
    """
    if credentials is None:
        raise HTTPException(status_code=401, detail="Authentication required")

    token = credentials.credentials

    # Development convenience: Allow testing protected endpoints offline when in debug mode
    # with a test token or placeholder credentials.
    if settings.debug and (token == "dev-test-token" or "your-project" in settings.supabase_url):
        return {
            "id": "00000000-0000-0000-0000-000000000001",
            "email": "dev@upwise.local",
            "role": "authenticated",
        }

    headers = {
        "apikey": settings.supabase_anon_key,
        "Authorization": f"Bearer {token}",
    }
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(
                f"{settings.supabase_url.rstrip('/')}/auth/v1/user",
                headers=headers,
            )
        if response.status_code != 200:
            raise HTTPException(status_code=401, detail="Invalid or expired access token")
        user = response.json()
        if not user.get("id"):
            raise HTTPException(status_code=401, detail="Invalid authenticated user")
        return user
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=503, detail="Authentication service unavailable") from exc
