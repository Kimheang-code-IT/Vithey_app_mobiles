"""Flutter contract routes under /api/v1/ai/**."""

from __future__ import annotations

import asyncio
import json
import uuid
from typing import Any

from fastapi import APIRouter, Body, Query, Request
from fastapi.responses import Response, StreamingResponse
from pydantic import BaseModel, Field

from ..chat_service import ChatService, chunk_reply
from ..chat_stubs import stub_reply
from ..cv_app_service import CvAppService
from .auth import UserDep
from .flutter_envelope import fail, ok, page_meta

flutter_router = APIRouter(prefix="/api/v1/ai", tags=["flutter-ai"])


class ChatBody(BaseModel):
    message: str = Field(min_length=1)
    topic: str | None = None
    session_id: uuid.UUID | None = None
    client_message_id: str | None = None


class CvGenerateBody(BaseModel):
    target_role: str | None = None
    language: str | None = "en"
    template_id: str | None = None


class CvSuggestBody(BaseModel):
    section: str = Field(min_length=1)
    original_text: str = Field(min_length=1)
    cv_file_id: str | None = None


def _chat(request: Request) -> ChatService:
    return request.app.state.chat_service


def _cv(request: Request) -> CvAppService:
    return request.app.state.cv_app_service


@flutter_router.post("/chat")
def chat(request: Request, user: UserDep, body: ChatBody):
    try:
        data = _chat(request).chat(
            user.user_id, body.message, body.topic, body.session_id
        )
        return ok(data)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))
    except ValueError as exc:
        return fail(400, "VALIDATION_ERROR", str(exc))
    except Exception as exc:
        return fail(502, "UPSTREAM_ERROR", str(exc))


@flutter_router.post("/chat/stream")
async def chat_stream(request: Request, user: UserDep, body: ChatBody):
    chat_svc = _chat(request)
    request_id = chat_svc.registry.register(user.user_id)

    async def event_gen():
        try:
            prepared = await asyncio.to_thread(
                chat_svc.prepare_stream_turn,
                user.user_id,
                body.message,
                body.topic,
                body.session_id,
            )
            meta = {
                "request_id": str(request_id),
                "session_id": str(prepared["session_id"]),
                "user_message_id": str(prepared["user_message_id"]),
                "topic": prepared["topic"],
            }
            yield _sse("meta", json.dumps(meta))

            reply = stub_reply(prepared["topic"], body.message)
            streamed = []
            cancelled = False
            for chunk in chunk_reply(reply):
                if chat_svc.registry.is_cancelled(request_id):
                    cancelled = True
                    break
                streamed.append(chunk)
                yield _sse("token", chunk)
                await asyncio.sleep(0.02)

            final = "".join(streamed) if streamed else ("" if cancelled else reply)
            assistant_id = None
            if final or not cancelled:
                assistant_id = await asyncio.to_thread(
                    chat_svc.complete_stream_turn, prepared, final or reply
                )
            done = {
                "request_id": str(request_id),
                "session_id": str(prepared["session_id"]),
                "message_id": str(assistant_id) if assistant_id else None,
                "cancelled": cancelled,
            }
            yield _sse("done", json.dumps(done))
        except Exception as exc:
            yield _sse(
                "error",
                json.dumps({"code": "UPSTREAM_ERROR", "message": str(exc)}),
            )
        finally:
            chat_svc.registry.mark_done(request_id)

    return StreamingResponse(event_gen(), media_type="text/event-stream")


@flutter_router.post("/messages/{message_id}/regenerate")
def regenerate(request: Request, user: UserDep, message_id: uuid.UUID):
    try:
        data = _chat(request).regenerate(user.user_id, message_id)
        return ok(data)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))
    except ValueError as exc:
        return fail(400, "VALIDATION_ERROR", str(exc))


@flutter_router.delete("/chat/requests/{request_id}", status_code=204)
def cancel_request(request: Request, user: UserDep, request_id: uuid.UUID):
    try:
        _chat(request).cancel(user.user_id, request_id)
        return Response(status_code=204)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))


@flutter_router.get("/sessions")
def list_sessions(
    request: Request,
    user: UserDep,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    data, total = _chat(request).list_sessions(user.user_id, page, limit)
    return ok(data, page_meta(page, limit, total))


@flutter_router.get("/sessions/{session_id}/messages")
def list_messages(
    request: Request,
    user: UserDep,
    session_id: uuid.UUID,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    try:
        data, total = _chat(request).list_messages(
            user.user_id, session_id, page, limit
        )
        return ok(data, page_meta(page, limit, total))
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))


@flutter_router.delete("/sessions/{session_id}", status_code=204)
def delete_session(request: Request, user: UserDep, session_id: uuid.UUID):
    try:
        _chat(request).delete_session(user.user_id, session_id)
        return Response(status_code=204)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))


@flutter_router.post("/cv/generate")
def cv_generate(
    request: Request,
    user: UserDep,
    body: CvGenerateBody | None = Body(default=None),
):
    body = body or CvGenerateBody()
    authorization = request.headers.get("Authorization")
    data = _cv(request).generate(
        user.user_id,
        authorization,
        body.target_role,
        body.language,
        body.template_id,
    )
    return ok(data)


@flutter_router.post("/cv/suggest")
def cv_suggest(request: Request, user: UserDep, body: CvSuggestBody):
    data = _cv(request).suggest(
        user.user_id, body.section, body.original_text, body.cv_file_id
    )
    return ok(data)


def _sse(event: str, data: str) -> str:
    # token events are plain text; others are JSON
    return f"event: {event}\ndata: {data}\n\n"
