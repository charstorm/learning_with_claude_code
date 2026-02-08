FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY hello_world.py .

EXPOSE 8000

CMD ["uvicorn", "hello_world:app", "--host", "0.0.0.0", "--port", "8000"]
