# ⚡ Quick Start Guide

Get the Notes App running in **5 minutes**!

## 🚀 Option 1: Using Docker Compose (Recommended)

### Prerequisites
- Docker Desktop installed ([Download](https://www.docker.com/products/docker-desktop))

### Steps

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/Notes-App-CI-CD.git
cd Notes-App-CI-CD

# 2. Create environment file
cp .env.example .env

# 3. Start the app
docker-compose up -d

# 4. Wait 10 seconds for MySQL to start
sleep 10

# 5. Open browser
open http://localhost:3000
# Or manually visit: http://localhost:3000
```

### That's it! 🎉

The app is running with:
- ✅ Frontend UI
- ✅ Backend API
- ✅ MySQL Database

### Stop the app

```bash
docker-compose down
```

---

## 💻 Option 2: Local Development

### Prerequisites
- Node.js 18+ ([Download](https://nodejs.org/))
- MySQL Server ([Download](https://www.mysql.com/downloads/))

### Steps

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/Notes-App-CI-CD.git
cd Notes-App-CI-CD

# 2. Install dependencies
npm install

# 3. Create environment file
cp .env.example .env

# 4. Edit .env with your MySQL password
nano .env
# Change: DB_PASS=your_mysql_password

# 5. Make sure MySQL is running
# Then start the app
npm start

# 6. Open browser
open http://localhost:3000
```

### For development with auto-reload

```bash
npm run dev
```

---

## 🧪 Testing the App

### Via Browser

1. Open http://localhost:3000
2. Enter a note title: "My First Note"
3. Enter content: "This is awesome!"
4. Click **➕ Add Note**
5. See your note appear instantly!
6. Try **Edit** and **Delete** buttons

### Via Command Line (API Testing)

```bash
# Test the API
bash test-api.sh
```

Expected output:
```
✅ All tests passed! Your Notes App is working correctly.
```

---

## 🐳 Using Pre-built Docker Image

Pull from Docker Hub (once CI/CD pushes it):

```bash
# Pull image
docker pull himanshutoshniwal7570/notesapp:latest

# Run it
docker run -p 3000:3000 \
  -e DB_HOST=localhost \
  -e DB_USER=root \
  -e DB_PASS=password \
  himanshutoshniwal7570/notesapp:latest
```

---

## 🔗 Important Links

| Link | Purpose |
|------|---------|
| http://localhost:3000 | Web UI |
| http://localhost:3000/api/notes | Get all notes (API) |
| http://localhost:3000/health | Health check |

---

## 📝 API Quick Reference

### Create Note
```bash
curl -X POST http://localhost:3000/api/notes \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Note",
    "content": "Note content here"
  }'
```

### Get All Notes
```bash
curl http://localhost:3000/api/notes
```

### Update Note
```bash
curl -X PUT http://localhost:3000/api/notes/NOTE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content"
  }'
```

### Delete Note
```bash
curl -X DELETE http://localhost:3000/api/notes/NOTE_ID
```

---

## 🔐 GitHub Actions Setup (CI/CD)

### 1. Get Docker Token

1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name it "GitHub Actions"
4. Copy the token

### 2. Add GitHub Secrets

1. Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add `DOCKERHUB_USERNAME` = `himanshutoshniwal7570`
4. Add `DOCKERHUB_TOKEN` = (paste your token)

### 3. Push to Trigger CI/CD

```bash
git add .
git commit -m "Deploy app"
git push origin main
```

Watch the workflow in **Actions** tab! 🚀

---

## 📂 Project Structure

```
Notes-App-CI-CD/
├── app.js                    # Backend server
├── package.json              # Dependencies
├── Dockerfile                # Docker image build
├── docker-compose.yml        # Docker Compose setup
├── public/
│   └── index.html           # Frontend UI
├── .github/workflows/
│   ├── ci-cd.yml            # Main pipeline
│   ├── security-scan.yml    # Security
│   └── maintenance.yml      # Cleanup
├── backup.sh                 # Database backup
├── README.md                 # Full documentation
└── DEPLOYMENT.md            # Deployment guide
```

---

## 🐛 Troubleshooting

### "Port 3000 already in use"
```bash
# Kill the process on port 3000
lsof -i :3000
kill -9 <PID>

# Or use different port
PORT=3001 npm start
```

### "Cannot connect to MySQL"
```bash
# Make sure MySQL is running
# Docker Compose version - MySQL starts automatically
docker-compose logs mysql

# Local version - start MySQL
# On macOS: brew services start mysql
# On Windows: Open MySQL from System Tray
```

### "Module not found"
```bash
# Reinstall dependencies
rm -rf node_modules
npm install
```

### Docker command not found
- Install Docker Desktop: https://www.docker.com/products/docker-desktop

---

## 📚 Next Steps

1. **Explore the UI** - Create, edit, delete notes
2. **Read [README.md](./README.md)** - Full documentation
3. **Check [DEPLOYMENT.md](./DEPLOYMENT.md)** - Production deployment
4. **Setup GitHub Secrets** - Enable CI/CD pipeline
5. **Make modifications** - Add features, customize styling

---

## ⭐ Quick Checklist

- [ ] ✅ Docker installed and running
- [ ] ✅ Project cloned
- [ ] ✅ `docker-compose up -d` executed
- [ ] ✅ App accessible at http://localhost:3000
- [ ] ✅ Can create/edit/delete notes
- [ ] ✅ API is responding (test-api.sh)

---

## 💬 Need Help?

1. Check error messages carefully
2. View logs: `docker-compose logs -f`
3. Read full README.md
4. Check Troubleshooting section above

---

## 🎯 You're all set! 

**Now go ahead and:**
- 📝 Create amazing notes
- 🚀 Deploy to production
- 🔄 Setup CI/CD pipeline
- 🐳 Push to Docker Hub

**Happy coding! 🎉**

---

**Questions? Check the full [README.md](./README.md) for comprehensive documentation.**
