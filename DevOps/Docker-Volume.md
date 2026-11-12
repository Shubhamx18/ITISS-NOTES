# Assignment 3: Docker

Run each question in a fresh terminal folder. Docker must be running (`docker --version` to check).

---

## Q1. Docker Volume Persistence

**Step 1.** Create the volume.
```bash
docker volume create data_vol
```

**Step 2.** Run a container with the volume mounted at `/data`.
```bash
docker run -it --name c1 -v data_vol:/data alpine sh
```

**Step 3.** Inside the container, create a file and exit.
```bash
echo "Hello from data_vol" > /data/test.txt
ls /data
exit
```

**Step 4.** Remove the container.
```bash
docker rm c1
```

**Step 5.** Start a new container with the same volume.
```bash
docker run -it --name c2 -v data_vol:/data alpine sh
```

**Step 6.** Verify the file still exists.
```bash
cat /data/test.txt
exit
```
Output: `Hello from data_vol`. The file survived because the data lives in the volume, not in the container.

**Step 7.** Clean up.
```bash
docker rm c2
```

---

## Q2. Dockerfile: Python Application

**Step 1.** Create a project folder.
```bash
mkdir python_app && cd python_app
```

**Step 2.** Create `app.py`.
```python
print("Hello from Python inside Docker!")
```

**Step 3.** Create `Dockerfile` (no extension).
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

**Step 4.** Build the image.
```bash
docker build -t python-app .
```

**Step 5.** Run the container.
```bash
docker run --rm python-app
```
Output: `Hello from Python inside Docker!`

---

## Q3. Dockerfile: Java Application

**Step 1.** Create a project folder.
```bash
mkdir java_app && cd java_app
```

**Step 2.** Create `Hello.java`.
```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from Java inside Docker!");
    }
}
```

**Step 3.** Create `Dockerfile`.
```dockerfile
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY Hello.java .
RUN javac Hello.java
CMD ["java", "Hello"]
```

**Step 4.** Build the image.
```bash
docker build -t java-app .
```

**Step 5.** Run the container.
```bash
docker run --rm java-app
```
Output: `Hello from Java inside Docker!`

---

## Q4. Docker Volume with MySQL

**Step 1.** Run MySQL with a named volume.
```bash
docker run -d --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -v mysql_data:/var/lib/mysql \
  mysql:8
```

**Step 2.** Wait about 20 seconds for MySQL to start. Check the logs.
```bash
docker logs mysql-db
```
Wait until you see `ready for connections`.

**Step 3.** Open the MySQL shell.
```bash
docker exec -it mysql-db mysql -uroot -proot123
```

**Step 4.** Create the database, table and records.
```sql
CREATE DATABASE school;
USE school;
CREATE TABLE students (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO students VALUES (1, 'Asha'), (2, 'Ravi'), (3, 'Meera');
SELECT * FROM students;
EXIT;
```

**Step 5.** Restart the container.
```bash
docker restart mysql-db
```

**Step 6.** Verify the data persists (wait about 10 seconds after restart).
```bash
docker exec -it mysql-db mysql -uroot -proot123 -e "SELECT * FROM school.students;"
```
All 3 records are still present.

**Step 7 (stronger proof).** Delete the container and start a new one with the same volume.
```bash
docker rm -f mysql-db
docker run -d --name mysql-db2 \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -v mysql_data:/var/lib/mysql \
  mysql:8
```
After about 20 seconds, run the SELECT from Step 6 using `mysql-db2`. The data is still there.

---

## Q5. Dockerfile: Nginx Web Server

**Step 1.** Create a project folder.
```bash
mkdir nginx_app && cd nginx_app
```

**Step 2.** Create `index.html`.
```html
<!DOCTYPE html>
<html>
<head>
  <title>My Nginx Page</title>
</head>
<body>
  <h1>Hello from Nginx in Docker!</h1>
  <p>This is my custom HTML page.</p>
</body>
</html>
```

**Step 3.** Create `Dockerfile`.
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

**Step 4.** Build the image.
```bash
docker build -t my-nginx .
```

**Step 5.** Run the container, mapping host port 8080 to container port 80.
```bash
docker run -d --name web -p 8080:80 my-nginx
```

