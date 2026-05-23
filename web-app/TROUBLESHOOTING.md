# Troubleshooting Guide - MangoMart Web App

## Issue: "Server not available at http://127.0.0.1:8000/api/"

This is actually expected behavior! The app has a smart fallback system.

### What's Happening

```
✓ App starts → Tries to connect to API → Server not running → Falls back to demo data
```

This means your web app is working correctly - it's just that the backend server isn't running yet.

---

## Solution 1: Run the Django Backend (Recommended)

### Prerequisites
- Python 3.8+
- Django installed
- Your backend code in `/vercel/share/v0-project/`

### Steps

**1. Navigate to project root**
```bash
cd /vercel/share/v0-project
```

**2. Create virtual environment (if not exists)**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

**3. Install dependencies**
```bash
pip install -r requirements.txt
```

**4. Run migrations**
```bash
python manage.py migrate
```

**5. Create superuser (optional)**
```bash
python manage.py createsuperuser
```

**6. Start the server**
```bash
python manage.py runserver
```

You should see:
```
Starting development server at http://127.0.0.1:8000/
```

### Verify Server is Running

**In browser console (F12):**
```javascript
apiClient.healthCheck()
```

Should return `true` if server is running.

---

## Solution 2: Use Demo Mode (No Backend Needed)

If you don't have a backend set up yet, the web app works perfectly with demo data!

### What You Get
- 30+ sample products
- 6 sample shops
- 6 sample properties
- 3 sample events
- Working cart, search, filters
- UI fully functional
- No API calls needed

### How to Use Demo Mode

1. **Open the web app**
   ```
   File: /vercel/share/v0-project/web-app/index.html
   ```

2. **You'll see a message:**
   ```
   ⚠️ Could not connect to server at http://127.0.0.1:8000/api/
   Using demo data instead.
   ```

3. **Browse all features** - Everything works with demo data
   - View products
   - Search and filter
   - Add to cart
   - Checkout flow
   - User profile

4. **When backend is ready:**
   - Start the backend
   - Refresh the web app
   - It will automatically switch to live API data

---

## Quick Checklist

### Backend Not Running?
- [ ] Is backend installed?
- [ ] Virtual environment activated?
- [ ] Dependencies installed? (`pip install -r requirements.txt`)
- [ ] Database migrated? (`python manage.py migrate`)
- [ ] Backend started? (`python manage.py runserver`)

### Check Backend is Working

**Option 1: Browser**
```
http://127.0.0.1:8000/api/products/
```
Should show JSON data or 404 error (not "connection refused")

**Option 2: Console**
```javascript
// In browser F12 console
apiClient.getProducts()
```

**Option 3: Terminal**
```bash
curl http://127.0.0.1:8000/api/products/
```

---

## Common Issues

### 1. "Connection Refused"
```
Error: Failed to fetch
Network error at http://127.0.0.1:8000/api/
```

**Solution:** Backend is not running
```bash
python manage.py runserver
```

### 2. CORS Error
```
Access to fetch at 'http://127.0.0.1:8000/api/' from origin 'file://' 
has been blocked by CORS policy
```

**Solution 1:** Add CORS headers to backend

**For Django:**
```bash
pip install django-cors-headers
```

In `settings.py`:
```python
INSTALLED_APPS = [
    'corsheaders',
    ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    ...
]

CORS_ALLOWED_ORIGINS = [
    "http://127.0.0.1:8001",
    "http://localhost:8001",
    "http://127.0.0.1:3000",
    "http://localhost:3000",
    "file://",  # For local file:// URLs
]
```

**Solution 2:** Run web app from server instead of file
```bash
cd /vercel/share/v0-project/web-app
python -m http.server 8001
```
Then open: `http://127.0.0.1:8001`

### 3. "Invalid Token" Error
```
Unauthorized: Please login again
```

**Solution:** Clear stored tokens and login again
```javascript
// In browser console
localStorage.clear()
```
Then refresh page and login with valid credentials.

