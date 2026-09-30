"""Auth for Flutter-facing /api/v1/ai/** routes (JWT + gateway X-User headers)."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from typing import Annotated

import jwt
from fastapi import Depends, Header, HTTPException, Request

from ..config import Config


@dataclass(frozen=True)
class CurrentUser:
    user_id: uuid.UUID
    email: str | None
    roles: list[str]


def _parse_roles(raw: str | None) -> list[str]:
    if not raw:
        return []
    return [part.strip() for part in raw.split(",") if part.strip()]


def require_user(
    request: Request,
    authorization: Annotated[str | None, Header()] = None,
    x_user_id: Annotated[str | None, Header(alias="X-User-Id")] = None,
    x_user_email: Annotated[str | None, Header(alias="X-User-Email")] = None,
    x_user_roles: Annotated[str | None, Header(alias="X-User-Roles")] = None,
) -> CurrentUser:
    config: Config = getattr(request.app.state, "config", None) or Config()

    # Prefer gateway identity headers (already validated at the edge).
    if x_user_id:
        try:
            return CurrentUser(
                user_id=uuid.UUID(x_user_id),
                email=x_user_email,
                roles=_parse_roles(x_user_roles),
            )
        except ValueError as exc:
            raise HTTPException(status_code=401, detail="Invalid X-User-Id") from exc

    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Authentication is required")

    token = authorization[7:].strip()
    secret = config.VITHEY_JWT_SECRET
    if not secret:
        raise HTTPException(status_code=401, detail="JWT secret not configured")

    try:
        claims = jwt.decode(
            token,
            secret,
            algorithms=["HS256"],
            options={"require": ["sub"]},
        )
        user_id = uuid.UUID(str(claims["sub"]))
        roles = claims.get("roles") or []
        if isinstance(roles, str):
            roles = [roles]
        return CurrentUser(
            user_id=user_id,
            email=claims.get("email"),
            roles=list(roles),
        )
    except (jwt.PyJWTError, ValueError, KeyError) as exc:
        raise HTTPException(status_code=401, detail="Missing or invalid token") from exc


UserDep = Annotated[CurrentUser, Depends(require_user)]
