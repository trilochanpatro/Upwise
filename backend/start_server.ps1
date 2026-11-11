$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "Starting Upwise FastAPI backend on http://0.0.0.0:8000 ..." -ForegroundColor Cyan
.\.venv\Scripts\uvicorn.exe app.main:app --host 0.0.0.0 --port 8000
