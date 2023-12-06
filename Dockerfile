# Dockerfile
# Uses multi-stage builds requiring Docker 17.05 or higher
# See https://docs.docker.com/develop/develop-images/multistage-build/
# 참고: https://github.com/svx/poetry-fastapi-docker

# Creating a python base with shared environment variables
FROM python:3.11-slim AS python-base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    WORKDIR_APP="/app"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# builder-base is used to build dependencies
FROM python-base AS builder-base
RUN buildDeps="build-essential" \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
    && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/*
# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
ENV POETRY_VERSION=1.7.1
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python3 - --version ${POETRY_VERSION} && \
    chmod a+x /opt/poetry/bin/poetry

WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes --only main
RUN poetry export -f requirements.txt --output requirements-test.txt --without-hashes --with test


# dev stage
FROM python-base AS development

ENV FASTAPI_ENV=dev
COPY --from=builder-base  ${PYSETUP_PATH} ${PYSETUP_PATH}
RUN pip install -r ${PYSETUP_PATH}/requirements.txt

WORKDIR $WORKDIR_APP
COPY . .

EXPOSE 8000
CMD ["uvicorn", "--reload", "--host=0.0.0.0", "--port=8000", "app.main:app"]

# Test stage
FROM development AS test

ENV FASTAPI_ENV=test
RUN pip install -r ${PYSETUP_PATH}/requirements-test.txt

WORKDIR $WORKDIR_APP
COPY . .

ENTRYPOINT ["pytest", "--cov-report", "term-missing"]


# prod
FROM python-base AS production
ENV FASTAPI_ENV=prod

COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY gunicorn_conf.py /gunicorn_conf.py

# Create user with the name poetry
RUN groupadd -g 1000 appuser

COPY --chown=poetry:poetry ./app /app
USER appuser
WORKDIR /app
CMD [ "gunicorn", "--worker-class uvicorn.workers.UvicornWorker", "--config /gunicorn_conf.py", "app.main:app"]