param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[a-z0-9]+(?:-[a-z0-9]+)*$')]
  [string]$Name
)

$ErrorActionPreference = "Stop"
$branch = "feature/$Name"

if ((git status --porcelain).Length -gt 0) {
  throw "Há alterações locais não salvas. Faça commit ou stash antes de criar a branch."
}

git checkout develop
git pull --ff-only origin develop
git checkout -b $branch
git push -u origin $branch

Write-Host "Branch $branch criada e publicada." -ForegroundColor Green
