# Git Commit Message Hook - PowerShell Script
# Copyright (c) 2025 Evgenii Khromov
# Licensed under the MIT License
# https://github.com/ev-khromov/jira-commit-msg.git

Set-StrictMode -Version Latest

# Parameters
$CommitMsgFile = $args[0]
$ConfigFile = if ($args[1]) { $args[1] } else { "$PSScriptRoot/commit-msg-config.json" }

# Functions
function Write-ErrorAndExit {
    param([string]$Message, [int]$ExitCode = 1)
    Write-Error $Message
    exit $ExitCode
}

function Load-Configuration {
    if (-not (Test-Path $ConfigFile)) {
        Write-ErrorAndExit "ERROR: Configuration file not found: $ConfigFile"
    }
    
    try {
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        return $config
    }
    catch {
        Write-ErrorAndExit "ERROR: Failed to parse configuration file: $($_.Exception.Message)"
    }
}

function Test-CommitMessage {
    param(
        [string]$Message,
        [array]$Patterns
    )
    
    foreach ($patternObj in $Patterns) {
        if ($Message -match $patternObj.pattern) {
            Write-Verbose "Commit message matches pattern: $($patternObj.name)"
            return $true
        }
    }
    return $false
}

function Get-TicketFromBranch {
    param(
        [string]$BranchName,
        [array]$BranchPatterns
    )
    
    foreach ($branchPattern in $BranchPatterns) {
        if ($BranchName -match $branchPattern.pattern) {
            $ticketGroup = $branchPattern.ticketGroup
            if ($ticketGroup -and $Matches[$ticketGroup]) {
                Write-Verbose "Extracted ticket from branch: $($Matches[$ticketGroup]) using pattern: $($branchPattern.name)"
                return $Matches[$ticketGroup]
            }
        }
    }
    return $null
}

function Validate-MessageLength {
    param(
        [string]$Message,
        [int]$MinLength,
        [int]$MaxLength
    )
    
    $firstLine = ($Message -split "`n")[0]
    
    if ($firstLine.Length -lt $MinLength) {
        Write-ErrorAndExit "ERROR: Commit message too short. Minimum length: $MinLength characters"
    }
    
    if ($firstLine.Length -gt $MaxLength) {
        Write-ErrorAndExit "ERROR: Commit message too long. Maximum length: $MaxLength characters"
    }
}

# Main execution
try {
    # Load configuration
    $config = Load-Configuration
    
    # Read commit message
    if (-not (Test-Path $CommitMsgFile)) {
        Write-ErrorAndExit "ERROR: Commit message file not found: $CommitMsgFile"
    }
    
    $CommitMsg = Get-Content $CommitMsgFile -Raw
    if (-not $CommitMsg) {
        Write-ErrorAndExit "ERROR: Commit message is empty"
    }
    
    $CommitMsg = $CommitMsg.Trim()
    
    # Get current branch
    $BranchName = git symbolic-ref --short HEAD 2>$null
    if (-not $BranchName) {
        Write-ErrorAndExit "ERROR: Unable to determine branch name"
    }
    
    Write-Verbose "Branch: $BranchName"
    Write-Verbose "Original message: $CommitMsg"
    
    # Check if message already matches any commit pattern
    $messageMatches = Test-CommitMessage -Message $CommitMsg -Patterns $config.commitPatterns
    
    if (-not $messageMatches -and $config.settings.autoPrependTicket) {
        # Try to extract ticket from branch
        $ticket = Get-TicketFromBranch -BranchName $BranchName -BranchPatterns $config.branchPatterns
        
        if ($ticket) {
            $CommitMsg = "$ticket $CommitMsg"
            Set-Content $CommitMsgFile $CommitMsg
            Write-Verbose "Prepended ticket: $CommitMsg"
            
            # Re-check if the modified message now matches patterns
            $messageMatches = Test-CommitMessage -Message $CommitMsg -Patterns $config.commitPatterns
        }
    }
    
    # Final validation
    if ($config.settings.requireTicketInMessage -and -not $messageMatches) {
        $patternDescriptions = $config.commitPatterns | ForEach-Object { "- $($_.description): $($_.pattern)" } | Join-String -Separator "`n"
        Write-ErrorAndExit @"
ERROR: Commit message does not match any required patterns.

Your message: '$CommitMsg'

Allowed patterns:
$patternDescriptions

Examples:
- JIRA-1234 Add new feature
- feat: add user authentication
- fix(auth): resolve login issue
"@
    }
    
    # Validate message length
    if ($config.settings.minMessageLength -or $config.settings.maxMessageLength) {
        Validate-MessageLength -Message $CommitMsg -MinLength $config.settings.minMessageLength -MaxLength $config.settings.maxMessageLength
    }
    
    Write-Verbose "Commit message validation passed: $CommitMsg"
    exit 0
}
catch {
    Write-ErrorAndExit "ERROR: Unexpected error: $($_.Exception.Message)"
}