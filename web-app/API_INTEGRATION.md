# MangoMart Web App - API Integration Guide

## Overview

The web app is now **fully integrated with the backend API** (same as Flutter app). It automatically:

1. Connects to API at `http://127.0.0.1:8000/api/`
2. Falls back to demo data if server is unavailable
3. Handles JWT authentication
4. Manages user sessions and tokens
5. Performs all CRUD operations through the API

## Architecture

### Files Structure

```
web-app/
├── js/
│   ├── api-client.js      # API HTTP client with JWT auth
│   ├── app-api.js         # Main app logic with API integration
│   ├── app.js             # Legacy (deprecated)
│   ├── components.js      # UI components helper
│   └── data.js            # Demo data fallback
├── styles/
│   ├── main.css           # Core styles + new UI elements
│   └── animations.css     # Animations
└── index.html             # HTML structure
```

## API Client Usage

### Creating API Client Instance

```javascript
// Automatically created as window.apiClient
// Access from anywhere in the app

apiClient.get('products/')          // GET request
apiClient.post('orders/', data)     // POST request
apiClient.put('products/1/', data)  // PUT request
apiClient.patch('products/1/', data) // PATCH request
apiClient.delete('products/1/')     // DELETE request
```

### Authentication

```javascript
// Login
await apiClient.login('username', 'password');
// Tokens saved to localStorage automatically

// Logout
await apiClient.logout();
// Tokens cleared from localStorage

// Check if logged in
const token = apiClient.getAccessToken();
if (token) {
  // User is logged in
}

// Get current user
const user = await apiClient.getCurrentUser();

// Token refresh (automatic on 401)
await apiClient.refreshToken();
```

### Products API

```javascript
// Get all products with pagination/filters
const res = await apiClient.getProducts({ 
  limit: 50, 
  offset: 0,
  category: 'Electronics'
});
// Returns: { results: [...], count: 100, next: '...', previous: null }

// Get single product
const product = await apiClient.getProductById(123);

// Create product (admin only)
const newProduct = await apiClient.createProduct({
  name: 'Product Name',
  price: 99.99,
  category: 'Electronics',
  description: 'Description',
  stock: 50
});

// Update product
const updated = await apiClient.updateProduct(123, {
  price: 89.99
});

// Delete product
await apiClient.deleteProduct(123);
```

### Shops API

```javascript
// Get all shops
const shops = await apiClient.getShops({ limit: 100 });

// Get single shop
const shop = await apiClient.getShopById(456);

// Get products from a shop
const products = await apiClient.getShopProducts(456);
```

### Properties API

```javascript
// Get all properties
const properties = await apiClient.getProperties({ 
  limit: 50,
  location: 'Lilongwe'
});

// Get single property
const property = await apiClient.getPropertyById(789);

// Create property
const newProp = await apiClient.createProperty({
  name: 'Apartment',
  location: 'Lilongwe',
  price: 50000,
  bedrooms: 3,
  bathrooms: 2,
  description: 'Nice apartment'
});
```

### Events API

```javascript
// Get all events
const events = await apiClient.getEvents({ limit: 100 });

// Get single event
const event = await apiClient.getEventById(111);

// Create event
const newEvent = await apiClient.createEvent({
  name: 'Concert',
  date: '2024-06-15',
  location: 'Blantyre',
  price: 50,
  description: 'Live music event'
});
```

### Cart & Orders API

```javascript
// Get cart
const cart = await apiClient.getCart();

// Add to cart
await apiClient.addToCart(productId, quantity);

// Remove from cart
await apiClient.removeFromCart(cartItemId);

// Create order
const order = await apiClient.createOrder({
  items: [
    { product_id: 123, quantity: 2 },
    { product_id: 456, quantity: 1 }
  ],
  total: 199.97,
  payment_method: 'card'
});

// Get user's orders
const orders = await apiClient.getOrders();
```

### Payments API

```javascript
// Initiate payment
const payment = await apiClient.initiatePayment({
  property_id: 789,
  amount: 50000,
  payment_method: 'card',
  card_name: 'John Doe',
  card_number: '4532...',
  expiry: '12/25',
  cvv: '123'
});

// Check payment status
const status = await apiClient.checkPaymentStatus('REF123456');

// Get user's payment history
const payments = await apiClient.getMyPayments();
```

