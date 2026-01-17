# 🔐 GitHub Secrets Configuration Guide

This guide explains how to set up the required GitHub Secrets for CI/CD pipeline.

## ⚙️ Required Secrets

Your CI/CD pipeline requires 2 secrets to push images to Docker Hub:

1. **DOCKERHUB_USERNAME** - Your Docker Hub username
2. **DOCKERHUB_TOKEN** - Your Docker Hub Personal Access Token

## 📋 Step-by-Step Setup

### Step 1: Create Docker Personal Access Token

1. Go to [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Click on **New Access Token**
3. Give it a name (e.g., "GitHub Actions" or "CI/CD Token")
4. Make sure these are checked:
   - ✅ Read, Write, Delete
5. Click **Generate**
6. **Copy the token immediately** (you won't see it again!)
7. Save it safely - you'll need it in the next step

**Token Format Example**: `dckr_pat_xxxxxxxxxxxxxxxxxxxx`

### Step 2: Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Click **Settings** (top navigation)
3. In left sidebar, go to **Secrets and variables** → **Actions**
4. Click **New repository secret** (green button)

#### Secret 1: DOCKERHUB_USERNAME

- **Name**: `DOCKERHUB_USERNAME`
- **Value**: `himanshutoshniwal7570` (your Docker Hub username)
- Click **Add secret**

#### Secret 2: DOCKERHUB_TOKEN

- **Name**: `DOCKERHUB_TOKEN`
- **Value**: Paste the token you generated in Step 1
- Click **Add secret**

### Step 3: Verify Secrets are Set

```
Your secrets should look like:
✅ DOCKERHUB_USERNAME = himanshutoshniwal7570
✅ DOCKERHUB_TOKEN = dckr_pat_xxxxxxxxxxxxxxxxxxxx
```

## 🧪 Testing the Setup

### Method 1: Trigger GitHub Action Manually

1. Go to **Actions** tab in your repository
2. Click **Build, Test, Scan & Deploy** workflow
3. Click **Run workflow** → **Run workflow**
4. Monitor the workflow execution
5. Check if image is pushed to Docker Hub

### Method 2: Make a Commit to Main Branch

```bash
# Make a small change and push to main
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

The workflow will automatically trigger.

### Method 3: Check Docker Hub

Visit: https://hub.docker.com/r/himanshutoshniwal7570/notesapp

You should see:
```
himanshutoshniwal7570/notesapp:latest
himanshutoshniwal7570/notesapp:<commit-sha>
```

## ✅ Verify Everything Works

### 1. Check GitHub Actions

Go to **Actions** tab:
- ✅ Workflow runs show green checkmarks
- ✅ Build stage: Success
- ✅ Security Scan stage: Success  
- ✅ Push stage: Success

### 2. Check Docker Hub

Visit your repository: `https://hub.docker.com/r/himanshutoshniwal7570/notesapp`
- ✅ Latest tag exists
- ✅ Image layers show correctly
- ✅ Manifest lists multi-platform support

### 3. Test Image Pull

```bash
# Login to Docker Hub
docker login

# Pull the image
docker pull himanshutoshniwal7570/notesapp:latest

# Run it
docker run -p 3000:3000 \
  -e DB_HOST=localhost \
  -e DB_USER=root \
  -e DB_PASS=password \
  himanshutoshniwal7570/notesapp:latest
```

## 🔍 Troubleshooting

### Issue: "Authentication failed"

**Solution**: Verify the token is correct:
1. Go to Docker Hub Security settings
2. Check if token is still valid (not revoked)
3. Copy the exact token again
4. Update the secret in GitHub

### Issue: "Push failed - No credentials supplied"

**Solution**: Check secret names are exactly correct:
- `DOCKERHUB_USERNAME` (not `DOCKERHUB_USER`)
- `DOCKERHUB_TOKEN` (not `DOCKER_TOKEN`)

### Issue: Workflow doesn't trigger

**Solution**: Make sure:
1. You pushed to `main` branch (not other branches)
2. File changes include code changes
3. GitHub Actions is enabled in repository settings

### Issue: Image not appearing in Docker Hub

**Solution**: Check workflow logs:
1. Go to **Actions** tab
2. Click the failed workflow
3. Click **Push** stage
4. View logs for error messages

## 🔐 Security Best Practices

✅ **DO:**
- Rotate tokens regularly (every 3 months)
- Use different tokens for different CI/CD systems
- Revoke tokens you no longer use
- Monitor Docker Hub activity logs

❌ **DON'T:**
- Commit tokens to git
- Share tokens in chat/email
- Use the same token for multiple CI/CD systems
- Put tokens in .env files that are committed

## 📱 Optional: Add More Workflows

If you want to add more CI/CD workflows, you may need additional secrets:

```yaml
# Example for GitHub Container Registry
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Auto-provided
```

```yaml
# Example for AWS ECR
AWS_ACCESS_KEY_ID: your-aws-key
AWS_SECRET_ACCESS_KEY: your-aws-secret
```

## 🧹 Cleanup Old Tokens

Periodically clean up unused tokens:

1. Go to [Docker Hub Security](https://hub.docker.com/settings/security)
2. Review and delete old tokens
3. Generate fresh tokens if needed

## 📞 Need Help?

- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides)

---

**✅ Once you complete these steps, your CI/CD pipeline is ready to go!**

Every time you push to `main` branch:
1. Build Docker image
2. Scan for vulnerabilities (Trivy)
3. Push to Docker Hub
4. Daily security checks
5. Weekly cleanup
