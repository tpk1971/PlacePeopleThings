try {
    docker info > $null 2>&1
    Write-Host "Docker appears to be running." -ForegroundColor Green
    exit 0
} catch {
    Write-Host "Docker does not appear to be running or accessible." -ForegroundColor Red
    Write-Host "Please start Docker Desktop or ensure Docker Engine is running and you have access."
    exit 1
}