### Banners API

```javascript
// Get all banners
const banners = await apiClient.getBanners();
// Returns: Array of banner objects
```

### File Upload

```javascript
// Upload a file
const fileInput = document.getElementById('fileInput');
const file = fileInput.files[0];
const response = await apiClient.uploadFile(file, 'image');
```

## App Main Class

### MangoMartApp

```javascript
// Accessed as window.app

// Properties
app.currentUser        // Current logged-in user object
app.cart              // Shopping cart array
app.products          // Products array
app.shops             // Shops array
app.properties        // Properties array
app.events            // Events array
app.banners           // Banners array
app.currentPage       // Current page name

// Navigation
app.navigate('home')        // Navigate to page
app.navigate('products')
app.navigate('shops')
app.navigate('properties')
app.navigate('events')
app.navigate('hospitality')
app.navigate('cart')
app.navigate('profile')
app.navigate('auth')

// Authentication
await app.handleLogin(event)  // Handle login form
await app.logout()            // Logout user

// Cart Management
app.addToCart(product)        // Add item to cart
app.removeFromCart(index)     // Remove item from cart
app.updateCartQuantity(index, qty)
app.checkout()                // Process checkout

// Rendering
app.renderHome()
app.renderProducts()
app.renderShops()
app.renderProperties()
app.renderEvents()
app.renderHospitality()
app.renderCart()
app.renderProfile()
app.renderAuth()

// Utilities
app.showNotification(message, type)  // Show message
app.showLoadingSpinner(show)         // Show/hide loader
app.filterProducts()                 // Filter products
app.showSearch()                     // Search dialog
```

## Error Handling

### API Errors

```javascript
try {
  const products = await apiClient.getProducts();
} catch (error) {
  console.error('Error:', error.message);
  console.error('Status:', error.status);
  console.error('Data:', error.data);
  
  // Show user-friendly message
  app.showNotification(error.message, 'error');
}
```

### Network Issues

The app automatically:
- Detects network errors
- Shows connection error notifications
- Falls back to demo data if API unavailable
- Retries failed requests (with backoff for 401)

## Storage & Persistence

### localStorage Usage

```javascript
// Cart persists across sessions
localStorage.setItem('cart', JSON.stringify(app.cart));
JSON.parse(localStorage.getItem('cart'));

// Authentication tokens
localStorage.getItem('access_token');
localStorage.getItem('refresh_token');
localStorage.getItem('user_id');
localStorage.getItem('username');
localStorage.getItem('user_data');
```

## Demo Mode Fallback

When API is unavailable, the app uses hardcoded demo data:

```javascript
// In data.js
window.productsData = [...]   // 30+ sample products
window.shopsData = [...]      // 6 sample shops
window.propertiesData = [...]  // 6 sample properties
window.eventsData = [...]     // 3 sample events
```

The app automatically:
1. Checks if API is available
2. Tries to load from API
3. Falls back to demo data on error
4. Shows appropriate messages to user

## Environment Configuration

### Base URL

```javascript
// In api-client.js
this.baseURL = 'http://127.0.0.1:8000/api/';
```

To change to production:

```javascript
// Update in api-client.js constructor
this.baseURL = 'https://api.example.com/api/';
```

### Headers

Automatically added:
- `Content-Type: application/json`
- `Authorization: Bearer {token}` (when logged in)
- `ngrok-skip-browser-warning: true` (for ngrok tunnels)

## Testing API Endpoints

### Using Browser Console

```javascript
// In developer console (F12)

// Get all products
apiClient.getProducts().then(res => console.log(res));

// Get single product
apiClient.getProductById(1).then(res => console.log(res));

// Login
apiClient.login('admin', 'password').then(res => console.log(res));

// Create product
apiClient.createProduct({
  name: 'Test Product',
  price: 29.99,
  category: 'Test'
}).then(res => console.log(res));
```

### Using cURL

```bash
# Login and get token
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

# Get products
curl -X GET http://127.0.0.1:8000/api/products/ \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create product
curl -X POST http://127.0.0.1:8000/api/products/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Product",
    "price": 99.99,
    "category": "Electronics",
    "stock": 50
  }'
```

