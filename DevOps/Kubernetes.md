# Assignment 6: Kubernetes

This guide uses a local **kind** cluster. Commands marked with a note are specific to kind (port mapping, loading images, LoadBalancer).

---

## Setup: Create the Cluster

**Step 1.** Create `kind-config.yaml`. It maps two ports from the node to your machine so NodePort services open in the browser at `localhost`.
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 30080
        protocol: TCP
      - containerPort: 30081
        hostPort: 30081
        protocol: TCP
```

**Step 2.** Create the cluster.
```bash
kind create cluster --name k8s-lab --config kind-config.yaml
```

**Step 3.** Verify.
```bash
kubectl cluster-info --context kind-k8s-lab
kubectl get nodes
```
The node should show `Ready`.

---

## Q1. Run Apache Pod

**Step 1.** Create the pod.
```bash
kubectl run apache-pod --image=httpd
```

**Step 2.** Verify the pod (wait until `STATUS` is `Running`).
```bash
kubectl get pods
```

**Step 3.** Describe the pod.
```bash
kubectl describe pod apache-pod
```
Check `Image: httpd`, `Status: Running`, and the events at the bottom.

**Step 4.** Delete the pod to keep the cluster clean.
```bash
kubectl delete pod apache-pod
```

---

## Q2. Apache Deployment

**Step 1.** Create the deployment.
```bash
kubectl create deployment apache-deployment --image=httpd
```

**Step 2.** Verify the deployment.
```bash
kubectl get deployments
```

**Step 3.** Verify the pod created by the deployment.
```bash
kubectl get pods
```
The pod name looks like `apache-deployment-<hash>-<id>`.

---

## Q3. Increase and Decrease Replicas

**Step 1.** Scale up to 4.
```bash
kubectl scale deployment apache-deployment --replicas=4
```

**Step 2.** Verify the ReplicaSet and pods.
```bash
kubectl get rs
kubectl get pods
```
The ReplicaSet shows `DESIRED 4`, `CURRENT 4`, and 4 pods are listed.

**Step 3.** Scale down to 2.
```bash
kubectl scale deployment apache-deployment --replicas=2
```

**Step 4.** Verify the changes.
```bash
kubectl get rs
kubectl get pods
```
The ReplicaSet shows `DESIRED 2`. Extra pods may show `Terminating` for a few seconds, then only 2 remain.

---

## Q4. Use YAML File

**Step 1.** Delete the deployment from Q2. Its selector differs from the YAML below, and a selector cannot be changed on an existing deployment.
```bash
kubectl delete deployment apache-deployment
```

**Step 2.** Create `apache-deployment.yaml`.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
  labels:
    app: apache
spec:
  replicas: 3
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
        - name: apache
          image: httpd
          ports:
            - containerPort: 80
```

**Step 3.** Apply it.
```bash
kubectl apply -f apache-deployment.yaml
```

**Step 4.** Optional: create `apache-pod.yaml` for the Pod configuration.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache-pod-yaml
  labels:
    app: apache-single
spec:
  containers:
    - name: apache
      image: httpd
      ports:
        - containerPort: 80
```

**Step 5.** Optional: create `apache-rs.yaml` for the ReplicaSet configuration.
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: apache-rs
spec:
  replicas: 2
  selector:
    matchLabels:
      app: apache-rs
  template:
    metadata:
      labels:
        app: apache-rs
    spec:
      containers:
        - name: apache
          image: httpd
```

**Step 6.** Apply the optional files.
```bash
kubectl apply -f apache-pod.yaml
kubectl apply -f apache-rs.yaml
```

**Step 7.** Verify all resources.
```bash
kubectl get deployments,rs,pods
```
The deployment shows `3/3` ready. The Pod and ReplicaSet appear alongside it.

**Step 8.** Remove the optional resources. The deployment stays for the next questions.
```bash
kubectl delete -f apache-pod.yaml
kubectl delete -f apache-rs.yaml
```

---

## Q5. ClusterIP Service

**Step 1.** Create the service.
```bash
kubectl expose deployment apache-deployment --name=apache-clusterip --type=ClusterIP --port=80 --target-port=80
```

**Step 2.** Verify the service and its endpoints.
```bash
kubectl get svc apache-clusterip
kubectl get endpoints apache-clusterip
```
The service has a `CLUSTER-IP` and no `EXTERNAL-IP`. The endpoints list 3 pod IPs.

**Step 3.** Test access from inside the cluster using a temporary pod.
```bash
kubectl run test-pod --rm -it --image=busybox --restart=Never -- wget -qO- http://apache-clusterip
```
Output: `<html><body><h1>It works!</h1></body></html>`

---

## Q6. NodePort Service

**Step 1.** Create `apache-nodeport.yaml`. The fixed `nodePort: 30080` matches the port mapped in the kind config.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-nodeport
spec:
  type: NodePort
  selector:
    app: apache
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

