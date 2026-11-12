# Assignment 1: Git & GitHub

Replace `Your Name` and `<username>` with your own details.

---

## Q1. Create and Initialize Git Repository

**Step 1.** Create the repository folder and move into it.
```bash
mkdir git_lab
cd git_lab
```

**Step 2.** Initialize Git.
```bash
git init -b main
```

**Step 3.** Set your identity (one-time only).
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

**Step 4.** Create `info.txt` with your name and date.
```bash
echo "Name: Your Name" > info.txt
echo "Date: 12-11-2026" >> info.txt
```

**Step 5.** Check the repository status.
```bash
git status
```

**Step 6.** Add the file to staging.
```bash
git add info.txt
```

**Step 7.** Commit.
```bash
git commit -m "Initial commit"
```

---

## Q2. Connect to GitHub and Push Code

**Step 1.** On github.com, click **+ → New repository**, name it `git_lab_remote`, keep it empty (no README, no .gitignore), and click **Create repository**.

**Step 2.** Link the local repository to the remote.
```bash
git remote add origin https://github.com/<username>/git_lab_remote.git
```

**Step 3.** Verify the link.
```bash
git remote -v
```

**Step 4.** Push the code.
```bash
git push -u origin main
```
Use a Personal Access Token as the password when prompted.

**Step 5.** Open the repository on GitHub and confirm `info.txt` is uploaded.

---

## Q3. Clone Repository and Make Changes

**Step 1.** Move out of `git_lab`.
```bash
cd ..
```

**Step 2.** Clone the repository into a new directory.
```bash
git clone https://github.com/<username>/git_lab_remote.git git_lab_clone
cd git_lab_clone
```

**Step 3.** Create `data.txt` with sample content.
```bash
echo "This is sample data" > data.txt
```

**Step 4.** Add and commit.
```bash
git add data.txt
git commit -m "Added data file"
```

**Step 5.** Push the changes to GitHub.
```bash
git push
```

**Step 6.** Confirm `data.txt` appears on GitHub.

---

## Q4. Branching and Merging

Perform these steps inside `git_lab_clone`.

**Step 1.** Create a new branch named `feature`.
```bash
git branch feature
```

**Step 2.** Switch to the `feature` branch.
```bash
git switch feature
```

**Step 3.** Modify `info.txt` by adding a new line.
```bash
echo "Feature branch update" >> info.txt
```

**Step 4.** Commit the changes.
```bash
git add info.txt
git commit -m "Feature branch update"
```

**Step 5.** Switch back to the `main` branch.
```bash
git switch main
```

**Step 6.** Merge `feature` into `main`.
```bash
git merge feature
```

**Step 7.** Delete the `feature` branch after the merge.
```bash
git branch -d feature
```

**Step 8.** Verify.
```bash
git branch
git log --oneline
```

**Step 9 (optional).** Push the merged result.
```bash
git push
```

---

## Screenshots for Submission

- `git status` before the first commit (Q1)
- `git remote -v` and the GitHub page showing `info.txt` (Q2)
- GitHub page showing `data.txt` (Q3)
- `git log --oneline` and `git branch` after merge and delete (Q4)
