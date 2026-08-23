FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir kopf==1.37.5 kubernetes==32.0.1
COPY operator.py .
CMD ["kopf", "run", "/app/operator.py", "--verbose"]
