#!/usr/bin/env bash

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker CLI not found. Install Docker and ensure it's on PATH."
  exit 2
fi

if docker info >/dev/null 2>&1; then
  echo "Docker is running."
  exit 0
else
  echo "Docker does not appear to be running or accessible."
  exit 1
fi
@echo off
REM Check if docker CLI is available and Docker Engine is running
where docker >nul 2>&1
if %ERRORLEVEL% neq 0 (
  echo Docker CLI not found. Please install Docker Desktop and ensure 'docker' is on PATH.
  exit /b 2
)

docker info >nul 2>&1
if %ERRORLEVEL% equ 0 (
  echo Docker is running.
  exit /b 0
) else (
  echo Docker does not appear to be running or accessible.
  echo Please start Docker Desktop or ensure Docker Engine is running and you have access.
  exit /b 1
)

