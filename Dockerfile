# Use AWS Lambda Python 3.10 base image
FROM public.ecr.aws/lambda/python:3.10

# Install system dependencies
RUN yum install -y \
      git \
      tar \
      gzip \
      ca-certificates \
    && yum clean all \
    && rm -rf /var/cache/yum

# Set the working directory
WORKDIR /var/task

# Install Python dependencies first (for better layer caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -f requirements.txt

# Copy application files
COPY app.py ./

# Verify git is working
RUN git --version && \
    echo "Git installed successfully"

# Set the Lambda handler
CMD ["app.lambda_handler"]