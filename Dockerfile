# Use lightweight Python 3.10 slim base image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install git and cleanup
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy your Lambda handler and requirements
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Set the Lambda handler
CMD ["app.lambda_handler"]
