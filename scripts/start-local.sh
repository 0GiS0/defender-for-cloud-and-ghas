#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_PID=""
WEB_PID=""

cleanup() {
  local exit_code=$?

  if [[ -n "$API_PID" ]] && kill -0 "$API_PID" 2>/dev/null; then
    kill "$API_PID" 2>/dev/null || true
  fi

  if [[ -n "$WEB_PID" ]] && kill -0 "$WEB_PID" 2>/dev/null; then
    kill "$WEB_PID" 2>/dev/null || true
  fi

  wait 2>/dev/null || true
  exit "$exit_code"
}

trap cleanup EXIT INT TERM

echo "[start-local] Restoring API dependencies"
dotnet restore "$ROOT_DIR/src/api/SensitiveDataApi.csproj"

echo "[start-local] Installing frontend dependencies"
npm install --prefix "$ROOT_DIR/src/web"

echo "[start-local] Starting API on http://localhost:5000"
ASPNETCORE_ENVIRONMENT=Development dotnet run \
  --project "$ROOT_DIR/src/api/SensitiveDataApi.csproj" \
  --urls http://0.0.0.0:5000 &
API_PID=$!

echo "[start-local] Starting frontend on http://localhost:8080"
npm run dev --prefix "$ROOT_DIR/src/web" -- --host 0.0.0.0 --port 8080 &
WEB_PID=$!

echo "[start-local] App ready"
echo "[start-local] Frontend: http://localhost:8080"
echo "[start-local] API: http://localhost:5000"
echo "[start-local] Press Ctrl+C to stop both processes"

wait "$API_PID" "$WEB_PID"