@echo off
REM Build API Docker image after verifying Docker is running
call "%~dp0\check_docker.cmd"
if %ERRORLEVEL% neq 0 (
  echo Aborting build due to Docker not available.
  exit /b %ERRORLEVEL%
)
echo Building API image...
cd /d "%~dp0\..\PlacePeopleThingsAPI"
docker build --progress=plain -t placepeoplethings-api:local .
exit /b %ERRORLEVEL%

