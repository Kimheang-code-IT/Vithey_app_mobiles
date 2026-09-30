FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

COPY pyproject.toml README.md ./
COPY vithey_ai ./vithey_ai
COPY main.py ./

# Pin versions to avoid long pip backtracking on slow networks
RUN pip install --upgrade pip \
    && pip install \
      "openai>=1.40,<2" \
      "pydantic>=2.7,<3" \
      "python-dotenv>=1.0,<2" \
      "fastapi>=0.110,<1" \
      "uvicorn[standard]>=0.29,<1" \
      "httpx>=0.27,<1" \
      "PyJWT>=2.8,<3" \
      "psycopg[binary]>=3.1,<4" \
    && pip install --no-deps -e .

EXPOSE 8100

# Worker count is env-driven so the stack can scale without rebuilding.
ENV AI_CORE_WORKERS=1

CMD uvicorn vithey_ai.api.app:create_app --factory --host 0.0.0.0 --port 8100 --workers ${AI_CORE_WORKERS:-1}
