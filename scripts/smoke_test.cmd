@echo off
REM Run smoke tests against local stack: POST then GET /api/places
setlocal enabledelayedexpansion

echo Creating smoke test place...
curl -sS -X POST http://localhost:3000/api/places -H "Content-Type: application/json" -d "{\"name\":\"Smoke Test from script\",\"description\":\"Run at %DATE% %TIME%\"}"
echo.
echo Fetching places...
curl -sS http://localhost:3000/api/places
echo.
endlocal

