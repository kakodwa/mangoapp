@echo off
REM MangoMart Backend Setup Script for Windows
REM This script automates the backend setup process

echo ================================
echo MangoMart Backend Setup (Windows)
echo ================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8 or higher from https://www.python.org/
    pause
    exit /b 1
)

echo Python found: 
python --version
echo.

REM Step 1: Create virtual environment
echo Step 1: Creating virtual environment...
if not exist "venv" (
    python -m venv venv
    echo Virtual environment created
) else (
    echo Virtual environment already exists
)

REM Activate virtual environment
echo Step 2: Activating virtual environment...
call venv\Scripts\activate.bat
echo Virtual environment activated
echo.

REM Step 3: Install dependencies
echo Step 3: Installing dependencies...
pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt >nul 2>&1
echo Dependencies installed
echo.

REM Step 4: Apply migrations
echo Step 4: Running migrations...
python manage.py migrate >nul 2>&1
echo Migrations applied
echo.

REM Step 5: Create superuser (optional)
echo Step 5: Create superuser (optional)
echo If you haven't created a superuser yet, you can do it now
echo.
echo To create superuser, run:
echo   python manage.py createsuperuser
echo.

REM Step 6: Start server
echo Step 6: Starting development server...
echo.
echo ================================
echo Server starting...
echo URL: http://127.0.0.1:8000/api/
echo Admin: http://127.0.0.1:8000/admin/
echo ================================
echo.
echo Keep this window open while developing.
echo Press Ctrl+C to stop the server.
echo.

python manage.py runserver
pause