**Step 2.** Apply it.
```bash
kubectl apply -f apache-nodeport.yaml
```

**Step 3.** Verify.
```bash
kubectl get svc apache-nodeport
```
`PORT(S)` shows `80:30080/TCP`.

**Step 4.** Open the browser at `http://localhost:30080`. The page shows `It works!`

**Step 5.** Get the node IP for the `http://<node-ip>:<node-port>` form.
```bash
kubectl get nodes -o wide
```
Use the `INTERNAL-IP` value. On Linux, `http://<INTERNAL-IP>:30080` works directly. On Mac or Windows with Docker Desktop, the node IP is not reachable from the host, so use `localhost`.

---

## Q7. LoadBalancer Service

**Step 1.** Create the service.
```bash
kubectl expose deployment apache-deployment --name=apache-loadbalancer --type=LoadBalancer --port=80 --target-port=80
```

**Step 2.** Verify the external IP.
```bash
kubectl get svc
```
On a plain kind cluster, `EXTERNAL-IP` shows `<pending>`. kind has no cloud provider to allocate load balancer IPs, so this is expected.

**Step 3.** To get a real external IP, run `cloud-provider-kind` in a separate terminal and keep it running.
```bash
go install sigs.k8s.io/cloud-provider-kind@latest
sudo $(go env GOPATH)/bin/cloud-provider-kind
```

**Step 4.** Check again in the first terminal.
```bash
kubectl get svc apache-loadbalancer
```
`EXTERNAL-IP` now shows an address. Open `http://<EXTERNAL-IP>` in the browser or run `curl http://<EXTERNAL-IP>`.

---

## Q8. Flask Application Deployment

**Step 1.** Create a project folder.
```bash
mkdir flask_k8s && cd flask_k8s
```

**Step 2.** Create `app.py`. Use your own PRN and name.
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>PRN: 12345678</h1><h2>Name: Your Name</h2>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**Step 3.** Create `requirements.txt`.
```
flask
```

**Step 4.** Create `Dockerfile`.
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

**Step 5.** Build the image.
```bash
docker build -t flask-app:v1 .
```

**Step 6.** Load the image into the kind cluster. kind nodes cannot see your local Docker images otherwise.
```bash
kind load docker-image flask-app:v1 --name k8s-lab
```

**Step 7.** Create `flask-k8s.yaml` with the Deployment and Service.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      containers:
        - name: flask-container
          image: flask-app:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  type: NodePort
  selector:
    app: flask
  ports:
    - port: 80
      targetPort: 5000
      nodePort: 30081
```

**Step 8.** Apply it.
```bash
kubectl apply -f flask-k8s.yaml
```

**Step 9.** Verify.
```bash
kubectl get deployments,pods,svc
```
Both pods should show `Running`.

**Step 10.** Open the browser at `http://localhost:30081`. The page shows the PRN and name.

---

## Q9. Rolling Update Flask Application

**Step 1.** Modify `app.py` to include the course name.
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>PRN: 12345678</h1><h2>Name: Your Name</h2><h3>Course: PG-DevOps</h3>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**Step 2.** Build the new image version.
```bash
docker build -t flask-app:v2 .
```

**Step 3.** Load it into the cluster.
```bash
kind load docker-image flask-app:v2 --name k8s-lab
```

**Step 4.** Update the deployment with the new image.
```bash
kubectl set image deployment/flask-deployment flask-container=flask-app:v2
```

**Step 5.** Verify the rolling update.
```bash
kubectl rollout status deployment/flask-deployment
```
Output: `deployment "flask-deployment" successfully rolled out`

**Step 6.** Check the pods and revision history. Old pods are replaced one by one, so the app stays available.
```bash
kubectl get pods
kubectl rollout history deployment/flask-deployment
```

**Step 7.** Refresh `http://localhost:30081`. The page now shows PRN, Name and Course.

**Step 8.** Optional: roll back to the previous version.
```bash
kubectl rollout undo deployment/flask-deployment
```

---

## Cleanup

```bash
kubectl delete -f flask-k8s.yaml
kubectl delete -f apache-nodeport.yaml
kubectl delete svc apache-clusterip apache-loadbalancer
kubectl delete -f apache-deployment.yaml
kind delete cluster --name k8s-lab
```

---

## Screenshots for Submission

- Q1: `kubectl get pods` and `kubectl describe pod apache-pod`
- Q2: `kubectl get deployments` and `kubectl get pods`
- Q3: `kubectl get rs` and `kubectl get pods` after scaling to 4 and to 2
- Q4: `kubectl apply -f apache-deployment.yaml` and `kubectl get deployments,rs,pods`
- Q5: `kubectl get svc` and the busybox `wget` output
- Q6: `kubectl get svc` and browser at `localhost:30080`
- Q7: `kubectl get svc` showing the EXTERNAL-IP
- Q8: `kubectl get deployments,pods,svc` and browser output
- Q9: `kubectl rollout status` output and browser showing the updated page
