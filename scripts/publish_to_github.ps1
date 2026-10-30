<#
 Publishes this folder as a new GitHub repository using the GitHub CLI.
 Run from PowerShell:   .\scripts\publish_to_github.ps1
 Optional:              .\scripts\publish_to_github.ps1 -DataDir "C:\path\to\Datasets" -Visibility public
 -DataDir (optional)    folder that contains the 4 CSV files (searched recursively); they are zipped and
                        attached to a GitHub Release because they are too large to keep in git.
 Needs: git and GitHub CLI (gh). Install gh with:  winget install --id GitHub.cli --exact
#>
param(
  [string]$Owner = "HANIDEVINF",
  [string]$Name = "MCTNet-Crop-Classification",
  [ValidateSet("public","private")][string]$Visibility = "public",
  [string]$DataDir = ""
)
$ErrorActionPreference = "Stop"
$Description = "Reproduction, covariate ablation and BiGRU extension of MCTNet (CNN-Transformer) for crop-type mapping from Sentinel-2 time series - Arkansas and California, 2021."
$Topics = @("deep-learning","remote-sensing","sentinel-2","crop-classification","time-series","transformer","cnn","tensorflow","keras","google-earth-engine")

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git is not installed." }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { throw "GitHub CLI not found. Run: winget install --id GitHub.cli --exact  (then reopen PowerShell)" }

gh auth status 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Logging in to GitHub..."; gh auth login }

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (git config user.name))  { $n = Read-Host "git user.name";  git config user.name $n }
if (-not (git config user.email)) { $e = Read-Host "git user.email"; git config user.email $e }

if (-not (Test-Path ".git")) { git init -b main | Out-Null }
git add -A
git commit -m "Initial commit: MCTNet crop classification (reproduction, covariate ablation, BiGRU extension)" | Out-Null

Write-Host "Creating $Owner/$Name ($Visibility)..."
gh repo create "$Owner/$Name" "--$Visibility" --description $Description --source . --remote origin --push
if ($LASTEXITCODE -ne 0) { throw "gh repo create failed (does the repository already exist?)." }

foreach ($t in $Topics) { gh repo edit "$Owner/$Name" --add-topic $t | Out-Null }

if ($DataDir -ne "") {
  $names = @("MCTNet_Arkansas_2021_fixed.csv","MCTNet_California_2021_fixed.csv","MCTNet_Arkansas_2021_enriched_fixed.csv","MCTNet_California_2021_enriched_fixed.csv")
  $files = foreach ($n in $names) { Get-ChildItem -Path $DataDir -Recurse -Filter $n | Select-Object -First 1 -ExpandProperty FullName }
  if ($files.Count -ne 4) { throw "Could not find all 4 CSV files under $DataDir" }
  $zip = Join-Path $env:TEMP "mctnet-datasets-2021.zip"
  if (Test-Path $zip) { Remove-Item $zip }
  Compress-Archive -Path $files -DestinationPath $zip
  gh release create "v1.0-data" $zip --repo "$Owner/$Name" --title "Datasets (2021)" --notes "Sentinel-2 time series and enriched covariate CSVs used by the notebooks. Check the original data providers' terms before reuse."
}

Write-Host ""
Write-Host "Done: https://github.com/$Owner/$Name"
