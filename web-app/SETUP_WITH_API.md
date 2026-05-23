# Setting Up MangoMart Web App with API

## Quick Start (5 minutes)

### Step 1: Ensure Backend is Running

The web app expects the backend API at `http://127.0.0.1:8000/api/`

**Option A: Run your existing backend**
```bash
# In your backend directory (e.g., Django)
cd backend/
python manage.py runserver
```

**Option B: Using Docker**
```bash
docker-compose up
```

**Option C: Using ngrok (for remote testing)**
```bash
ngrok http 8000
# Update baseURL in js/api-client.js to the ngrok URL
```

### Step 2: Open the Web App

```bash
# Option 1: Direct file open (simplest)
# Open: /vercel/share/v0-project/web-app/index.html in your browser

# Option 2: Local HTTP server
cd /vercel/share/v0-project/web-app
python -m http.server 8001
# Then open: http://localhost:8001

# Option 3: Python SimpleHTTPServer
python -m SimpleHTTPServer 8001

# Option 4: Node.js HTTP Server
npx http-server -p 8001

# Option 5: Live Server (VSCode)
# Install extension, right-click index.html, select "Open with Live Server"
```

### Step 3: Start Using the App

1. Open http://127.0.0.1:8001 (or file:// path)
2. Browse products, shops, properties
3. Login with your credentials (from backend)
4. Add items to cart
5. Checkout

## Detailed Setup

### Prerequisites

- Backend API running at `http://127.0.0.1:8000/api/`
- Modern web browser (Chrome, Firefox, Safari, Edge)
- (Optional) Python 3+ or Node.js for HTTP server

### Backend API Requirements

Your backend must provide these endpoints:

**Authentication**
- `POST /api/token/` - Login (returns access/refresh tokens)
- `POST /api/token/refresh/` - Refresh token
- `POST /api/users/register/` - Register new user
- `GET /api/users/me/` - Get current user

**Products**
- `GET /api/products/` - List products (with pagination)
- `GET /api/products/{id}/` - Get single product
- `POST /api/products/` - Create product
- `PUT /api/products/{id}/` - Update product
- `DELETE /api/products/{id}/` - Delete product

**Shops**
- `GET /api/shops/` - List shops
- `GET /api/shops/{id}/` - Get shop details

**Properties**
- `GET /api/properties/` - List properties
- `GET /api/properties/{id}/` - Get property details

**Events**
- `GET /api/events/` - List events
- `GET /api/events/{id}/` - Get event details

**Banners**
- `GET /api/banners/` - Get banners

**Cart & Orders**
- `GET /api/cart/` - Get cart
- `POST /api/cart/add/` - Add to cart
- `DELETE /api/cart/{id}/` - Remove from cart
- `POST /api/orders/` - Create order
- `GET /api/orders/` - Get user orders

**Payments**
- `POST /api/payments/initiate_payment/` - Start payment
- `GET /api/payments/check_payment_status/` - Check payment
- `GET /api/payments/my_payments/` - Get payment history

### Configuration

#### 1. Change API Base URL

Edit `js/api-client.js`:

```javascript
class ApiClient {
  constructor() {
    // Change this line
    this.baseURL = 'http://127.0.0.1:8000/api/';
    
    // For production:
    // this.baseURL = 'https://api.yourdomain.com/api/';
```

#### 2. Enable CORS on Backend

Your backend must allow requests from the web app:

**Django (settings.py)**
```python
INSTALLED_APPS = [
    ...
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    ...
]

CORS_ALLOWED_ORIGINS = [
    "http://127.0.0.1:8001",
    "http://localhost:8001",
    "http://localhost:3000",
    "http://localhost:8000",
    # For production
    "https://yourdomain.com",
]

# Allow credentials
CORS_ALLOW_CREDENTIALS = True
```

**FastAPI (main.py)**
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:8001",
        "http://localhost:8001",
        "http://localhost:3000",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Flask (app.py)**
```python
from flask_cors import CORS

CORS(app, origins=[
    "http://127.0.0.1:8001",
    "http://localhost:8001",
    "http://localhost:3000",
])
```

#### 3. JWT Token Configuration

Backend must return JWT tokens in this format:

```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

Web app will:
- Store tokens in localStorage
- Send access token in Authorization header
- Auto-refresh when token expires (401 response)

### Testing

#### 1. Check Server Connection

Open browser console (F12) and run:

```javascript
// Should return true if server is available
await apiClient.healthCheck()
```

#### 2. Test API Endpoints

```javascript
// Get products
apiClient.getProducts().then(res => {
  console.log('Products:', res);
}).catch(err => {
  console.error('Error:', err);
});

// Login
apiClient.login('admin', 'password').then(res => {
  console.log('Login successful:', res);
}).catch(err => {
  console.error('Login error:', err);
});

