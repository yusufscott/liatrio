FROM python:3.11

WORKDIR /app/

COPY liatrio.app/requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY liatrio.app/liatrio .

EXPOSE 5000

CMD [ "flask", "run", "--host=0.0.0.0" ]