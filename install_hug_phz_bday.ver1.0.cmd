@echo off
:: FILE: install_hug_phz_bday.cmd  v1.0
:: MODULE: Installer for HuggingPhaze MVP
:: DESCRIPTION: Checks dependencies, builds folder structure, writes MVP files, zips project, and confirms actions.
:: AUTHOR: Professor Tucker

SET PROJECT_ROOT=C:\src\hug-phz-bday

:: ----------------------------------------
:: Function to pause and get confirmation
:: ----------------------------------------
:confirm
setlocal
set MSG=%1
powershell -Command "$result = [System.Windows.Forms.MessageBox]::Show('%MSG%', 'HuggingPhaze Installer', 'YesNo', 'Question'); exit ($result -eq 'Yes')"
if %errorlevel%==1 (
    echo User cancelled.
    exit /b 1
)
exit /b 0

:: ----------------------------------------
:: Dependency Checks
:: ----------------------------------------
echo Checking for Git...
git --version >nul 2>&1 || (
    echo Git not found. Please install Git from https://git-scm.com/downloads
    pause
    exit /b 1
)
echo Checking for Python...
python --version >nul 2>&1 || (
    echo Python not found. Please install Python 3.11+ from https://www.python.org/downloads/
    pause
    exit /b 1
)
echo Checking for pip...
pip --version >nul 2>&1 || (
    echo pip not found. Make sure Python includes pip.
    pause
    exit /b 1
)
echo Checking for Node...
node --version >nul 2>&1 || (
    echo Node.js not found. Install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo Checking for npm...
npm --version >nul 2>&1 || (
    echo npm not found. Comes with Node.js.
    pause
    exit /b 1
)

:: ----------------------------------------
:: Create Project Folders
:: ----------------------------------------
echo Creating project folders...
set FOLDERS=frontend\public frontend\src\components backend\app\routes backend\app\utils notebooks docs
for %%f in (%FOLDERS%) do (
    set FULL_PATH=%PROJECT_ROOT%\%%f
    if not exist "%FULL_PATH%" (
        powershell -Command "$result = [System.Windows.Forms.MessageBox]::Show('Create folder: %FULL_PATH%?', 'HuggingPhaze Installer', 'YesNo', 'Question'); exit ($result -eq 'Yes')"
        if %errorlevel%==1 (
            echo Skipped folder %FULL_PATH%
        ) else (
            mkdir "%FULL_PATH%"
        )
    )
)

:: ----------------------------------------
:: Create MVP Files
:: ----------------------------------------
echo Creating MVP files...
:: Frontend index.html
set INDEX_FILE=%PROJECT_ROOT%\frontend\public\index.html
powershell -Command "$result = [System.Windows.Forms.MessageBox]::Show('Write file: %INDEX_FILE%?', 'HuggingPhaze Installer', 'YesNo', 'Question'); exit ($result -eq 'Yes')"
if %errorlevel%==0 (
echo ^<!DOCTYPE html^> > "%INDEX_FILE%"
echo ^<html lang="en"^> >> "%INDEX_FILE%"
echo ^<head^> >> "%INDEX_FILE%"
echo ^<meta charset="UTF-8"^> >> "%INDEX_FILE%"
echo ^<title^>HuggingPhaze^</title^> >> "%INDEX_FILE%"
echo ^<style^>body {background-color:#000; color:#0F0; font-family:Arial; padding:2rem;} .container {border:2px solid #0F0; box-shadow:2px 2px 8px #36454F; padding:2rem; max-width:800px; margin:auto;} button {background-color:#0F0; color:#000; padding:0.75rem 1.5rem; border:none; cursor:pointer; box-shadow:2px 2px 6px #36454F;}^</style^> >> "%INDEX_FILE%"
echo ^</head^> >> "%INDEX_FILE%"
echo ^<body^> >> "%INDEX_FILE%"
echo ^<div class="container"^> >> "%INDEX_FILE%"
echo ^<h1^>Welcome to HuggingPhaze^</h1^> >> "%INDEX_FILE%"
echo ^<p^>Your easy interface to Hugging Face for non-technical users.^</p^> >> "%INDEX_FILE%"
echo ^<button onclick="alert('Placeholder for LLM interaction')"^>Start Your Project^</button^> >> "%INDEX_FILE%"
echo ^</div^> >> "%INDEX_FILE%"
echo ^</body^> >> "%INDEX_FILE%"
echo ^</html^> >> "%INDEX_FILE%"

:: Backend main.py
set MAIN_FILE=%PROJECT_ROOT%\backend\app\main.py
powershell -Command "$result = [System.Windows.Forms.MessageBox]::Show('Write file: %MAIN_FILE%?', 'HuggingPhaze Installer', 'YesNo', 'Question'); exit ($result -eq 'Yes')"
if %errorlevel%==0 (
echo from fastapi import FastAPI > "%MAIN_FILE%"
echo app = FastAPI() >> "%MAIN_FILE%"
echo @app.get("/") >> "%MAIN_FILE%"
echo def read_root(): >> "%MAIN_FILE%"
echo     return {"message": "Welcome to HuggingPhaze backend MVP"} >> "%MAIN_FILE%"
)

:: ----------------------------------------
:: Zip the project
:: ----------------------------------------
set ZIP_FILE=%PROJECT_ROOT%\hug-phz-bday.zip
powershell -Command "$result = [System.Windows.Forms.MessageBox]::Show('Create ZIP file: %ZIP_FILE%?', 'HuggingPhaze Installer', 'YesNo', 'Question'); exit ($result -eq 'Yes')"
if %errorlevel%==0 (
powershell Compress-Archive -Path "%PROJECT_ROOT%\*" -DestinationPath "%ZIP_FILE%" -Force
)

:: ----------------------------------------
:: Completion Message
:: ----------------------------------------
powershell -Command "[System.Windows.Forms.MessageBox]::Show('HuggingPhaze MVP build complete!\nProject at: %PROJECT_ROOT%\nZIP file: %ZIP_FILE%', 'HuggingPhaze Installer')"

pause
exit
