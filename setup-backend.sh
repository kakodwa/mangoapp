#!/bin/bash

# MangoMart Backend Setup Script
# This script automates the backend setup process

echo "================================"
echo "MangoMart Backend Setup"
echo "================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

echo "✓ Python found: $(python3 --version)"
echo ""

# Step 1: Create virtual environment
echo "Step 1: Creating virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Activate virtual environment
echo "Step 2: Activating virtual environment..."
source venv/bin/activate
echo "✓ Virtual environment activated"
echo ""

# Step 3: Install dependencies
echo "Step 3: Installing dependencies..."
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1
echo "✓ Dependencies installed"
echo ""

# Step 4: Apply migrations
echo "Step 4: Running migrations..."
python manage.py migrate > /dev/null 2>&1
echo "✓ Migrations applied"
echo ""

# Step 5: Create superuser (optional)
echo "Step 5: Create superuser? (optional)"
echo "If you haven't created a superuser yet, do it now:"
echo ""
echo "To create superuser:"
echo "  python manage.py createsuperuser"
echo ""

# Step 6: Start server
echo "Step 6: Starting development server..."
echo ""
echo "================================"
echo "Server starting..."
echo "URL: http://127.0.0.1:8000/api/"
echo "Admin: http://127.0.0.1:8000/admin/"
echo "================================"
echo ""
echo "Keep this terminal open while developing."
echo "Press Ctrl+C to stop the server."
echo ""

python manage.py runserver
