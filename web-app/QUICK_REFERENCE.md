# MangoMart Web App - Quick Reference

## Opening the App

```bash
# Option 1: Direct file (simplest)
Open: /vercel/share/v0-project/web-app/index.html

# Option 2: Python server
cd web-app && python -m http.server 8001
# Then: http://localhost:8001

# Option 3: Node HTTP server
npx http-server web-app -p 8001
```

## Starting Backend

```bash
# Django
python manage.py runserver

# FastAPI
uvicorn main:app --reload

# Flask
python app.py
```

## Testing in Browser Console (F12)

```javascript
// Get all products
apiClient.getProducts().then(r => console.log(r))

// Get single product
apiClient.getProductById(1).then(r => console.log(r))

// Login
apiClient.login('username', 'password').then(r => console.log(r))

// Get current user
apiClient.getCurrentUser().then(r => console.log(r))

// Create product
apiClient.createProduct({
  name: 'Test Product',
  price: 99.99,
  category: 'Electronics'
}).then(r => console.log(r))

// Add to cart
app.addToCart({id: 1, name: 'Product', price: 99.99})

// Check cart
app.cart

// Navigate
app.navigate('products')
app.navigate('shops')
app.navigate('properties')
app.navigate('events')
```

## File Structure

```
web-app/
├── index.html              # Main HTML
├── js/
│   ├── api-client.js      # API client (HTTP + JWT)
│   ├── app-api.js         # Main app with API
│   ├── app.js             # Legacy app
│   ├── components.js      # UI helpers
│   └── data.js            # Demo data
├── styles/
│   ├── main.css           # Main styles + new components
│   └── animations.css     # Animations
├── API_INTEGRATION.md     # All API endpoints
├── SETUP_WITH_API.md      # Backend configuration
└── README.md              # Features & usage
```

## API Base URL

**Current:** `http://127.0.0.1:8000/api/`

**Change in:** `js/api-client.js` (line ~5)

```javascript
this.baseURL = 'http://127.0.0.1:8000/api/';
```

## Common API Calls

### Products
```javascript
// GET
apiClient.getProducts({ limit: 20, offset: 0 })
apiClient.getProductById(123)

// POST
apiClient.createProduct({ name: 'X', price: 99.99 })

// PUT
apiClient.updateProduct(123, { price: 89.99 })

// DELETE
apiClient.deleteProduct(123)
```

### Authentication
```javascript
// Login
apiClient.login('admin', 'password')

// Register
apiClient.register({
  username: 'john',
  email: 'john@example.com',
  password: 'pass123',
  firstName: 'John',
  lastName: 'Doe'
})

// Logout
apiClient.logout()

// Get token
apiClient.getAccessToken()

// Get refresh token
apiClient.getRefreshToken()
```

### Shops
```javascript
apiClient.getShops({ limit: 100 })
apiClient.getShopById(456)
apiClient.getShopProducts(456)
```

### Properties
```javascript
apiClient.getProperties({ limit: 50 })
apiClient.getPropertyById(789)
apiClient.createProperty({
  name: 'Apt',
  location: 'City',
  price: 50000
})
```

### Events
```javascript
apiClient.getEvents({ limit: 100 })
apiClient.getEventById(111)
apiClient.createEvent({
  name: 'Concert',
  date: '2024-06-15',
  price: 50
})
```

### Cart & Orders
```javascript
apiClient.getCart()
apiClient.addToCart(productId, quantity)
apiClient.removeFromCart(cartItemId)
apiClient.createOrder({ items: [...], total: 199.97 })
apiClient.getOrders()
```

### Payments
```javascript
apiClient.initiatePayment({
  property_id: 789,
  amount: 50000,
  payment_method: 'card'
})
apiClient.checkPaymentStatus('REF123456')
apiClient.getMyPayments()
```

## Enable CORS (Django)

```python
# settings.py
INSTALLED_APPS = [
    'corsheaders',
    # ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    # ...
]

CORS_ALLOWED_ORIGINS = [
    "http://127.0.0.1:8001",
    "http://localhost:8001",
]
```

## Enable CORS (FastAPI)

