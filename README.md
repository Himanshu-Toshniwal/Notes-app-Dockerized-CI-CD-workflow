# 📝 Notes App - Simplified DevOps Edition

A clean **Notes Application** with **Node.js**, **Express.js**, **SQLite**, **Docker**, and **Kubernetes** deployment.

## ✨ Features

### Core Application
- Create, Read, Update, Delete notes
- Real-time UI updates with responsive design
- SQLite database with UUID-based IDs
- RESTful API endpoints with health checks
- Modern UI with error handling

### DevOps & Infrastructure
- **Docker**: Containerization with multi-stage builds
- **Kubernetes**: Basic K8s deployment manifests
- **CI/CD**: GitHub Actions workflow for build and deploy
- **SQLite**: Lightweight database for development

## 🚀 Quick Start

### SQLite Version (Recommended)
```bash
# Install dependencies
npm install

# Run application
npm run start:sqlite
# Access: http://localhost:3000
```

### Docker
```bash
# Run with Docker Compose
docker-compose up --build
# Access: http://localhost:3000
```

### Kubernetes
```bash
# Deploy to K8s cluster
cd k8s
./deploy.sh
```

## 📚 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notes` | Get all notes |
| GET | `/api/notes/:id` | Get single note |
| POST | `/api/notes` | Create new note |
| PUT | `/api/notes/:id` | Update note |
| DELETE | `/api/notes/:id` | Delete note |
| GET | `/health` | Health check |

## 🔧 Available Scripts

- `npm run start:sqlite` - Start SQLite version
- `npm run dev:sqlite` - Development mode with auto-reload
- `npm test` - Test API endpoints

## 📦 Project Structure

```
Notes-app-Dockerized-CI-CD-workflow/
├── app-sqlite.js             # Main SQLite application
├── package.json              # Dependencies and scripts
├── docker-compose.yml        # Docker services
├── Dockerfile               # Container build
├── public/
│   └── index.html           # Frontend UI
├── .github/workflows/       # CI/CD pipeline
│   └── ci-cd.yml           # Main workflow
├── k8s/                     # Kubernetes manifests
│   ├── namespace.yaml      # K8s namespace
│   ├── deployment.yaml     # App deployment
│   ├── service.yaml        # Service exposure
│   └── deploy.sh          # Deployment script
├── .env.sqlite             # Environment config
├── run.sh                  # Quick start script
├── test-api.sh             # API testing
└── README.md               # Documentation
```

## 🔒 Environment Variables

### SQLite Configuration (.env.sqlite)
```env
DB_PATH=./notesdb.sqlite
PORT=3000
NODE_ENV=development
```

### Docker Environment (.env.example)
```env
DB_PATH=/app/data/notesdb.sqlite
PORT=3000
NODE_ENV=production
```

## 🐳 Docker Usage

```bash
# Build and run
docker-compose up --build

# Run in background
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f
```

## 💾 Database Backups

### Automated SQLite Backup
```bash
npm run backup:sqlite
# Creates: ./backups/notesdb_backup_YYYYMMDD_HHMMSS.sqlite.gz
```

### Backup Features
- **Compression**: Gzip compression for space efficiency
- **Timestamping**: Unique timestamps for each backup
- **Automation**: GitHub Actions daily backups
- **Retention**: Configurable backup retention policies
- **Logging**: Detailed backup logs in `backups/backup.log`

### Scheduled Backups
```bash
# Setup automated daily backups
./setup-cron.sh    # Linux/Mac
./setup-cron.bat   # Windows

# Manual backup verification
ls -la backups/
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows (6 Total)

1. **Main CI/CD** (`ci-cd.yml`)
   - Build Docker image with multi-stage optimization
   - Security scanning with Trivy
   - API testing with health checks
   - Database backup testing
   - Push to DockerHub on main branch

2. **Kubernetes Deployment** (`k8s-deploy.yml`)
   - Automated K8s deployment using Kind cluster
   - Namespace isolation and resource management
   - Health check validation and rollback support

3. **Backup Automation** (`backup-automation.yml`)
   - Daily automated backups at 2 AM UTC
   - Backup verification and compression
   - Retention policy enforcement

4. **API Testing** (`api-testing.yml`)
   - Comprehensive endpoint testing
   - Performance and load testing
   - Integration test validation

5. **Security Scanning** (`security-scan.yml`)
   - Daily vulnerability scans
   - Dependency security checks
   - SARIF report generation

6. **Maintenance** (`maintenance.yml`)
   - Cleanup old Docker images
   - Log rotation and optimization
   - Performance monitoring

### Pipeline Features
- **Multi-stage builds** for optimized images
- **Security-first** approach with vulnerability scanning
- **Automated testing** at every stage
- **Zero-downtime deployments** with K8s rolling updates
- **Comprehensive monitoring** and alerting

## ☸️ Kubernetes Deployment

### Production-Ready K8s Setup
```bash
# Deploy to Kubernetes
cd k8s
./deploy.sh

# Check deployment status
kubectl get all -n notes-app

# Access application
kubectl port-forward svc/notes-app-service 3000:3000 -n notes-app
```

### K8s Features
- **Namespace Isolation**: Dedicated `notes-app` namespace
- **High Availability**: 2 replica deployment with HPA
- **Persistent Storage**: PVC for database persistence
- **Resource Management**: CPU/Memory limits and requests
- **Health Monitoring**: Liveness and readiness probes
- **Auto-scaling**: Horizontal Pod Autoscaler (2-10 pods)
- **Ingress Support**: Ready for external traffic routing

### Monitoring & Scaling
```bash
# View pod status
kubectl get pods -n notes-app

# Check HPA status
kubectl get hpa -n notes-app

