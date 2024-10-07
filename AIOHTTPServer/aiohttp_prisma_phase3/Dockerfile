# Use official Python image from the Docker Hub
FROM python:3.11

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Copy the requirements file to the container
COPY app/requirements.txt .

# Install the required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code to the container
COPY app/ .

# Install the Prisma Client using npm
RUN apt-get install -y curl 
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - 
RUN apt-get install -y nodejs 
RUN apt-get install -y npm 
#RUN npm install -g prisma 
RUN prisma generate

# Expose the port the Aiohttp app runs on
EXPOSE 8080

# Start the Aiohttp app
CMD ["python", "aiohttp_prisma_server.py"]