## API Response Format

### List Endpoints

```json
{
  "count": 100,
  "next": "http://api/products/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "Product 1",
      ...
    }
  ]
}
```

### Single Item Endpoints

```json
{
  "id": 1,
  "name": "Product 1",
  "price": 99.99,
  ...
}
```

### Authentication Response

```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "username": "john",
    "email": "john@example.com"
  }
}
```

## Common Scenarios

### Load Data on Page Visit

```javascript
renderProducts() {
  const container = document.querySelector('[data-page="products"]');
  
  if (this.products.length === 0) {
    // Reload from API if not cached
    apiClient.getProducts().then(res => {
      this.products = res.results || res;
      // Render...
    });
  } else {
    // Use cached data
    // Render...
  }
}
```

### Handle Authentication Flow

```javascript
async handleLogin(event) {
  event.preventDefault();
  
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  
  try {
    // This also saves tokens to localStorage
    await apiClient.login(username, password);
    
    // Get user profile
    this.currentUser = await apiClient.getCurrentUser();
    
    // Navigate to home
    this.navigate('home');
  } catch (error) {
    this.showNotification(error.message, 'error');
  }
}
```

### Implement Real-time Search

```javascript
filterProducts() {
  const query = document.getElementById('searchInput').value;
  
  if (query.length > 2) {
    apiClient.getProducts({ 
      search: query,
      limit: 20
    }).then(res => {
      this.products = res.results || res;
      this.renderProducts();
    });
  }
}
```

## Debugging

### Enable Console Logging

```javascript
// API client logs all requests/responses with [API] prefix
// Check browser console (F12) for detailed logs

[API] GET products/
[API] POST token/
[API ERROR] GET products/: Network error
```

### Check Network Requests

1. Open DevTools (F12)
2. Go to Network tab
3. Perform action
4. Click request to see details:
   - Request headers (Authorization)
   - Request body (data sent)
   - Response status
   - Response body (API response)

### Troubleshooting

**Server not found error**
- Ensure backend is running at http://127.0.0.1:8000/
- Check backend server logs
- App will fallback to demo data

**401 Unauthorized**
- Token expired, app will try to refresh
- If refresh fails, user redirected to login
- Clear localStorage if needed: `localStorage.clear()`

**CORS errors**
- Check backend CORS configuration
- Should include http://localhost:3000 in CORS_ALLOWED_ORIGINS
- Or run frontend on same domain as backend

## Performance Tips

1. **Cache data** - Products loaded once, reused for filtering
2. **Pagination** - Use limit/offset for large datasets
3. **Lazy loading** - Load images with `loading="lazy"`
4. **Debounce search** - Prevent excessive API calls
5. **Local storage** - Cart persists without API calls

## Security

### JWT Token Handling

- Tokens stored in localStorage (not ideal for production)
- For production, consider:
  - HttpOnly cookies for tokens
  - CSRF protection
  - Token rotation
  - Secure endpoints

### Input Validation

Always validate user input before sending to API:

```javascript
if (!username || username.length < 3) {
  throw new Error('Username too short');
}

if (!password || password.length < 8) {
  throw new Error('Password too weak');
}
```

## Migration Checklist

- [x] API client created (api-client.js)
- [x] App with API integration (app-api.js)
- [x] Authentication flow working
- [x] CRUD operations implemented
- [x] Error handling in place
- [x] Demo data fallback ready
- [x] Token management (JWT)
- [x] Cart persistence (localStorage)
- [x] Responsive UI
- [x] Loading indicators
- [x] User notifications

## Next Steps

1. **Test with real backend** - Run backend server and test API calls
2. **User authentication** - Test login/logout flow
3. **Data operations** - Test CRUD (Create, Read, Update, Delete)
4. **Error scenarios** - Test error handling (no internet, invalid data)
5. **Deploy** - Deploy web app and update API URL to production

## Support

For issues or questions:
1. Check browser console (F12) for errors
2. Check Network tab for API responses
3. Review this documentation
4. Check backend API documentation
5. Enable debug logging in api-client.js
