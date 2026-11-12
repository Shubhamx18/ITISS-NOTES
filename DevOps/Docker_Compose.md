Assignment 4

Q1. Docker Compose: Nginx Static Website
Question
Create a Docker Compose setup to run an Nginx container that serves a
custom HTML page.
Requirements
1. Create a folder named website
2. Create a file index.html with content:

Hello from Docker Compose
3. Use Docker Compose to:
Run an Nginx container
Map port 8080 to 80
Mount website folder to /usr/share/nginx/html
4. Open browser and verify output

Q2. Docker Compose: Python Script Container
Question
Run a simple Python script using Docker Compose.
Requirements
1. Create a file app.py: print("Hello from Python Container")
2. Create a Dockerfile to run this script
3. Use Docker Compose to run this container
4. Container should execute script and exit

Assignment 4 1

Q3. Docker Compose: MySQL with Volume
Question
Create a MySQL container using Docker Compose with persistent storage.
Requirements
1. Use MySQL image
2. Set:
root password
database name
3. Create a named volume
4. Start container and:
Enter MySQL using docker exec
Create table test
5. Restart container and verify data still exists

Q4. Docker Compose: One Volume with 3 Nginx
Containers
Question
Create a Docker Compose setup using three Nginx containers that share a
single volume but display different HTML content.
Requirements
1. Create one named volume:

shared-data

2. Create three Nginx containers:

nginx1
nginx2

Assignment 4 2

nginx3

3. Attach the same volume to all containers at:

/usr/share/nginx/html

4. Each container should display different HTML content:

nginx1 → Hello from Container 1
nginx2 → Hello from Container 2
nginx3 → Hello from Container 3

5. Expose each container on different ports:

nginx1 → 8081
nginx2 → 8082
nginx3 → 8083

6. Ensure all three containers run simultaneously using Docker Compose.
7. Open browser and verify:

http://localhost:8081
http://localhost:8082
http://localhost:8083

Each port should show different content.
