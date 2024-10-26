# `python-base` sets up all our shared environment variables
FROM python:3.12.2-slim as python-base

# Definição de variáveis de ambiente para Python, Pip e Poetry
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.8.4 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Adiciona os caminhos do Poetry e do ambiente virtual ao PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instala dependências básicas
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
        git  # Adiciona o Git aqui


# Instala o Poetry - respeitando as variáveis de ambiente definidas
RUN curl -sSL https://install.python-poetry.org | python -

# Instala dependências adicionais
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2

# Define o diretório de trabalho para a instalação de dependências do projeto
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Instala as dependências do projeto sem as de desenvolvimento
RUN poetry install --no-dev

# Instala as dependências restantes
RUN poetry install

# Define o diretório de trabalho como /app
WORKDIR /app

# Copia o restante do código para dentro do container
COPY . /app/

# Expõe a porta 8000 para o serviço web
EXPOSE 8000

# Comando para iniciar o servidor Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
