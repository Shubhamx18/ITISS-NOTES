# Assignment 4: Docker Compose

Check Docker Compose is available: `docker compose version`. Use a separate folder for each question.

---

## Q1. Docker Compose: Nginx Static Website

**Step 1.** Create the project folder and the `website` folder.
```bash
mkdir q1_nginx && cd q1_nginx
mkdir website
```

**Step 2.** Create `website/index.html`.
```html
<h1>Hello from Docker Compose</h1>
```

**Step 3.** Create `docker-compose.yml`.
```yaml
services:
  nginx:
    image: nginx:alpine
    container_name: nginx_web
    ports:
      - "8080:80"
    volumes:
      - ./website:/usr/share/nginx/html
```

**Step 4.** Start the container.
```bash
docker compose up -d
```

**Step 5.** Check it is running.
```bash
docker compose ps
```

**Step 6.** Verify in the browser at `http://localhost:8080`, or from the terminal:
```bash
curl http://localhost:8080
```
Output: `Hello from Docker Compose`

**Step 7.** Stop and remove.
```bash
docker compose down
```

---

## Q2. Docker Compose: Python Script Container

**Step 1.** Create the project folder.
```bash
mkdir q2_python && cd q2_python
```

**Step 2.** Create `app.py`.
```python
print("Hello from Python Container")
```

**Step 3.** Create `Dockerfile`.
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

**Step 4.** Create `docker-compose.yml`.
```yaml
services:
  python-app:
    build: .
    container_name: python_container
```

**Step 5.** Build and run.
```bash
docker compose up --build
```
Output: `Hello from Python Container`. The container runs the script and exits.

**Step 6.** Verify the container exited successfully.
```bash
docker compose ps -a
```
Status shows `Exited (0)`.

**Step 7.** Clean up.
```bash
docker compose down
```

---

## Q3. Docker Compose: MySQL with Volume

**Step 1.** Create the project folder.
```bash
mkdir q3_mysql && cd q3_mysql
```

**Step 2.** Create `docker-compose.yml`.
```yaml
services:
  mysql:
    image: mysql:8
    container_name: mysql_compose
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: testdb
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

**Step 3.** Start the container.
```bash
docker compose up -d
```

**Step 4.** Wait about 20 seconds, then check the logs for `ready for connections`.
```bash
docker compose logs mysql
```

**Step 5.** Enter MySQL using `docker exec`.
```bash
docker exec -it mysql_compose mysql -uroot -proot123
```

**Step 6.** Create the table `test` and insert records.
```sql
USE testdb;
CREATE TABLE test (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO test VALUES (1, 'Asha'), (2, 'Ravi');
SELECT * FROM test;
EXIT;
```

**Step 7.** Restart the container.
```bash
docker compose restart
```

**Step 8.** Wait about 10 seconds and verify the data still exists.
```bash
docker exec -it mysql_compose mysql -uroot -proot123 -e "SELECT * FROM testdb.test;"
```
Both records are present.

**Step 9 (stronger proof).** Remove the container and recreate it. The volume is kept.
```bash
docker compose down
docker compose up -d
```
Wait about 20 seconds and run the command from Step 8 again. The data is still there.

**Step 10.** Clean up. Use `-v` only when you want to delete the volume as well.
```bash
docker compose down -v
```

---

## Q4. Docker Compose: One Volume with 3 Nginx Containers

All three containers mount the same volume at `/usr/share/nginx/html`, so they see the same files. To show different content, the volume holds three pages (`page1.html`, `page2.html`, `page3.html`) and each container is configured to serve a different one.

**Step 1.** Create the project folder structure.
```bash
mkdir q4_nginx && cd q4_nginx
mkdir conf
```

**Step 2.** Create `conf/nginx1.conf`.
```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index page1.html;
}
```

**Step 3.** Create `conf/nginx2.conf`.
```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index page2.html;
}
```

**Step 4.** Create `conf/nginx3.conf`.
```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index page3.html;
}
```

**Step 5.** Create `docker-compose.yml`.
```yaml
services:
  init:
    image: alpine
    container_name: init_content
    volumes:
      - shared-data:/data
    command: >
      sh -c "echo '<h1>Hello from Container 1</h1>' > /data/page1.html &&
             echo '<h1>Hello from Container 2</h1>' > /data/page2.html &&
             echo '<h1>Hello from Container 3</h1>' > /data/page3.html"

  nginx1:
    image: nginx:alpine
    container_name: nginx1
    ports:
      - "8081:80"
    volumes:
      - shared-data:/usr/share/nginx/html
      - ./conf/nginx1.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      init:
        condition: service_completed_successfully

  nginx2:
    image: nginx:alpine
    container_name: nginx2
    ports:
      - "8082:80"
    volumes:
      - shared-data:/usr/share/nginx/html
      - ./conf/nginx2.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      init:
        condition: service_completed_successfully

  nginx3:
    image: nginx:alpine
    container_name: nginx3
    ports:
      - "8083:80"
    volumes:
      - shared-data:/usr/share/nginx/html
      - ./conf/nginx3.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      init:
        condition: service_completed_successfully

volumes:
  shared-data:
    name: shared-data
```
The `init` container writes the three pages into the volume once and exits. The three Nginx containers then start and keep running.

**Step 6.** Start everything.
```bash
docker compose up -d
```

**Step 7.** Confirm nginx1, nginx2 and nginx3 are all running.
```bash
docker compose ps
```

**Step 8.** Verify in the browser:
- `http://localhost:8081` shows `Hello from Container 1`
- `http://localhost:8082` shows `Hello from Container 2`
- `http://localhost:8083` shows `Hello from Container 3`

Or from the terminal:
```bash
curl http://localhost:8081
curl http://localhost:8082
curl http://localhost:8083
```

**Step 9.** Verify all three share the same volume.
```bash
docker volume ls
docker exec nginx1 ls /usr/share/nginx/html
docker exec nginx3 ls /usr/share/nginx/html
```
Both show `page1.html`, `page2.html`, `page3.html`.

**Step 10.** Clean up.
```bash
docker compose down -v
```

---

## Screenshots for Submission

- Q1: browser showing `localhost:8080` and `docker compose ps`
- Q2: `docker compose up --build` output and `docker compose ps -a`
- Q3: `SELECT` output before and after `docker compose restart`
- Q4: `docker compose ps` and the three browser tabs (8081, 8082, 8083)
