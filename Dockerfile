FROM python:3.11

WORKDIR /app/

COPY liatrio.app/requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    mkdir liatrio


COPY liatrio.app/liatrio liatrio

EXPOSE 5000

CMD ["gunicorn", "--bind", ":5000", "--workers", "3", "liatrio.app:create_app()"]