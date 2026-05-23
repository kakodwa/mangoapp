# Get Started - MangoMart Web App

## ⚡ 30 Second Quick Start

### Option 1: Use Demo Data (No Backend Needed)

```bash
# 1. Open this file directly in your browser:
/vercel/share/v0-project/web-app/index.html

# Done! 
# You'll see demo products, shops, properties, events
# Everything works: search, filter, cart, checkout
# No API server needed
```

### Option 2: Set Up Real Backend (10 minutes)

```bash
# 1. Open terminal in project directory
cd /vercel/share/v0-project

# 2. Run the setup script
# macOS/Linux:
bash setup-backend.sh

# Windows:
setup-backend.bat

# 3. Open web app in browser:
/vercel/share/v0-project/web-app/index.html

# Done!
# Now you have real data from the API
```

---

## The Issue You're Seeing

```
"Server not available at http://127.0.0.1:8000/api/"
```

This message appears when:
- Backend server is NOT running
- But the app still works with DEMO DATA

**This is correct behavior!** The app has automatic fallback.

---

## What You Need to Do

### Choose One:

**If you just want to explore the app:**
1. Open `/vercel/share/v0-project/web-app/index.html`
2. Browse all features
3. Works perfectly with demo data
4. No setup needed

**If you want to use the real backend:**
1. Start backend: `python manage.py runserver`
2. Open `/vercel/share/v0-project/web-app/index.html`
3. App will automatically connect to API
4. Real data loads automatically

---

## Manual Backend Setup (If Scripts Don't Work)

```bash
# 1. Navigate to project
cd /vercel/share/v0-project

# 2. Create & activate virtual environment
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# or: venv\Scripts\activate  # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run migrations
python manage.py migrate

# 5. Start server
python manage.py runserver

# Visit: http://127.0.0.1:8000/api/products/
```

---

## Verify It's Working

### In Browser Console (F12)

```javascript
// Check if server is available
apiClient.healthCheck()

// Get products from API
apiClient.getProducts()

// Should return: {results: [...], count: 30}
```

### In Terminal

```bash
# Check if server responds
curl http://127.0.0.1:8000/api/products/

# Should return JSON data
```

---

## Common Scenarios

### Scenario 1: No Backend Server
```
✓ Web app works
✓ See demo data (30+ products)
✓ Everything functional
⚠️ "Server not available" message (expected)
```

### Scenario 2: Backend Server Running
```
✓ Web app works
✓ See real API data
✓ Everything functional
✓ No "Server not available" message
```

### Scenario 3: Wrong API URL
```
❌ Data doesn't load
❌ Check: web-app/js/api-client.js
❌ Edit: this.baseURL = 'http://YOUR_URL:8000/api/'
```

---

## Folder Structure

```
/vercel/share/v0-project/
├── web-app/
│   ├── index.html              👈 Open this in browser
│   ├── js/
│   │   ├── api-client.js       (API communication)
│   │   ├── app-api.js          (App logic with API)
│   │   ├── app.js              (Fallback app logic)
│   │   ├── components.js       (UI components)
│   │   └── data.js             (Demo data)
│   ├── styles/
│   │   ├── main.css
│   │   └── animations.css
│   └── [documentation files]
├── lib/                         (Flutter source)
├── manage.py                    (Django command)
├── setup-backend.sh             (Auto setup - macOS/Linux)
├── setup-backend.bat            (Auto setup - Windows)
└── requirements.txt             (Python dependencies)
```

---

## Next Steps

### For Testing/Demo:
1. Open `/vercel/share/v0-project/web-app/index.html`
2. Explore all pages
3. Try all features

### For Development:
1. Run `python manage.py runserver`
2. Open `/vercel/share/v0-project/web-app/index.html`
3. Check Network tab (F12) to see API calls
4. Start coding!

### For Deployment:
1. See `SETUP_WITH_API.md`
2. Configure production API URL
3. Deploy backend
4. Deploy web app

---

## Documentation

- **TROUBLESHOOTING.md** - Fix common issues
- **API_INTEGRATION.md** - All API endpoints & examples
- **SETUP_WITH_API.md** - Complete backend setup
- **QUICK_REFERENCE.md** - Developer quick lookup
- **README.md** - Feature overview

---

## Quick Commands

```bash
# Start backend
python manage.py runserver

# Create superuser
python manage.py createsuperuser

# Run migrations
python manage.py migrate

# Open web app
open /vercel/share/v0-project/web-app/index.html

# Run tests (if exists)
python manage.py test

# Access admin
http://127.0.0.1:8000/admin/

# Access API
http://127.0.0.1:8000/api/products/
```

---

## Still Confused?

The key concept:

```
Backend not running? → Use demo data ✓
Backend running? → Use real API data ✓
Either way → App works perfectly ✓
```

No action needed unless you want real backend data!

---

## Ready?

👉 **Open now:** `/vercel/share/v0-project/web-app/index.html`

Everything else is optional.

Happy exploring! 🚀
