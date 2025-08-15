#!/bin/bash
# FILE: repair_github.sh  v1.0  MODULE: GitHub Repair Script
# Author: Professor Tucker
# Purpose: Consolidate multiple professor-tucker branches into main and clean up repo
# Notes: Run from the root of your repository. Ensure you have backups in case of conflicts.

set -e  # Stop on errors

echo "🔹 Fetching all remote branches..."
git fetch --all

echo "🔹 Checking out default branch 'main'..."
git checkout main

echo "🔹 Pulling latest changes from origin/main..."
git pull origin main

# Find all branches with 'professor-tucker' in the name
branches_to_merge=$(git branch -r | grep 'origin/professor-tucker' | sed 's|origin/||')

if [ -z "$branches_to_merge" ]; then
    echo "⚠️ No remote professor-tucker branches found. Exiting."
    exit 0
fi

echo "🔹 Branches to merge into main: $branches_to_merge"

# Merge each branch
for branch in $branches_to_merge; do
    echo "🔹 Checking out $branch locally..."
    git checkout -B "$branch" "origin/$branch"

    echo "🔹 Merging $branch into main with 'theirs' strategy for automatic trivial conflicts..."
    git checkout main
    git merge -X theirs "$branch" -m "Merging $branch into main"

    echo "🔹 Deleting local branch $branch..."
    git branch -d "$branch"

    echo "🔹 Deleting remote branch $branch..."
    git push origin --delete "$branch" || echo "⚠️ Remote branch $branch may not exist, skipping."
done

echo "🔹 Pushing consolidated main branch to GitHub..."
git push origin main

echo "✅ GitHub repair complete. All professor-tucker code is now on 'main'."
echo "✅ Duplicate branches removed. Your default branch is ready for GitHub Pages deployment."
