# 🛠️ Scripts Directory

Automation scripts for version control, backups, and database management.

---

## 📋 Available Scripts

### Version Control Scripts

#### `create-version.bat`
Creates a new version tag in Git.

**Usage:**
```bash
create-version.bat v3.0.1 "Bug fixes and improvements"
```

**What it does:**
1. Checks for uncommitted changes
2. Optionally commits changes
3. Creates Git tag with version number
4. Shows confirmation

**Example:**
```bash
# Create patch version (bug fixes)
create-version.bat v3.0.1 "Fixed HOD approval bug"

# Create minor version (new features)
create-version.bat v3.1.0 "Added email notifications"

# Create major version (breaking changes)
create-version.bat v4.0.0 "Complete redesign"
```

---

#### `list-versions.bat`
Lists all versions, commits, and available backups.

**Usage:**
```bash
list-versions.bat
```

**Shows:**
- All Git tags (versions)
- Recent commits
- Current Git status
- Available backups

**Example Output:**
```
Git Tags (Versions):
--------------------
v3.0.0  Initial commit - Purchase Requisition System v3.0
v3.0.1  Bug fixes
v3.1.0  Email notifications

Recent Commits:
---------------
abc1234 (tag: v3.1.0) Added email notifications
def5678 (tag: v3.0.1) Fixed HOD approval bug
588d0f6 (tag: v3.0.0) Initial commit
```

---

### Backup Scripts

#### `backup-version.bat`
Creates a complete backup of a specific version or current state.

**Usage:**
```bash
# Backup specific version
backup-version.bat v3.0.0

# Backup current state
backup-version.bat
```

**What gets backed up:**
- ✅ All source code
- ✅ Database files (.db)
- ✅ Uploaded files
- ✅ Environment config (.env)
- ✅ Documentation

**What's excluded:**
- ❌ node_modules
- ❌ Log files
- ❌ Temporary files

**Output:**
```
C:\Projects\purchase-requisition-backups\
  ├── prs-v3.0.0-20250106_143022\         (Folder)
  └── prs-v3.0.0-20250106_143022.zip      (Compressed)
```

---

#### `restore-version.bat`
Restores a previous backup.

**Usage:**
```bash
restore-version.bat prs-v3.0.0-20250106_143022
```

**⚠️ Warning:** This will:
1. Stop running servers
2. Create safety backup of current state
3. Replace all files with backup
4. Reinstall dependencies
5. Reinitialize database

**Safety Features:**
- Creates automatic safety backup before restoring
- Prompts for confirmation
- Shows list of available backups

---

#### `automated-backup.bat`
Automated backup script for Windows Task Scheduler.

**Setup:**
1. Open Task Scheduler (`taskschd.msc`)
2. Create Basic Task
3. Set trigger: Daily at 2:00 AM
4. Action: Run this script
5. Configure for Windows 10/11

**Features:**
- Daily backups (kept 30 days)
- Weekly backups on Sunday (kept 90 days)
- Monthly backups on 1st (kept permanently)
- Automatic cleanup of old backups
- Detailed logging

**Log File:**
```
C:\backups\purchase-requisition-system\backup-log.txt
```

---

### Database Scripts

Located in `backend/scripts/`:

#### `hashPasswords.js`
Hashes user passwords in the database.

**Usage:**
```bash
cd backend
node scripts/hashPasswords.js
```

**When to run:**
- After database restore
- After fresh installation
- When adding new users manually

---

#### `addBudgetsTable.js`
Adds budget management tables to database.

**Usage:**
```bash
cd backend
node scripts/addBudgetsTable.js
```

---

#### `addQuotesAndAdjudications.js`
Adds quotes and adjudication tables.

**Usage:**
```bash
cd backend
node scripts/addQuotesAndAdjudications.js
```

---

#### `importVendors.js`
Imports vendors from Excel file.

**Usage:**
```bash
cd backend
node scripts/importVendors.js
```

**Requires:** `vendorlist.xlsx` in backend directory

---

## 🎯 Common Workflows

### Workflow 1: After Making Changes

```bash
# 1. Check what changed
git status
git diff

# 2. Create new version
scripts\create-version.bat v3.0.2 "Updated approval workflow"

# 3. Backup the version
scripts\backup-version.bat v3.0.2

# 4. Verify
scripts\list-versions.bat
```

---

### Workflow 2: Before Major Update

```bash
# 1. Backup current state
scripts\backup-version.bat

# 2. Make changes
# ... edit files ...

# 3. Test thoroughly
npm test

# 4. If successful, create version
scripts\create-version.bat v3.1.0 "Major update"

# 5. If failed, restore backup
scripts\restore-version.bat prs-backup-20250106_143022
```

---

### Workflow 3: Setup Automated Backups

```bash
# 1. Test the backup script manually
scripts\automated-backup.bat

# 2. Check backup was created
dir C:\backups\purchase-requisition-system

# 3. Setup Task Scheduler (see automated-backup.bat comments)

# 4. Test scheduled task
# In Task Scheduler, right-click task → Run

# 5. Verify logs
type C:\backups\purchase-requisition-system\backup-log.txt
```

---

### Workflow 4: Emergency Restore

```bash
# 1. List available backups
scripts\list-versions.bat

# 2. Choose backup to restore
scripts\restore-version.bat prs-v3.0.0-20250106_143022

# 3. Wait for restore to complete

# 4. Start servers
cd backend
npm start

# 5. Test application
# Open http://localhost:3000
```

---

## 🔍 Troubleshooting

### Script won't run
```bash
# Make sure you're in project root
cd C:\projects\purchase-requisition-system

# Run from Command Prompt (not Git Bash)
cmd.exe

# Check file exists
dir scripts\*.bat
```

### Backup too large
```bash
# Check what's taking space
dir /s backend\uploads

# Clean up old logs
del backend\logs\*.log

# Remove old databases
del *.db-old
```

### Restore failed
```bash
# Check safety backup created during restore
dir ..\purchase-requisition-backups\safety-backup-*

# Restore from safety backup
scripts\restore-version.bat safety-backup-20250106_143022
```

### Git errors
```bash
# Check Git is installed
git --version

# Check repository status
git status

# Reinitialize if needed
git init
```

---

## 📚 Documentation

- **Full Guide:** `VERSION_CONTROL_GUIDE.md`
- **Quick Demo:** `QUICK_VERSION_CONTROL_DEMO.md`
- **Main README:** `README.md`
- **Troubleshooting:** `TROUBLESHOOTING.md`

---

## 🔐 Security Notes

- ✅ `.gitignore` excludes sensitive files
- ✅ Backups include .env (keep secure)
- ✅ Database files backed up separately
- ⚠️ Don't commit .env to Git
- ⚠️ Store backups on secure location
- ⚠️ Encrypt backups if storing remotely

---

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| Create version | `create-version.bat v3.0.1 "Description"` |
| List versions | `list-versions.bat` |
| Backup version | `backup-version.bat v3.0.0` |
| Backup current | `backup-version.bat` |
| Restore backup | `restore-version.bat backup-name` |
| Hash passwords | `cd backend && node scripts/hashPasswords.js` |
| Import vendors | `cd backend && node scripts/importVendors.js` |

---

**Need help?** See `VERSION_CONTROL_GUIDE.md` for detailed instructions.
