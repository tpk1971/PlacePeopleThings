param(
  [int]$maxAttempts = 30,
  [int]$intervalSec = 2
)

function Wait-ForUrl([string]$url) {
  $attempt = 0
  while ($attempt -lt $maxAttempts) {
    try {
      $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
      if ($resp.StatusCode -eq 200) { Write-Host "OK: $url"; return $true }
    } catch {
      Write-Host "Waiting for $url... ($($attempt+1)/$maxAttempts)"
    }
    Start-Sleep -Seconds $intervalSec
    $attempt++
  }
  return $false
}

# Example usage:
# .\scripts\wait_for_health.ps1 -maxAttempts 60

$apiOk = Wait-ForUrl "http://localhost:3000/api/health"
$feOk = Wait-ForUrl "http://localhost:8080/"

if (-not ($apiOk -and $feOk)) { Write-Error "One or more services did not become healthy"; exit 1 }
Write-Host "Services healthy"; exit 0
.PHONY: up down build smoke

up:
	@docker compose up -d --build db api frontend

down:
	@docker compose down

build:
	@docker compose build --no-cache api frontend

smoke:
	@./scripts/smoke_test.cmd