# View logs
kubectl logs -f deployment/notes-app-deployment -n notes-app

# Scale manually
kubectl scale deployment notes-app-deployment --replicas=3 -n notes-app
```

## 🧪 Testing

### Automated Testing
```bash
# Run comprehensive API tests
npm test

# Test specific endpoints
./test-api.sh

# Health check
curl http://localhost:3000/health
```

### Manual API Testing
```bash
# Get all notes
curl http://localhost:3000/api/notes

# Create new note
curl -X POST http://localhost:3000/api/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Note","content":"This is a test note"}'

# Update note
curl -X PUT http://localhost:3000/api/notes/[note-id] \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated","content":"Updated content"}'

# Delete note
curl -X DELETE http://localhost:3000/api/notes/[note-id]
```

### Load Testing
```bash
# Test concurrent requests
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/notes \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"Load Test $i\",\"content\":\"Testing load\"}" &
done
```

## 🚀 Deployment Options

### 1. Docker Hub (Production Ready)
```bash
# Pull and run latest image
docker pull himanshutoshniwal7570/notesapp:latest
docker run -p 3000:3000 himanshutoshniwal7570/notesapp:latest

# Run with persistent storage
docker run -p 3000:3000 -v $(pwd)/data:/app/data himanshutoshniwal7570/notesapp:latest
```

### 2. Local Development
```bash
# Clone repository
git clone <repository-url>
cd Notes-app-Dockerized-CI-CD-workflow

# Install dependencies
npm install

# Start development server
npm run dev:sqlite
```

### 3. Production Kubernetes
```bash
# Deploy to production K8s cluster
kubectl apply -f k8s/

# Verify deployment
kubectl get all -n notes-app

# Access via LoadBalancer or Ingress
kubectl get ingress -n notes-app
```

### 4. GitHub Actions Auto-Deploy
- Push to `main` branch triggers automatic deployment
- Includes security scanning, testing, and K8s deployment
- Zero-downtime rolling updates with health checks

## 🔐 Security Features

### Built-in Security
- **Vulnerability Scanning**: Daily Trivy scans for container security
- **Dependency Checks**: Automated security updates via GitHub Actions
- **Resource Limits**: K8s resource constraints prevent resource exhaustion
- **Health Monitoring**: Liveness/readiness probes for reliability
- **Input Validation**: Sanitized API inputs and error handling

### Security Best Practices
- Non-root container execution
- Multi-stage Docker builds for minimal attack surface
- Secrets management via K8s secrets and GitHub secrets
- Network policies for pod-to-pod communication
- Regular security updates via automated workflows

## 📊 Monitoring & Observability

### Application Monitoring
```bash
# Health check endpoint
curl http://localhost:3000/health

# Application metrics
kubectl top pods -n notes-app

# View application logs
kubectl logs -f deployment/notes-app-deployment -n notes-app
```

### Performance Metrics
- **Response Time**: API endpoint performance tracking
- **Resource Usage**: CPU/Memory monitoring via K8s metrics
- **Auto-scaling**: HPA based on CPU utilization (70% threshold)
- **Backup Status**: Automated backup success/failure tracking

## 🛠️ Development Workflow

### Local Development
1. **Setup**: `npm install` and `npm run dev:sqlite`
2. **Testing**: `npm test` for API validation
3. **Backup**: `npm run backup:sqlite` for data safety
4. **Docker**: `docker-compose up` for containerized testing

### CI/CD Workflow
1. **Push**: Code changes trigger GitHub Actions
2. **Build**: Multi-stage Docker image creation
3. **Test**: Comprehensive API and integration testing
4. **Security**: Trivy vulnerability scanning
5. **Deploy**: Automated K8s deployment on main branch
6. **Monitor**: Health checks and performance monitoring

### Production Deployment
1. **K8s Cluster**: Deploy using `k8s/deploy.sh`
2. **Scaling**: HPA automatically scales 2-10 pods
3. **Storage**: PVC ensures data persistence
4. **Monitoring**: Built-in health checks and metrics
5. **Backups**: Automated daily backups with retention

## 🔧 Configuration

### GitHub Secrets Required
```
DOCKERHUB_USERNAME=your_dockerhub_username
DOCKERHUB_TOKEN=your_dockerhub_token
```

### Environment Configuration
- **Development**: Uses `.env.sqlite` with local SQLite
- **Docker**: Uses environment variables for container config
- **Kubernetes**: Uses ConfigMaps and Secrets for secure config management

## 📚 Documentation

- **[GitHub Actions Guide](GITHUB_ACTIONS_GUIDE.md)**: Complete CI/CD setup
- **[Security Guide](SECURITY_GUIDE.md)**: Security best practices
- **[Secrets Config](.github/SECRETS_CONFIG.md)**: GitHub secrets setup

## 🎯 Production Features

### Scalability
- **Horizontal Pod Autoscaler**: 2-10 pods based on CPU usage
- **Resource Optimization**: Efficient memory and CPU limits
- **Load Balancing**: K8s service with multiple pod endpoints

### Reliability
- **Health Checks**: Liveness and readiness probes
- **Rolling Updates**: Zero-downtime deployments
- **Persistent Storage**: Data survives pod restarts
- **Backup Strategy**: Automated daily backups with compression

### Security
- **Container Security**: Non-root execution, minimal base image
- **Network Security**: K8s network policies and service isolation
- **Vulnerability Management**: Daily security scans and updates
- **Secrets Management**: Secure handling of sensitive configuration

## 📄 License

MIT License - see LICENSE file for details

## 👤 Author

**Himanshu Toshniwal**

---

**Ready for Production** ✅ | **DevOps Complete** ✅ | **Security Hardened** ✅ | **Auto-Scaling** ✅