// Get current user
apiClient.getCurrentUser().then(user => {
  console.log('User:', user);
}).catch(err => {
  console.error('Error:', err);
});
```

#### 3. Check Network Requests

1. Open DevTools (F12)
2. Go to Network tab
3. Refresh page
4. Look for API requests:
   - Should see requests to http://127.0.0.1:8000/api/
   - Check status: 200 OK = good, 401 = auth error, 500 = server error
5. Click request to see:
   - Request headers (Authorization)
   - Response data (JSON)

#### 4. Troubleshoot Connection Issues

**CORS Error**
```
Access to XMLHttpRequest at 'http://127.0.0.1:8000/api/products/' 
from origin 'http://127.0.0.1:8001' has been blocked by CORS policy
```
Solution: Configure CORS on backend (see above)

**Network Error / Connection Refused**
```
TypeError: Failed to fetch
```
Solution:
- Check backend is running
- Check URL is correct (http://127.0.0.1:8000/api/)
- Try http://localhost:8000/api/ instead
- Check firewall isn't blocking

**401 Unauthorized**
```
Unauthorized: Please login again
```
Solution:
- Login with correct credentials
- Check backend user exists
- Check JWT is being sent (see Network tab)

**500 Internal Server Error**
```
Server returned 500 error
```
Solution:
- Check backend error logs
- Check request data format
- Verify database is connected
- Check backend migrations ran

### Production Deployment

#### 1. Update API URL

```javascript
// In js/api-client.js
this.baseURL = 'https://api.yourdomain.com/api/';
```

#### 2. Deploy Frontend

**Option A: Vercel**
```bash
vercel --prod
```

**Option B: Netlify**
```bash
netlify deploy --prod --dir=web-app
```

**Option C: GitHub Pages**
```bash
git subtree push --prefix web-app origin gh-pages
```

**Option D: Traditional Hosting**
- Upload web-app/ folder via FTP
- Set web root to web-app/

#### 3. Deploy Backend

Deploy your backend API to production server

#### 4. Update CORS

Add production URLs to backend CORS config:

```python
CORS_ALLOWED_ORIGINS = [
    "https://yourdomain.com",
    "https://app.yourdomain.com",
]
```

#### 5. Use HTTPS

- Frontend and backend must use HTTPS
- Use secure cookies for tokens (optional)
- Configure SSL certificates

### Demo Mode

If backend is unavailable, app automatically uses demo data:

```javascript
// Demo data is in js/data.js
window.productsData = [...]
window.shopsData = [...]
window.propertiesData = [...]
window.eventsData = [...]
```

This allows:
- Development without backend
- Testing UI/UX
- Offline browsing
- Demo presentations

To disable demo mode:

```javascript
// In app-api.js, comment out:
// this.loadDemoData();
```

### Development Tips

#### 1. Live Reload

Use auto-reload for faster development:

```bash
# Install http-server with auto-reload
npm install -g http-server
http-server web-app -p 8001 -c-1
```

#### 2. Debug API Calls

Enable detailed logging in api-client.js:

```javascript
async request(method, endpoint, options = {}) {
  const url = new URL(this.baseURL + endpoint);
  console.log(`[API] ${method.toUpperCase()} ${endpoint}`, options);
  // ... rest of code
}
```

#### 3. Mock API Responses

For testing without backend:

```javascript
// Override fetch in browser console
window.originalFetch = fetch;
window.fetch = async (url, config) => {
  console.log('Mock fetch:', url);
  return new Response(JSON.stringify({
    results: [/* mock data */]
  }));
};
```

#### 4. Inspect Storage

```javascript
// Check localStorage
localStorage.getItem('access_token')
localStorage.getItem('cart')
localStorage.getItem('user_data')

// Clear all
localStorage.clear()

// View all items
for (let i = 0; i < localStorage.length; i++) {
  console.log(localStorage.key(i), ':', localStorage.getItem(localStorage.key(i)));
}
```

### Performance Optimization

#### 1. Caching

```javascript
// Data is cached in app properties
app.products   // Loaded once from API
app.shops      // Reused for all pages
app.properties // No re-fetching
```

#### 2. Pagination

```javascript
// Limit results to improve load time
apiClient.getProducts({ 
  limit: 20,      // Get 20 items
  offset: 0       // Skip 0 items
})
```

#### 3. Image Optimization

```html
<!-- Use placeholder images -->
<img src="image.jpg" 
     alt="Product"
     loading="lazy"
     onerror="this.src='placeholder.jpg'">
```

#### 4. Minimize API Calls

```javascript
// Load data once
if (this.products.length === 0) {
  await loadFromAPI();
} else {
  useCache();
}
```

## Troubleshooting

### App Won't Load

1. Check browser console (F12) for errors
2. Check Network tab for failed requests
3. Verify all files exist (check DevTools Sources tab)
4. Clear browser cache (Ctrl+Shift+Delete)
5. Try different browser

### Login Not Working

1. Verify backend `/api/token/` endpoint works
2. Check username/password are correct
3. Check backend user exists in database
4. Check JWT is being sent (Network tab)
5. Check CORS is configured

### Products Not Loading

1. Check `/api/products/` endpoint returns data
2. Verify products exist in backend database
3. Check authorization (should be accessible without login)
4. Check pagination (limit/offset parameters)
5. Review API response format

### Cart Not Persisting

1. Check browser allows localStorage
2. Verify localStorage is not disabled
3. Check storage space (quota limit)
4. Try clearing storage and reloading
5. Check browser's private/incognito mode

### API Endpoints Timing Out

1. Check backend server is running
2. Check network connection
3. Increase timeout in api-client.js:
   ```javascript
   this.timeout = 60000; // 60 seconds
   ```
4. Check backend logs for slow queries
5. Optimize database queries

## Getting Help

1. **Check logs** - DevTools Console (F12)
2. **Check network** - DevTools Network tab
3. **Read docs** - This file + API_INTEGRATION.md
4. **Backend docs** - Check backend API documentation
5. **Test endpoints** - Use cURL or Postman

## Success Checklist

- [x] Backend API running at http://127.0.0.1:8000/api/
- [x] CORS configured on backend
- [x] Web app loading without errors
- [x] Demo data appearing
- [x] Can login with valid credentials
- [x] Products loading from API
- [x] Cart persisting across reload
- [x] All pages rendering correctly
- [x] No console errors
- [x] Network requests successful (200 status)

Once all items are checked, your setup is complete!
