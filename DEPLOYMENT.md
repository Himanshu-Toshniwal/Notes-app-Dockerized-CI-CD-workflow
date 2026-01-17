# 🚀 Deployment Guide

Complete guide for deploying Notes App in different environments.

## 📋 Table of Contents

1. [Local Development](#local-development)
2. [Docker Desktop](#docker-desktop)
3. [Docker Hub](#docker-hub)
4. [Production Deployment](#production-deployment)
5. [Kubernetes](#kubernetes)
6. [Cloud Platforms](#cloud-platforms)

---

## Local Development

### Prerequisites
- Node.js 18+
- MySQL Server installed
- npm or yarn

### Setup

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/Notes-App-CI-CD.git
cd Notes-App-CI-CD

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your MySQL credentials
# DB_PASS=your_mysql_password

# Start MySQL server
# (Instructions depend on your OS)

# Run the app
npm start

# Access at http://localhost:3000
```

### Development with Auto-reload

```bash
npm run dev
```

---

## Docker Desktop

### Build Locally

```bash
# Build image
docker build -t notesapp:latest .

# Verify build
docker images | grep notesapp
```

### Run with Docker Desktop

```bash
# Create Docker network
docker network create notesapp-net

# Run MySQL
docker run -d \
  --name mysql-notes \
  --network notesapp-net \
  -e MYSQL_ROOT_PASSWORD=rootpass123 \
  -e MYSQL_DATABASE=notesdb \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# Run App
docker run -d \
  --name notesapp \
  --network notesapp-net \
  -e DB_HOST=mysql-notes \
  -e DB_USER=root \
  -e DB_PASS=rootpass123 \
  -e DB_NAME=notesdb \
  -p 3000:3000 \
  notesapp:latest

# Check logs
docker logs -f notesapp

# Stop containers
docker stop notesapp mysql-notes
docker rm notesapp mysql-notes
```

### Using Docker Compose

```bash
# Create .env file for compose
cat > .env << EOF
DB_PASS=rootpass123
DB_NAME=notesdb
EOF

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down

# Keep database volume
docker-compose down -v
```

---

## Docker Hub

### Push Image to Docker Hub

```bash
# Login to Docker Hub
docker login
# Enter: himanshutoshniwal7570 (username)
# Enter: <your_personal_access_token>

# Tag image
docker tag notesapp:latest himanshutoshniwal7570/notesapp:latest

# Push to Docker Hub
docker push himanshutoshniwal7570/notesapp:latest

# Verify on Docker Hub
# Visit: https://hub.docker.com/r/himanshutoshniwal7570/notesapp
```

### Pull and Run from Docker Hub

```bash
# Pull image
docker pull himanshutoshniwal7570/notesapp:latest

# Run
docker run -d \
  -p 3000:3000 \
  -e DB_HOST=your_mysql_host \
  -e DB_USER=root \
  -e DB_PASS=your_password \
  himanshutoshniwal7570/notesapp:latest

# Access
open http://localhost:3000
```

---

## Production Deployment

### VPS Deployment (Linux Server)

#### Prerequisites
- Ubuntu 20.04+ or similar
- Docker installed
- Docker Compose installed
- SSH access

#### Steps

```bash
# SSH into server
ssh user@your_server_ip

# Clone repository
git clone https://github.com/YOUR_USERNAME/Notes-App-CI-CD.git
cd Notes-App-CI-CD

# Create production .env
cat > .env << EOF
DB_HOST=mysql
DB_USER=root
DB_PASS=$(openssl rand -base64 32)
DB_NAME=notesdb
PORT=3000
NODE_ENV=production
EOF

# Start with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Create backup of database
docker-compose exec mysql mysqldump -u root -p$DB_PASS notesdb > backup.sql
```

### Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt-get install nginx

# Create Nginx config
sudo nano /etc/nginx/sites-available/notesapp
```

Add this config:

```nginx
server {
    listen 80;
    server_name your_domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

Enable and restart:

```bash
sudo ln -s /etc/nginx/sites-available/notesapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### SSL/TLS Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your_domain.com

# Auto-renewal check
sudo systemctl timer list-timers
```

---

## Kubernetes

### Prerequisites
- Kubernetes cluster (local or cloud)
- kubectl installed
- Docker image on Docker Hub

### Deployment YAML

Create `k8s-deployment.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: notesapp

---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: notesapp
type: Opaque
stringData:
  password: $(openssl rand -base64 32)

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: notesapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        - name: MYSQL_DATABASE
          value: notesdb
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: notesapp
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notesapp
  namespace: notesapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: notesapp
  template:
    metadata:
      labels:
        app: notesapp
    spec:
      containers:
      - name: notesapp
        image: himanshutoshniwal7570/notesapp:latest
        ports:
        - containerPort: 3000
        env:
        - name: DB_HOST
          value: mysql
        - name: DB_USER
          value: root
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        - name: DB_NAME
          value: notesdb
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: notesapp-service
  namespace: notesapp
spec:
  type: LoadBalancer
  selector:
    app: notesapp
  ports:
  - port: 80
    targetPort: 3000

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: notesapp-hpa
  namespace: notesapp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: notesapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Deploy to Kubernetes

```bash
# Apply manifest
kubectl apply -f k8s-deployment.yaml

# Check status
kubectl get pods -n notesapp
kubectl get svc -n notesapp

# View logs
kubectl logs -n notesapp deployment/notesapp

# Port forward for local testing
kubectl port-forward -n notesapp svc/notesapp-service 3000:80
```

---

## Cloud Platforms

### AWS Deployment

#### Using ECS (Elastic Container Service)

```bash
# Create ECR repository
aws ecr create-repository --repository-name notesapp --region us-east-1

# Tag image for ECR
docker tag notesapp:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/notesapp:latest

# Push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/notesapp:latest
```

### Google Cloud (GCP)

```bash
# Configure gcloud
gcloud config set project YOUR_PROJECT_ID

# Push to GCR
docker tag notesapp:latest gcr.io/YOUR_PROJECT_ID/notesapp:latest
docker push gcr.io/YOUR_PROJECT_ID/notesapp:latest

# Deploy to Cloud Run
gcloud run deploy notesapp \
  --image gcr.io/YOUR_PROJECT_ID/notesapp:latest \
  --platform managed \
  --region us-central1 \
  --set-env-vars "DB_HOST=cloudsql-host"
```

### Heroku Deployment

```bash
# Login to Heroku
heroku login

# Create app
heroku create notesapp

# Add MySQL add-on
heroku addons:create cleardb:ignite

# Deploy
git push heroku main

# View logs
heroku logs -t
```

---

## Monitoring & Logging

### Health Checks

```bash
# Check if app is healthy
curl http://localhost:3000/health
# Response: {"status":"healthy","timestamp":"2024-01-17T..."}
```

### Database Monitoring

```bash
# Connect to MySQL
docker exec -it mysql-notes mysql -u root -prootpass123

# View databases
SHOW DATABASES;

# View notes table
USE notesdb;
SELECT COUNT(*) FROM notes;
```

### Container Logs

```bash
# Docker logs
docker logs notesapp

# Docker Compose logs
docker-compose logs app

# Kubernetes logs
kubectl logs -n notesapp deployment/notesapp
```

---

## Backup & Recovery

### Database Backup

```bash
# Backup to SQL file
docker-compose exec mysql mysqldump -u root -p$DB_PASS notesdb > backup.sql

# Backup using Kubernetes
kubectl exec -n notesapp <mysql-pod> -- mysqldump -u root -pPASSWORD notesdb > backup.sql
```

### Database Restore

```bash
# Restore from SQL file
docker-compose exec -T mysql mysql -u root -p$DB_PASS notesdb < backup.sql
```

### Volume Backup

```bash
# Docker volume backup
docker run --rm -v mysql-data:/data -v $(pwd):/backup alpine tar czf /backup/mysql-backup.tar.gz /data
```

---

## Performance Tuning

### Database Optimization

```bash
# Add indexes
ALTER TABLE notes ADD INDEX idx_title (title);
ALTER TABLE notes ADD INDEX idx_created_at (created_at);
```

### Connection Pooling

Already configured in `app.js`:
```javascript
connectionLimit: 10,
queueLimit: 0
```

### Caching Strategy

Consider adding Redis:
```yaml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

---

## Troubleshooting

### Port conflicts

```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Database connection issues

```bash
# Test MySQL connection
docker exec mysql-notes mysql -u root -prootpass123 -e "SHOW DATABASES;"

# Check network connectivity
docker network inspect notesapp-net
```

### Docker image issues

```bash
# Remove old images
docker rmi notesapp:latest

# Rebuild without cache
docker build --no-cache -t notesapp:latest .
```

---

## Continuous Deployment

### Auto-deploy from GitHub

With GitHub Actions (already configured):
1. Every push to `main` triggers build
2. Image is pushed to Docker Hub
3. Manual deploy to production via Kubernetes/Docker

### Manual Deployment Steps

```bash
# Pull latest image
docker pull himanshutoshniwal7570/notesapp:latest

# Update running container
docker-compose down
docker-compose up -d
```

---

**✅ Choose your deployment method above and follow the steps!**