```python
# main.py
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:8001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| CORS Error | Configure CORS on backend |
| Server not found | Check backend is running |
| 401 Unauthorized | Login with correct credentials |
| Products not loading | Check products exist in database |
| Cart not saving | Check localStorage enabled |
| Token expired | App auto-refreshes (check logs) |

## Check if Working

1. **Open browser console** (F12)
2. **No red errors** - Good sign!
3. **Run:** `apiClient.getProducts()`
4. **See data** - API working!
5. **Check Network tab** - All 200 status
6. **Login** - `apiClient.login('admin', 'password')`
7. **See user** - `app.currentUser`

## Important Files

| File | Purpose |
|------|---------|
| `js/api-client.js` | HTTP client, JWT auth |
| `js/app-api.js` | Main app logic |
| `index.html` | UI structure |
| `styles/main.css` | All styling |
| `API_INTEGRATION.md` | Complete API docs |
| `SETUP_WITH_API.md` | Backend setup |

## Key Properties

```javascript
app.currentUser      // User object or null
app.products         // Array of products
app.shops            // Array of shops
app.properties       // Array of properties
app.events           // Array of events
app.cart             // Shopping cart array
app.currentPage      // Current page name
app.isLoading        // Is app loading?
```

## Key Methods

```javascript
app.navigate(page)                    // Go to page
app.addToCart(product)               // Add item
app.removeFromCart(index)            // Remove item
app.renderProducts()                 // Render page
app.showNotification(msg, type)      // Show message
app.filterProducts()                 // Search & filter
apiClient.login(user, pass)         // Login
apiClient.logout()                  // Logout
apiClient.healthCheck()             // Check API
```

## localStorage Keys

```javascript
localStorage.getItem('access_token')   // JWT token
localStorage.getItem('refresh_token')  // Refresh token
localStorage.getItem('user_id')        // User ID
localStorage.getItem('username')       // Username
localStorage.getItem('user_data')      // User object
localStorage.getItem('cart')           // Cart array
```

## Debugging

```javascript
// Check if API available
apiClient.healthCheck().then(ok => console.log('API OK:', ok))

// See all requests
// Open DevTools > Network tab
// Filter by "XHR" to see API calls

// Check tokens
console.log('Token:', apiClient.getAccessToken())
console.log('User:', app.currentUser)
console.log('Cart:', app.cart)

// Check response format
apiClient.getProducts().then(res => {
  console.log('Full response:', res)
  console.log('Has results:', res.results)
  console.log('Count:', res.count)
})
```

## Tips & Tricks

1. **Clear cache** - Ctrl+Shift+Delete
2. **Force reload** - Ctrl+Shift+R
3. **Mobile view** - F12 → Toggle device toolbar
4. **Console shortcuts:**
   - `clear()` - Clear console
   - `copy(app.cart)` - Copy to clipboard
   - `JSON.stringify(app)` - See all properties

5. **Network debugging:**
   - Filter: "XHR" to see API calls only
   - Check "Headers" tab for Authorization
   - Check "Response" tab for server data
   - Check "Status" code (200 = OK, 401 = auth, 500 = error)

## Response Formats

### List Endpoint
```json
{
  "count": 100,
  "next": "url?page=2",
  "previous": null,
  "results": [...]
}
```

### Single Item
```json
{
  "id": 1,
  "name": "Product",
  "price": 99.99
}
```

### Login
```json
{
  "access": "token...",
  "refresh": "token..."
}
```

## Pages Available

```
/home              - Main/featured
/products          - All products
/shops             - All shops
/properties        - Properties list
/events            - Events list
/hospitality       - Lodges
/cart              - Shopping cart
/profile           - User profile
/auth              - Login/register
```

Access via: `app.navigate('products')`

## Performance Notes

- Data loaded once, cached in memory
- Cart saved to localStorage (instant access)
- Pagination supported (add `limit` param)
- Demo data loads instantly when offline
- No re-fetching same data

## Security (Production)

1. Use HTTPS for all connections
2. Move tokens to HttpOnly cookies
3. Add CSRF protection
4. Implement rate limiting
5. Validate all inputs
6. Use environment variables for API URL

---

## Quick Links

- **Full API docs:** API_INTEGRATION.md
- **Backend setup:** SETUP_WITH_API.md
- **Features:** README.md
- **Configuration:** QUICKSTART.md
- **Getting started:** WEB_APP_START_HERE.md

## Need Help?

1. Check browser console (F12) for errors
2. Check Network tab for failed requests
3. Read API_INTEGRATION.md
4. Read SETUP_WITH_API.md
5. Check backend logs

---

**Last Updated:** May 2024  
**Version:** 2.0 (with API)  
**Status:** Production Ready ✅
