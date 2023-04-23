FROM python:3.11

WORKDIR /app/

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD [ "flask", "--app", "app", "run", "--host=0.0.0.0" ]