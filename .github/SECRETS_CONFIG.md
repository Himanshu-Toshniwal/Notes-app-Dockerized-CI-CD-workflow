# GitHub Actions Configuration

## 🔐 Required Environment Variables

These secrets must be configured in your GitHub repository for CI/CD to work.

## Setup Instructions

### Step 1: Generate Docker Personal Access Token

1. Visit: https://hub.docker.com/settings/security
2. Click **New Access Token**
3. Name: `GitHub Actions` (or any name)
4. Description: `CI/CD token for GitHub Actions`
5. Access: Read, Write, Delete
6. Click **Generate**
7. **Copy the token immediately** (won't show again)

### Step 2: Add to GitHub Secrets

1. Go to: `https://github.com/YOUR_USERNAME/Notes-App-CI-CD/settings/secrets/actions`
2. Click **New repository secret**

#### Add Secret 1: DOCKERHUB_USERNAME
```
Name:  DOCKERHUB_USERNAME
Value: himanshutoshniwal7570
```

#### Add Secret 2: DOCKERHUB_TOKEN
```
Name:  DOCKERHUB_TOKEN
Value: dckr_pat_xxxxxxxxxxxxxxxxxxxxxxx
```

## ✅ Verification

After adding secrets, you should see:
```
✓ DOCKERHUB_TOKEN
✓ DOCKERHUB_USERNAME
```

## 🧪 Test the Setup

### Method 1: Manual Trigger
1. Go to **Actions** tab
2. Select **Build, Test, Scan & Deploy**
3. Click **Run workflow**

### Method 2: Push to Main
```bash
git add .
git commit -m "Test CI/CD"
git push origin main
```

### Monitor Progress
- Go to **Actions** tab
- Watch the workflow run
- Check Docker Hub for pushed image

## 📊 Workflow Secrets Used

| Workflow | Secrets Used |
|----------|--------------|
| `ci-cd.yml` | DOCKERHUB_USERNAME, DOCKERHUB_TOKEN |
| `security-scan.yml` | DOCKERHUB_USERNAME, DOCKERHUB_TOKEN |
| `maintenance.yml` | DOCKERHUB_USERNAME, DOCKERHUB_TOKEN |

## 🔒 Security Best Practices

✅ **DO:**
- Keep tokens private
- Rotate tokens regularly
- Use dedicated tokens for CI/CD
- Monitor Docker Hub activity

❌ **DON'T:**
- Share tokens in chat/emails
- Commit tokens to git
- Use personal tokens for CI/CD
- Keep same token for years

## 🆘 Troubleshooting

### Workflow fails with "Authentication failed"

1. Check token is still valid:
   - Go to https://hub.docker.com/settings/security
   - Verify token exists and is active

2. Regenerate token:
   - Delete old token
   - Create new token
   - Update GitHub secret

### "Secret not found" error

1. Check secret name is **exact**:
   - `DOCKERHUB_USERNAME` (not `DOCKERHUB_USER`)
   - `DOCKERHUB_TOKEN` (not `DOCKER_TOKEN`)

2. Verify secrets are in correct repository

### Image not pushing to Docker Hub

1. Check secrets are configured
2. Check token has "Read, Write, Delete" permissions
3. Check Docker Hub username is correct
4. View workflow logs for error details

## 📝 Workflow Reference

### CI/CD Pipeline Stages

**Stage 1: Build**
- Validates Docker build
- No secrets needed

**Stage 2: Security Scan (Trivy)**
- Scans image for vulnerabilities
- Reports to GitHub Security
- No secrets needed

**Stage 3: Push to DockerHub**
- Uses: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`
- Only runs on `main` branch
- Only runs on push (not PR)

**Stage 4: Cleanup**
- Cleanup and summary
- No secrets needed

## 🔄 Scheduled Workflows

### Security Scan (Daily)
- Runs at 2:00 AM UTC
- Uses secrets for image pull (if needed)

### Maintenance (Weekly)
- Runs Mondays at 4:00 AM UTC
- Uses secrets for Docker login

## 🚀 Next Steps

1. ✅ Configure secrets above
2. ✅ Trigger workflow manually
3. ✅ Check Docker Hub for image
4. ✅ Setup production deployment
5. ✅ Monitor scheduled scans

## 📞 Support

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Security](https://docs.docker.com/docker-hub/access-tokens/)
- Check workflow logs in **Actions** tab

---

**Once secrets are configured, CI/CD will automatically:**
- Build Docker image on every push
- Scan for vulnerabilities
- Push to Docker Hub
- Run daily security checks
- Weekly cleanup