### 4. No Data Shows Up
```
Products: 0
Shops: 0
Properties: 0
```

**Check:**
1. Is demo data loaded? (Check console)
2. Is API data loaded? (Check Network tab)
3. Does backend have data?

```javascript
// In console
console.log(app.products)
console.log(app.shops)
app.cart
```

---

## Testing the API

### In Browser Console (F12)

```javascript
// Health check
apiClient.healthCheck()

// Get products
apiClient.getProducts()

// Get shops
apiClient.getShops()

// Login
apiClient.login('admin', 'password')

// Check current user
apiClient.getCurrentUser()

// Check app state
app.products.length
app.shops.length
app.cart
app.currentUser
```

### Using cURL (Terminal)

```bash
# Get products
curl http://127.0.0.1:8000/api/products/

# Login
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# Get with auth
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://127.0.0.1:8000/api/users/me/
```

---

## Verify Everything is Working

### Checklist

- [ ] Backend running: `python manage.py runserver`
- [ ] Web app opens: `/vercel/share/v0-project/web-app/index.html`
- [ ] No console errors (F12)
- [ ] Products load (check Network tab)
- [ ] Can login with valid credentials
- [ ] Cart persists after refresh
- [ ] All pages render correctly

### Expected in Console (F12)

```
[v0] App initializing...
[v0] Server available, loading data from API
[API] GET products/ {}
[v0] Loaded products: 30
[API] GET shops/ {}
[v0] Loaded shops: 6
... (similar for other endpoints)
✅ All data loaded successfully
```

---

## Backend Setup Reference

### Complete Django Setup

```bash
# 1. Navigate to project
cd /vercel/share/v0-project

# 2. Activate virtual environment
python -m venv venv
source venv/bin/activate

# 3. Install packages
pip install django djangorestframework django-cors-headers python-decouple pillow

# 4. Install project dependencies
pip install -r requirements.txt

# 5. Apply migrations
python manage.py migrate

# 6. Create admin user
python manage.py createsuperuser

# 7. Run server
python manage.py runserver
```

### Test with curl
```bash
# 1. Get products
curl http://127.0.0.1:8000/api/products/

# 2. Login
TOKEN=$(curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}' | jq -r '.access')

# 3. Use token
curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8000/api/users/me/
```

---

## Still Having Issues?

### Check the Logs

**Backend logs (Terminal):**
```
Watch the terminal running "python manage.py runserver"
Look for any error messages
```

**Browser console (F12):**
```
Press F12 → Console tab
Look for any error messages
Check the Network tab for API requests
```

### Debug Commands

```javascript
// Check API client
console.log(apiClient)
console.log(apiClient.baseURL)

// Check app state
console.log(app)
console.log(app.currentPage)
console.log(app.products)

// Force reload demo data
app.loadDemoData()
app.navigate('home')

// Clear everything and restart
localStorage.clear()
location.reload()
```

---

## Next Steps

1. **Set up backend:**
   ```bash
   python manage.py runserver
   ```

2. **Open web app:**
   - Direct: `/vercel/share/v0-project/web-app/index.html`
   - Or server: `http://127.0.0.1:8001`

3. **Verify in console:**
   ```javascript
   apiClient.healthCheck()
   apiClient.getProducts()
   ```

4. **Explore the app** - All features should work now!

---

## Support

If you're still having issues:

1. **Read the documentation:**
   - `API_INTEGRATION.md` - API reference
   - `SETUP_WITH_API.md` - Backend setup
   - `README.md` - Features guide

2. **Check the console:**
   - F12 → Console tab
   - F12 → Network tab
   - Look for error messages

3. **Verify backend:**
   - Is it running?
   - Does it have data?
   - Are CORS headers set?

4. **Test with cURL:**
   ```bash
   curl http://127.0.0.1:8000/api/products/
   ```

Happy coding! 🚀
