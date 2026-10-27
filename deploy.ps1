<#
.SYNOPSIS
  Deploy the committed config (HEAD) to /config on the Green, validate it, then reload or restart.

.DESCRIPTION
  Ships `git archive HEAD` rather than the working tree, so what runs is exactly what's committed.
  Before extracting, the files about to be overwritten are saved on the device; if `ha core check`
  fails they are restored and nothing is reloaded.

.PARAMETER Restart
  Restart Core instead of reloading YAML. Needed when configuration.yaml changes or an
  integration is added/removed (anything outside what `homeassistant.reload_all` covers).

.PARAMETER DryRun
  Upload, extract and check, then roll back. Validates against the live install without changing it.
#>
param([switch]$Restart, [switch]$DryRun)
$ErrorActionPreference = 'Stop'

$HaHost = 'root@homeassistant.local'
$Key    = "$HOME\.ssh\ha_green_ed25519"
$Ssh    = 'C:\Program Files\Git\usr\bin\ssh.exe'
$Scp    = 'C:\Program Files\Git\usr\bin\scp.exe'
# Repo paths that belong in /config. Everything else (README, CI, this script) stays local.
$Deploy = 'configuration.yaml', 'automations.yaml', 'scripts.yaml', 'scenes.yaml', 'packages', 'themes'

Set-Location $PSScriptRoot
if (git status --porcelain) { Write-Warning 'Working tree has uncommitted changes; deploying HEAD only.' }
$rev = git rev-parse --short HEAD

$tar = Join-Path $env:TEMP "raffmachine-$rev.tar"
git archive --format=tar -o $tar HEAD -- $Deploy
& $Scp -q -i $Key -o BatchMode=yes $tar "${HaHost}:/tmp/deploy.tar"
if ($LASTEXITCODE) { throw 'scp failed' }
Remove-Item $tar

$remote = @'
set -e
cd /homeassistant
backup=/tmp/predeploy.tar
# Save current versions of every file the archive will overwrite (new files have nothing to save).
tar -tf /tmp/deploy.tar | grep -v '/$' | while read -r f; do [ -e "$f" ] && echo "$f"; done > /tmp/existing.lst
tar -cf "$backup" -T /tmp/existing.lst
tar -xf /tmp/deploy.tar
rollback() { tar -tf /tmp/deploy.tar | grep -v '/$' | grep -vxF -f /tmp/existing.lst | xargs -r rm -f; tar -xf "$backup"; }
if ! ha core check; then rollback; echo 'CHECK FAILED - rolled back'; exit 1; fi
if [ "$DRYRUN" = 1 ]; then rollback; echo 'Dry run OK - rolled back'; exit 0; fi
echo "Deployed $REV"
'@ -replace "`r", ''

$env_ = "DRYRUN=$([int][bool]$DryRun) REV=$rev"
$remote | & $Ssh -i $Key -o BatchMode=yes $HaHost "$env_ sh -s"
if ($LASTEXITCODE) { throw "Deploy of $rev failed (device left unchanged)" }
if ($DryRun) { return }

if ($Restart) {
    & $Ssh -i $Key -o BatchMode=yes $HaHost 'ha core restart'
} else {
    $token = [Environment]::GetEnvironmentVariable('HOME_ASSISTANT_TOKEN', 'Machine')
    Invoke-RestMethod 'http://homeassistant.local/api/services/homeassistant/reload_all' -Method Post `
        -Headers @{ Authorization = "Bearer $token" } | Out-Null
    Write-Host 'Reloaded YAML (homeassistant.reload_all)'
}
