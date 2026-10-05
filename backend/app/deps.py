from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Role, User
from app.security import decode_access_token

DbSession = Annotated[Session, Depends(get_db)]

_bearer = HTTPBearer(auto_error=False)


def get_current_user(
    db: DbSession,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> User:
    unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Session expirée ou invalide. Veuillez vous reconnecter.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if credentials is None:
        raise unauthorized
    user_id = decode_access_token(credentials.credentials)
    user = db.get(User, user_id) if user_id is not None else None
    if user is None:
        raise unauthorized
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]


def require_admin(user: CurrentUser) -> User:
    if user.role is not Role.ADMIN:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Accès réservé à l'administrateur.")
    return user


def require_agency(user: CurrentUser) -> User:
    if user.role is not Role.AGENCY or user.agency_id is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Accès réservé aux agences.")
    return user


AdminUser = Annotated[User, Depends(require_admin)]
AgencyUser = Annotated[User, Depends(require_agency)]
