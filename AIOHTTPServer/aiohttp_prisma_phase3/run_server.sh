#How to run the server:
#1. Build the docker image
docker compose build

#2. Run the server in the background
docker-compose up -d 

#3. Generate Prisma Client
docker-compose exec web npx prisma generate

#4. Apply he migrations to create the Item table
docker-compose exec web npx prisma migrate dev --name init

#5. Insert seed data to database
docker-compose exec web python seed.py
