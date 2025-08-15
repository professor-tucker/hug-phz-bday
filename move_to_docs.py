# FILE: move_to_docs.py  v1.0  MODULE: GitHub Pages Prep
# Author: Professor Tucker
# Purpose: Move frontend/public into /docs for GitHub Pages and push automatically
# Notes: Run this from repo root (C:/src/hug-phz-bday)

import os
import shutil
import subprocess

# Paths
repo_root = os.getcwd()
source = os.path.join(repo_root, "frontend", "public")
destination = os.path.join(repo_root, "docs")

# Step 1: Remove old /docs folder if it exists
if os.path.exists(destination):
    print("🗑 Removing existing /docs folder...")
    shutil.rmtree(destination)

# Step 2: Move frontend/public to /docs
print("📂 Moving frontend/public to /docs...")
shutil.copytree(source, destination)

# Step 3: Commit and push changes to main
print("💾 Adding changes to git...")
subprocess.run(["git", "add", "."], check=True)

print("💬 Committing changes...")
subprocess.run(["git", "commit", "-m", "Move frontend/public to /docs for GitHub Pages"], check=True)

print("🚀 Pushing to main...")
subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Done! Your /docs folder is now up-to-date for GitHub Pages.")
