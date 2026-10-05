from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.deps import CurrentUser, DbSession
from app.models import User
from app.schemas import LoginIn, Me, TokenOut
from app.security import create_access_token, verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


def _me(user: User) -> Me:
    return Me(
        username=user.username,
        role=user.role,
        agency_id=user.agency_id,
        agency_name=user.agency.name if user.agency else None,
    )


@router.post("/login", response_model=TokenOut)
def login(data: LoginIn, db: DbSession):
    user = db.scalar(select(User).where(User.username == data.username.strip()))
    if user is None or not verify_password(data.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Nom d'utilisateur ou mot de passe incorrect.")
    return TokenOut(access_token=create_access_token(user.id), **_me(user).model_dump())


@router.get("/me", response_model=Me)
def me(user: CurrentUser):
    return _me(user)
