# GitHub-to-Jira integration commit message hook
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![JIRA](https://img.shields.io/badge/JIRA-Integration-0052CC.svg)](https://www.atlassian.com/software/jira)
[![Git Hook](https://img.shields.io/badge/Git-Hook-F05032.svg)](https://git-scm.com/docs/githooks)
[![Cross Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/ev-khromov/jira-commit-msg)

A configurable Git commit-msg hook that enforces commit message standards and automatically prepends JIRA ticket IDs from branch names to support Jira <-> GitHub integration.

## ⚡ Quick Install

Copy the files from `git-hooks/` to your project `.git/hooks/` directory.

(For nix/macos) make it executable: `chmod +x .git/hooks/commit-msg`. Requires PowerShell 5.1+ for cross-platform support.

## 🚀 Features

- ✅ **JSON-configurable patterns** - Customize commit message formats via configuration file
- ✅ **Auto-prepend JIRA tickets** - Automatically extracts and prepends ticket IDs from branch names
- ✅ **Multiple commit formats** - Supports JIRA tickets, conventional commits, and merge commits
- ✅ **Flexible branch patterns** - Works with various branch naming conventions
- ✅ **Message length validation** - Configurable min/max message length limits
- ✅ **Detailed error messages** - Clear feedback with examples when validation fails
- ✅ **Cross-platform** - Works on Windows, macOS, and Linux with PowerShell

## 📋 Supported Commit Patterns

### 1. JIRA Ticket Format
```
JIRA-1234 Add user authentication feature
ABC-999 Fix critical login bug
```

### 2. Conventional Commits
```
feat: add user authentication
fix(auth): resolve login issue
docs: update API documentation
```

### 3. Merge Commits
```
Merge branch 'feature/JIRA-1234'
```

## 🌿 Supported Branch Patterns

### Simple Format
```
feature/JIRA-1234
hotfix/ABC-999
bugfix/DEF-123
```

### With Description
```
feature/JIRA-1234-add-user-auth
hotfix/ABC-999-fix-critical-bug
release/PROJ-456-version-2-0
```

## 🛠️ Installation

### Prerequisites
- Git
- PowerShell 5.1+ (Windows) or PowerShell Core 6+ (macOS/Linux)

### Setup Steps

1. **Copy the git-hooks files** to your `.git/hooks/` directory:
   ```bash
   # Copy the shell script
   cp commit-msg .git/hooks/commit-msg
   
   # Copy the PowerShell script
   cp commit-msg.ps1 .git/hooks/commit-msg.ps1
   
   # Copy the configuration file
   cp commit-msg-config.json .git/hooks/commit-msg-config.json
   ```

2. **Make the hook executable** (Unix/macOS/Linux):
   ```bash
   chmod +x .git/hooks/commit-msg
   ```

3. **Test the installation**:
   ```bash
   git commit -m "test: verify hook installation"
   ```

## ⚙️ Configuration

The hook behavior is controlled by `.git/hooks/commit-msg-config.json`:

### Basic Configuration
```json
{
   "commitPatterns": [
      {
         "name": "jira-ticket",
         "pattern": "^[A-Z]+-\\d+\\s",
         "description": "JIRA ticket pattern (e.g., JIRA-1234 )"
      },
      {
         "name": "conventional-commits",
         "pattern": "^(feat|fix|docs|style|refactor|test|chore)(\\(.+\\))?:\\s",
         "description": "Conventional commits pattern"
      }
   ],
   "branchPatterns": [
      {
         "name": "feature-branch-simple",
         "pattern": "(feature|hotfix|bugfix|release|mod|fix)\\/([A-Z]+-\\d+)$",
         "ticketGroup": 2,
         "description": "Simple feature branch with JIRA ticket only"
      },
      {
         "name": "feature-branch-with-description",
         "pattern": "(feature|hotfix|bugfix|release|mod|fix)\\/([A-Z]+-\\d+)-(.+)",
         "ticketGroup": 2,
         "description": "Feature branch with JIRA ticket and hyphen-separated description"
      }
   ],
   "settings": {
      "autoPrependTicket": true,
      "requireTicketInMessage": true,
      "minMessageLength": 10,
      "maxMessageLength": 72
   }
}
```

### Configuration Options

#### Commit Patterns
- **name**: Identifier for the pattern
- **pattern**: Regular expression to match commit messages
- **description**: Human-readable description

#### Branch Patterns
- **name**: Identifier for the pattern
- **pattern**: Regular expression to match branch names
- **ticketGroup**: Which regex group contains the ticket ID (usually 2)
- **description**: Human-readable description

#### Settings
- **autoPrependTicket**: Automatically prepend ticket ID from branch name
- **requireTicketInMessage**: Enforce that commits match at least one pattern
- **minMessageLength**: Minimum commit message length (0 to disable)
- **maxMessageLength**: Maximum commit message length (0 to disable)
- **allowedCommitTypes**: Array of allowed conventional commit types

## 🎯 Usage Examples

### Auto-prepend Feature
When working on branch `feature/JIRA-1234`:
```bash
# Your commit message
git commit -m "add user login functionality"

# Automatically becomes
# "JIRA-1234 add user login functionality"
```

### Manual JIRA Format
```bash
git commit -m "JIRA-1234 implement OAuth2 authentication"
```

### Conventional Commits
```bash
git commit -m "feat: add user registration endpoint"
git commit -m "fix(auth): resolve token expiration issue"
git commit -m "docs: update API documentation"
```

### Branch-based Workflow
```bash
# Create feature branch
git checkout -b feature/JIRA-1234-user-auth

# Commit with simple message (auto-prepends JIRA-1234)
git commit -m "implement login form"

# Result: "JIRA-1234 implement login form"
```

## 🔧 Advanced Configuration

### Custom Config File Path
The hook supports specifying a custom configuration file:
```bash
# Default location
.git/hooks/commit-msg-config.json

# Custom location (modify .git/hooks/commit-msg)
CONFIG_FILE="path/to/custom-config.json"
```

### Adding New Commit Types
```json
{
   "commitPatterns": [
      {
         "name": "custom-format",
         "pattern": "^(TASK|STORY|BUG)-\\d+:",
         "description": "Custom ticket format"
      }
   ]
}
```

### Organization-specific Patterns
```json
{
   "branchPatterns": [
      {
         "name": "team-convention",
         "pattern": "(epic|story|task)\\/([A-Z]{2,}-\\d+)",
         "ticketGroup": 2,
         "description": "Team-specific branch naming"
      }
   ]
}
```