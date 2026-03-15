# Recondo Wars - Version Release Script
# Creates a new version tag, pushes to GitHub, and keeps only the last 3 tags.
#
# Usage:
#   .\release.ps1 -Version "v0.3" -Message "Description of changes"

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,

    [Parameter(Mandatory=$true)]
    [string]$Message
)

$ErrorActionPreference = "Stop"
$MaxTags = 3

Write-Host ""
Write-Host "=== Recondo Wars Release ===" -ForegroundColor Cyan
Write-Host "Version: $Version"
Write-Host "Message: $Message"
Write-Host ""

# Stage and commit
Write-Host "[1/5] Staging changes..." -ForegroundColor Yellow
git add -A
$hasChanges = git diff --cached --quiet; $LASTEXITCODE -ne 0

if ($hasChanges) {
    Write-Host "[2/5] Committing..." -ForegroundColor Yellow
    git commit -m "$Version - $Message"
} else {
    Write-Host "[2/5] No staged changes to commit, tagging current HEAD." -ForegroundColor Yellow
}

# Tag
Write-Host "[3/5] Tagging as $Version..." -ForegroundColor Yellow
$existingTag = git tag -l $Version
if ($existingTag) {
    Write-Host "ERROR: Tag $Version already exists. Choose a different version." -ForegroundColor Red
    exit 1
}
git tag $Version

# Push
Write-Host "[4/5] Pushing to GitHub..." -ForegroundColor Yellow
git push origin master
git push origin --tags

# Prune old tags (keep only the last $MaxTags)
Write-Host "[5/5] Pruning old versions (keeping last $MaxTags)..." -ForegroundColor Yellow

$allTags = git tag --sort=version:refname
if ($allTags -is [string]) {
    $allTags = @($allTags)
}

$tagCount = $allTags.Count
if ($tagCount -gt $MaxTags) {
    $toDelete = $allTags[0..($tagCount - $MaxTags - 1)]
    foreach ($oldTag in $toDelete) {
        Write-Host "  Deleting old tag: $oldTag" -ForegroundColor DarkGray
        git tag -d $oldTag
        git push origin --delete $oldTag
    }
} else {
    Write-Host "  Only $tagCount tag(s) exist, nothing to prune." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== Release Complete ===" -ForegroundColor Green
Write-Host "Current versions on GitHub:"
git tag --sort=version:refname
Write-Host ""
