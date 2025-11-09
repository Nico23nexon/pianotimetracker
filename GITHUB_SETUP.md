# How to Upload to GitHub

## Step 1: Initialize Git Repository

Run these commands in your project directory:

```bash
git init
git add .
git commit -m "Initial commit: Piano Practice Tracker app"
```

## Step 2: Create a GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Name it (e.g., "pianotracker" or "piano-practice-tracker")
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

## Step 3: Connect and Push

After creating the repository, GitHub will show you commands. Use these:

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual GitHub username and repository name.

## Alternative: Using GitHub CLI

If you have GitHub CLI installed:

```bash
gh repo create pianotracker --public --source=. --remote=origin --push
```

## Notes

- Your `.gitignore` file is already configured to exclude build files and dependencies
- Make sure you're in the project root directory when running these commands
- If you need to authenticate, GitHub will prompt you for credentials or use a personal access token

