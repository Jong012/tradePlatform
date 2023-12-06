# Creating a python base with shared environment variables
FROM python:3.11-slim AS python-base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=on \
    PYSETUP_PATH="/tmp" \
    WORKDIR_APP="/app"

# builder-base is used to build dependencies
FROM python-base AS builder-base

WORKDIR $PYSETUP_PATH

COPY ./poetry.lock ./pyproject.toml ./
RUN pip install "poetry==1.7.1" poetry-plugin-export
RUN poetry export -f requirements.txt --output $PYSETUP_PATH/requirements.txt --without-hashes --only main
RUN poetry export -f requirements.txt --output $PYSETUP_PATH/requirements-test.txt --without-hashes --with test

# create and set non-root USER


# Test stage
FROM python-base AS test

WORKDIR $WORKDIR_APP

COPY --from=builder-base $PYSETUP_PATH/requirements-test.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r  requirements-test.txt

COPY . .

ENTRYPOINT ["pytest", "--cov-report", "term-missing"]

# dev stage
FROM python-base AS dev

WORKDIR $WORKDIR_APP

COPY --from=builder-base  $PYSETUP_PATH/requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

COPY . .
CMD ["uvicorn", "--reload", "--host=0.0.0.0", "--port=8000", "app.main:app"]


# prod stage
FROM python-base AS prod

WORKDIR $WORKDIR_APP

RUN adduser -u 5678 --disabled-password --gecos "" appuser && \
    chown -R appuser /app

# 유저 설정
USER appuser

COPY --from=builder-base  $PYSETUP_PATH/requirements.txt .


RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY gunicorn_conf.py /gunicorn_conf.py
COPY . .

CMD [ "gunicorn", "--worker-class uvicorn.workers.UvicornWorker", "--config /gunicorn_conf.py", "app.main:app"]