**Step 6.** Verify in the browser at `http://localhost:8080`, or from the terminal:
```bash
curl http://localhost:8080
```

**Step 7.** Clean up.
```bash
docker rm -f web
```

---

## Q6. Bind Mount vs Volume

**Step 1.** Create a host directory with a file.
```bash
mkdir ~/host_dir
echo "File created on host" > ~/host_dir/host.txt
```

**Step 2.** Run a container with a bind mount.
```bash
docker run -it --name bind_c -v ~/host_dir:/data alpine sh
```

**Step 3.** Inside the container, read the host file and create a new one.
```bash
cat /data/host.txt
echo "Created from container" > /data/container.txt
exit
```

**Step 4.** Check on the host. Both files are visible.
```bash
ls ~/host_dir
cat ~/host_dir/container.txt
```

**Step 5.** Now the same with a Docker volume.
```bash
docker volume create demo_vol
docker run -it --name vol_c -v demo_vol:/data alpine sh
```
Inside:
```bash
echo "Created in volume" > /data/vol.txt
exit
```

**Step 6.** Try to find the volume data on the host. It is not in any normal folder you created.
```bash
docker volume inspect demo_vol
```
The `Mountpoint` is under Docker's own storage area (`/var/lib/docker/volumes/...`), managed by Docker.

**Step 7.** Clean up.
```bash
docker rm bind_c vol_c
```

### Difference

| Point | Bind Mount | Volume |
|---|---|---|
| Location | Any host path you choose (`~/host_dir`) | Inside Docker's storage area, managed by Docker |
| Created by | You (host directory must exist or is created by Docker) | `docker volume create` or automatically by Docker |
| Syntax | `-v /host/path:/container/path` | `-v volume_name:/container/path` |
| Host dependency | Depends on host folder structure | Independent of host folder structure |
| Management | Manual (normal file operations) | Docker commands (`docker volume ls`, `inspect`, `rm`) |
| Best for | Development, sharing source code or config files with a container | Databases and persistent application data, backups, production |
| Portability | Less portable (path must exist on every host) | More portable |

---

## Q7. Dockerfile: Shell Script Execution

**Step 1.** Create a project folder.
```bash
mkdir script_app && cd script_app
```

**Step 2.** Create `script.sh`.
```sh
#!/bin/sh
echo "Hello from a shell script inside Docker!"
echo "Current system date: $(date)"
```

**Step 3.** Create `Dockerfile`.
```dockerfile
FROM alpine
WORKDIR /app
COPY script.sh .
RUN chmod +x script.sh
CMD ["./script.sh"]
```

**Step 4.** Build the image.
```bash
docker build -t script-app .
```

**Step 5.** Run the container.
```bash
docker run --rm script-app
```
Output: the message and the current date.

---

## Q8. Shared Volume Between Containers

**Step 1.** Create the shared volume.
```bash
docker volume create shared_vol
```

**Step 2.** Start container 1 (writer) and keep it running.
```bash
docker run -d --name writer -v shared_vol:/shared alpine sh -c "echo 'Data written by writer' > /shared/shared.txt && sleep 3600"
```

**Step 3.** Start container 2 (reader) with the same volume and read the data.
```bash
docker run --rm --name reader -v shared_vol:/shared alpine cat /shared/shared.txt
```
Output: `Data written by writer`

**Step 4.** Write data from the second container.
```bash
docker run --rm -v shared_vol:/shared alpine sh -c "echo 'Data written by reader' >> /shared/shared.txt"
```

**Step 5.** Read it back from the first container (still running).
```bash
docker exec writer cat /shared/shared.txt
```
Output shows both lines, proving both containers share the same data.

**Step 6.** Clean up.
```bash
docker rm -f writer
```

---

## Final Cleanup (Optional)

```bash
docker rm -f $(docker ps -aq)
docker volume rm data_vol mysql_data demo_vol shared_vol
```

---

## Screenshots for Submission

- Q1: `cat /data/test.txt` output in the new container
- Q2, Q3, Q7: `docker build` and `docker run` output
- Q4: `SELECT` output before and after restart
- Q5: browser showing the page at `localhost:8080`
- Q6: `ls ~/host_dir` and `docker volume inspect demo_vol`
- Q8: output of reader and `docker exec writer cat /shared/shared.txt`
