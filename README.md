# 📝 Notes App - CI/CD Edition

![Build Status](https://github.com/YOUR_USERNAME/Notes-App-CI-CD/workflows/Build,%20Test,%20Scan%20&%20Deploy/badge.svg)
![Security Scan](https://github.com/YOUR_USERNAME/Notes-App-CI-CD/workflows/Security%20Scan%20&%20Cleanup/badge.svg)

A fully-featured **Notes Application** with **Node.js**, **Express.js**, **MySQL**, **Docker**, and **GitHub Actions CI/CD Pipeline**.

## ✨ Features

- ✅ **Create, Read, Update, Delete** notes
- ✅ **Real-time UI updates** (auto-refresh every 3 seconds)
- ✅ **Persistent MySQL database** storage
- ✅ **RESTful API** endpoints
- ✅ **Beautiful responsive UI** with gradient design
- ✅ **Docker multi-stage build** for optimization
- ✅ **GitHub Actions CI/CD pipeline** with 4 stages
- ✅ **Trivy security scanning** for vulnerabilities
- ✅ **DockerHub auto-push** on main branch
- ✅ **Scheduled security scans** and maintenance
- ✅ **Health checks** and monitoring
- ✅ **Non-root user** execution for security

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│          Frontend (HTML/CSS/JS)         │
│    Beautiful Notes UI with Real-time    │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│    Express.js Backend (Node.js)         │
│    RESTful API for CRUD Operations      │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         MySQL Database                  │
│    Persistent Data Storage              │
└─────────────────────────────────────────┘

CI/CD Pipeline:
Build → Security Scan (Trivy) → Push to DockerHub → Deploy
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/Notes-App-CI-CD.git
cd Notes-App-CI-CD
```

2. **Install dependencies**
```bash
npm install
```

3. **Setup environment variables**
```bash
cp .env.example .env
```

Edit `.env`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASS=your_mysql_password
DB_NAME=notesdb
PORT=3000
NODE_ENV=development
```

4. **Ensure MySQL is running**
```bash
# Make sure MySQL server is installed and running
# Create database (optional, app will auto-create):
mysql -u root -p
> CREATE DATABASE notesdb;
```

5. **Start the application**
```bash
npm start
# or for development with auto-reload
npm run dev
```

6. **Access the app**
```
http://localhost:3000
```

### Using Docker Compose

```bash
# Build and start all services
docker-compose up --build

# Stop services
docker-compose down

# View logs
docker-compose logs -f app
```

**URL**: `http://localhost:3000`

### Using Docker CLI

```bash
# Build the image
docker build -t notesapp:latest .

# Run with MySQL
docker run -d \
  --name mysql-notesapp \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=notesdb \
  -p 3306:3306 \
  mysql:8.0

docker run -d \
  --name notesapp \
  -e DB_HOST=mysql-notesapp \
  -e DB_USER=root \
  -e DB_PASS=rootpass \
  -p 3000:3000 \
  --link mysql-notesapp \
  notesapp:latest

# Access: http://localhost:3000
```

## 📚 API Endpoints

### Notes CRUD Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notes` | Get all notes |
| GET | `/api/notes/:id` | Get single note |
| POST | `/api/notes` | Create new note |
| PUT | `/api/notes/:id` | Update note |
| DELETE | `/api/notes/:id` | Delete note |
| GET | `/health` | Health check |

### Example Requests

```bash
# Get all notes
curl http://localhost:3000/api/notes

# Create note
curl -X POST http://localhost:3000/api/notes \
  -H "Content-Type: application/json" \
  -d '{"title": "My Note", "content": "Note content here"}'

# Update note
curl -X PUT http://localhost:3000/api/notes/note-id \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title", "content": "Updated content"}'

# Delete note
curl -X DELETE http://localhost:3000/api/notes/note-id

# Health check
curl http://localhost:3000/health
```

## 🐳 Docker Information

### Dockerfile Stages

1. **Builder Stage**: Installs production dependencies
2. **Puller Stage**: Optimizes image size
3. **Scanner Stage**: Prepares for security scanning
4. **Final Stage**: Production-ready image with non-root user

### Image Details

- **Base Image**: `node:18-alpine` (lightweight)
- **User**: `nodejs` (non-root for security)
- **Exposed Port**: `3000`
- **Health Check**: Built-in monitoring

## 🔄 GitHub Actions Workflow

### CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

**Triggered on**: `push` to main/develop, `pull_request` to main

**Stages**:
1. ✅ **Build** - Validates Docker build
2. 🔒 **Security Scan** - Trivy vulnerability scanning
3. 🚀 **Push** - Pushes to DockerHub on main branch
4. 🧹 **Cleanup** - Cleanup and summary

### Security Scan Workflow (`.github/workflows/security-scan.yml`)

**Triggered**: Daily at 2 AM UTC + manual trigger

**Features**:
- Trivy vulnerability scanning
- SARIF format upload to GitHub Security
- Critical and High severity reporting

### Maintenance Workflow (`.github/workflows/maintenance.yml`)

**Triggered**: Weekly on Monday at 4 AM UTC

**Tasks**:
- Docker system cleanup
- Image management
- Disk space monitoring

## 🔐 GitHub Secrets Setup

You need to configure these secrets in your GitHub repository:

### Required Secrets:
```
DOCKERHUB_USERNAME = himanshutoshniwal7570
DOCKERHUB_TOKEN = <your_docker_token>
```

### How to Set GitHub Secrets:

1. Go to GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add:
   - Name: `DOCKERHUB_USERNAME`
   - Value: `himanshutoshniwal7570`
4. Add:
   - Name: `DOCKERHUB_TOKEN`
   - Value: `<your_docker_personal_access_token>`

### How to Generate Docker Token:

1. Visit https://hub.docker.com/settings/security
2. Click **New Access Token**
3. Name it (e.g., "GitHub Actions")
4. Copy the token and save it as `DOCKERHUB_TOKEN` in GitHub

## 🔒 Security Features

- ✅ **Trivy Scanning** - Detects vulnerabilities in container images
- ✅ **Non-root User** - Application runs as unprivileged user
- ✅ **Health Checks** - Monitors application health
- ✅ **GitHub Security** - Uploads scan results to GitHub Security tab
- ✅ **Input Validation** - Sanitizes user inputs
- ✅ **Environment Secrets** - Secure credential management

## 📦 Project Structure

```
Notes-App-CI-CD/
├── app.js                          # Express.js main application
├── package.json                    # Node.js dependencies
├── Dockerfile                      # Multi-stage Docker build
├── docker-compose.yml              # Docker Compose configuration
├── .env.example                    # Environment variables template
├── .gitignore                      # Git ignore rules
├── public/
│   └── index.html                  # Frontend UI
├── .github/
│   └── workflows/
│       ├── ci-cd.yml              # Main CI/CD pipeline
│       ├── security-scan.yml      # Security scanning
│       └── maintenance.yml        # Maintenance tasks
└── README.md                       # This file
```

## 🚀 Deployment Options

### Option 1: Docker Hub Registry
```bash
docker pull himanshutoshniwal7570/notesapp:latest
docker run -p 3000:3000 \
  -e DB_HOST=your_mysql_host \
  -e DB_USER=root \
  -e DB_PASS=password \
  himanshutoshniwal7570/notesapp:latest
```

### Option 2: Kubernetes
```bash
kubectl apply -f k8s-deployment.yaml
```

### Option 3: Docker Swarm
```bash
docker stack deploy -c docker-compose.yml notesapp
```

## 📊 Monitoring & Logs

```bash
# View container logs
docker logs -f notesapp

# Using Docker Compose
docker-compose logs -f app

# Check health status
curl http://localhost:3000/health

# View all notes from CLI
curl http://localhost:3000/api/notes | jq '.'
```

## 🧪 Testing

```bash
# Test API endpoints
bash test-api.sh

# Or manually test
curl -X GET http://localhost:3000/api/notes
curl -X POST http://localhost:3000/api/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"Testing"}'
```

## 🔧 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | localhost | MySQL host |
| `DB_USER` | root | MySQL username |
| `DB_PASS` | (empty) | MySQL password |
| `DB_NAME` | notesdb | Database name |
| `PORT` | 3000 | Application port |
| `NODE_ENV` | development | Environment mode |

## 🐛 Troubleshooting

### MySQL Connection Error
```bash
# Check if MySQL is running
mysql -u root -p

# Verify connection in app
curl http://localhost:3000/api/notes
```

### Docker Build Issues
```bash
# Clean build
docker build --no-cache -t notesapp:latest .

# Check build logs
docker build -t notesapp:latest . 2>&1 | tail -50
```

### Port Already in Use
```bash
# Change port in .env
PORT=3001

# Or kill existing process
lsof -i :3000
kill -9 <PID>
```

## 📈 Performance Tips

- Use Docker volume for MySQL data persistence
- Enable Redis caching for frequently accessed notes
- Implement pagination for large datasets
- Use connection pooling (already implemented)
- Regular database cleanup of old notes

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the **MIT License** - see LICENSE file for details.

## 👤 Author

**Himanshu Tosh Niwal**
- GitHub: [@himanshutoshniwal7570](https://github.com/himanshutoshniwal7570)
- Docker Hub: [@himanshutoshniwal7570](https://hub.docker.com/u/himanshutoshniwal7570)

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation
- Review Docker logs for errors

## 🎯 Roadmap

- [ ] Add user authentication
- [ ] Implement search functionality
- [ ] Add tags/categories for notes
- [ ] Real-time collaboration (WebSocket)
- [ ] Mobile app (React Native)
- [ ] Cloud deployment (AWS, GCP)
- [ ] Database backup automation
- [ ] Advanced analytics dashboard

## 📚 References

- [Express.js Documentation](https://expressjs.com/)
- [MySQL Node.js](https://github.com/mysqljs/mysql2)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)

---

**Made with ❤️ by Himanshu Tosh Niwal** | **Powered by CI/CD Pipeline**

⭐ If you found this helpful, please star the repository!
