# MangoMart Web App - Implementation Guide

A comprehensive guide for developers to understand, modify, and extend the MangoMart web application.

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Code Structure](#code-structure)
3. [Core Systems](#core-systems)
4. [Adding Features](#adding-features)
5. [API Integration](#api-integration)
6. [Styling Guide](#styling-guide)
7. [Performance Optimization](#performance-optimization)

---

## Architecture Overview

The application follows a **Single Page Application (SPA)** architecture:

```
User Interaction
        ↓
    NavHandler
        ↓
    App.navigateTo()
        ↓
    Page Renderer
        ↓
    Display Update
```

### Key Components

- **HTML** - Structure and page definitions
- **CSS** - Styling and layout
- **JavaScript** - Logic and interactivity
- **localStorage** - Data persistence

### Data Flow

```
Mock Data (js/data.js)
        ↓
App.loadProducts() etc.
        ↓
createProductCard()
        ↓
Render to DOM
        ↓
User Interaction
```

---

## Code Structure

### Folder Layout

```
web-app/
├── index.html                 # Main HTML file (363 lines)
├── styles/
│   ├── main.css              # Main styles (1127 lines)
│   └── animations.css        # Animations (423 lines)
├── js/
│   ├── app.js                # App logic (341 lines)
│   ├── components.js         # Reusable components (291 lines)
│   └── data.js               # Sample data (406 lines)
├── README.md                 # Full documentation
├── QUICKSTART.md             # Quick start guide
└── IMPLEMENTATION_GUIDE.md   # This file
```

### HTML Structure

**Main container**: `<div id="app" class="app">`

**Key sections**:
- `<nav class="navbar">` - Navigation
- `<main class="main-content">` - Page container
- `<section id="page" class="page">` - Individual pages
- `<footer class="footer">` - Footer

---

## Core Systems

### 1. App Class (app.js)

The main application controller:

```javascript
class MangoMartApp {
    constructor()          // Initialize app
    init()                 // Set up event listeners
    navigateTo(page)       // Change pages
    checkAuth()            // Check user login
    handleLogin()          // Process login
    loadHome()             // Load home page
    addToCart(product)     // Add to cart
    saveCart()             // Save cart to localStorage
    filterProducts()       // Search and filter
}
```

**Usage Example**:
```javascript
window.app = new MangoMartApp();
window.app.navigateTo('products');
```

### 2. Component Functions (components.js)

Factory functions for creating UI elements:

```javascript
createProductCard(product, app)      // Product card
createShopCard(shop, app)            // Shop card
createPropertyCard(property)         // Property card
createEventCard(event)               // Event card
createLodgeCard(lodge)               // Lodge card
createModal(title, content, actions) // Modal dialog
showToast(message, type, duration)   // Notification toast
```

**Usage Example**:
```javascript
const card = createProductCard(product, app);
document.getElementById('container').appendChild(card);
```

### 3. Data Management (data.js)

Mock data arrays for development:

```javascript
window.productsData    // Array of product objects
window.shopsData       // Array of shop objects
window.propertiesData  // Array of property objects
window.eventsData      // Array of event objects
window.lodgesData      // Array of lodge objects
```

---

## Adding Features

### Add a New Product Category

1. **Update data.js**:
```javascript
window.productsData.push({
    id: 13,
    name: 'New Product',
    shop: 'Shop Name',
    price: 5000,
    category: 'New Category',
    image: 'url',
    rating: 4.5,
    reviews: 100,
    district: 'Lilongwe'
});
```

2. **Update filter chips in index.html**:
```html
<button class="chip">New Category</button>
```

3. **Update filterProducts() in app.js**:
```javascript
filterProducts() {
    // Filter logic already handles dynamic categories
}
```

### Add a New Page

1. **Add HTML section in index.html**:
```html
<section id="newpage" class="page">
    <div class="page-header">
        <h1>New Page</h1>
    </div>
    <div id="newpageContainer">
        <!-- Content goes here -->
    </div>
</section>
```

2. **Add navigation link**:
```html
<a href="#newpage" class="nav-link">New Page</a>
```

3. **Add page loader in app.js**:
```javascript
loadNewPage() {
    const container = document.getElementById('newpageContainer');
    container.innerHTML = '';
    window.newpageData.forEach(item => {
        container.appendChild(createNewpageCard(item));
    });
}
```

4. **Add to navigateTo()**:
```javascript
} else if (page === 'newpage') {
    this.loadNewPage();
}
```

5. **Create component in components.js**:
```javascript
function createNewpageCard(item) {
    const card = document.createElement('div');
    card.className = 'newpage-card';
    card.innerHTML = `
        <!-- Card HTML -->
    `;
    return card;
}
```

### Add Form Validation

```javascript
function validateForm(formData) {
    const errors = [];
    
    if (!formData.email || !isValidEmail(formData.email)) {
        errors.push('Invalid email');
    }
    
    if (!formData.phone || !isValidPhone(formData.phone)) {
        errors.push('Invalid phone number');
    }
    
    return errors;
}
```

---

## API Integration

### Replace Mock Data with API Calls

**Original (mock data)**:
```javascript
loadProducts() {
    const container = document.getElementById('productsPageContainer');
    window.productsData.forEach(product => {
        container.appendChild(createProductCard(product, this));
    });
}
```

**With API**:
```javascript
async loadProducts() {
    try {
        const response = await fetch('https://api.example.com/products');
        if (!response.ok) throw new Error('API error');
        
        const products = await response.json();
        window.productsData = products;
        
        const container = document.getElementById('productsPageContainer');
        container.innerHTML = '';
        products.forEach(product => {
            container.appendChild(createProductCard(product, this));
        });
    } catch (error) {
        console.error('Error loading products:', error);
        showToast('Failed to load products', 'error');
    }
}
```

### API Base Setup

```javascript
const API_BASE = 'https://api.mangomart.com';

async function apiCall(endpoint, options = {}) {
    const token = localStorage.getItem('authToken');
    
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };
    
    if (token) {
        headers.Authorization = `Bearer ${token}`;
    }
    
    const response = await fetch(`${API_BASE}${endpoint}`, {
        ...options,
        headers
    });
    
    if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
    }
    
    return response.json();
}
```

### Authentication Flow

```javascript
async handleLogin() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    try {
        const data = await apiCall('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });
        
        localStorage.setItem('authToken', data.token);
        this.user = data.user;
        this.navigateTo('home');
    } catch (error) {
        showToast('Login failed', 'error');
    }
}
```

---

## Styling Guide

### CSS Architecture

**Three-tier approach**:

1. **main.css** - Core styles, layout, components
2. **animations.css** - Animations and transitions
3. **Inline styles** - (Avoid, use classes instead)

### Adding New Styles

**Step 1**: Define variables
```css
:root {
    --my-color: #FF8C00;
    --my-spacing: 16px;
}
```

**Step 2**: Create class
```css
.my-component {
    background-color: var(--my-color);
    padding: var(--my-spacing);
    border-radius: var(--radius-md);
    transition: var(--transition);
}

.my-component:hover {
    transform: translateY(-2px);
}
```

**Step 3**: Use in HTML
```html
<div class="my-component">Content</div>
```

### Responsive Breakpoints

```css
/* Desktop */
@media (max-width: 1024px) {
    /* Adjustments */
}

/* Tablet */
@media (max-width: 768px) {
    /* Hide sidebar, adjust grid */
}

/* Mobile */
@media (max-width: 480px) {
    /* Single column, larger touch targets */
}
```

### Color Usage

```css
/* Do this */
background-color: var(--color-primary);
color: var(--color-dark-text);

/* Avoid this */
background-color: #FF8C00;
color: #212121;
```

---

## Performance Optimization

### Image Optimization

**Use placeholder with error handling**:
```html
<img src="url" 
     alt="Description"
     onerror="this.src='https://via.placeholder.com/200'">
```

**Or with lazy loading**:
```html
<img src="url" 
     alt="Description"
     loading="lazy">
```

### CSS Performance

✅ **Good**:
- Use CSS Grid/Flexbox
- Minimize specificity
- Use CSS variables
- Avoid deep nesting

❌ **Bad**:
- Inline styles
- `!important` overrides
- Complex selectors
- Hardcoded values

### JavaScript Optimization

✅ **Good**:
```javascript
// Event delegation
document.addEventListener('click', (e) => {
    if (e.target.matches('.btn-primary')) {
        handleClick(e);
    }
});
```

❌ **Bad**:
```javascript
// Attaching to every button
document.querySelectorAll('.btn-primary').forEach(btn => {
    btn.addEventListener('click', handleClick);
});
```

### Caching

```javascript
// Cache frequently accessed elements
const productsContainer = document.getElementById('productsContainer');
const shopsContainer = document.getElementById('shopsContainer');

// Reuse instead of querying again
productsContainer.innerHTML = '';
```

### Bundle Size

**Current size**:
- HTML: ~15KB
- CSS: ~50KB
- JS: ~50KB
- **Total: ~115KB**

### Minification for Production

```bash
# CSS minification
# Use: cssnano, clean-css

# JS minification
# Use: terser, webpack

# Result: ~30-40KB total
```

---

## Testing

### Manual Testing Checklist

```
[ ] Home page loads
[ ] Navigation works on all pages
[ ] Search and filter work
[ ] Add to cart works
[ ] Login/logout works
[ ] Mobile menu toggles
[ ] Images load correctly
[ ] Forms validate
[ ] Links work
[ ] Cart persists
```

### Browser Testing

```
[ ] Chrome (latest)
[ ] Firefox (latest)
[ ] Safari (latest)
[ ] Edge (latest)
[ ] Mobile Safari (iOS)
[ ] Chrome Mobile (Android)
```

### Performance Testing

```javascript
// Measure page load
console.time('pageLoad');
// ... code
console.timeEnd('pageLoad');

// Measure function
console.time('filter');
this.filterProducts();
console.timeEnd('filter');
```

---

## Debugging

### Common Issues

**Issue**: Page blank after navigation
```javascript
// Check if page element exists
console.log(document.getElementById('products')); // Should not be null
```

**Issue**: Cart not saving
```javascript
// Check localStorage
console.log(localStorage.getItem('cart'));
// Ensure localStorage is enabled
```

**Issue**: API not working
```javascript
// Check network tab in DevTools
// Verify CORS headers
// Check API response format
```

### Debug Mode

```javascript
// Add to app.js
const DEBUG = true;

if (DEBUG) {
    console.log('[DEBUG] Event triggered:', eventName);
    console.log('[DEBUG] Current page:', this.currentPage);
    console.log('[DEBUG] User data:', this.user);
}
```

---

## Deployment Checklist

Before deploying to production:

```
[ ] Update API endpoints (remove localhost)
[ ] Remove console.log statements
[ ] Minify CSS and JS
[ ] Optimize images
[ ] Test on real devices
[ ] Check HTTPS configuration
[ ] Verify all links work
[ ] Test form submissions
[ ] Check database connections
[ ] Set up error monitoring
[ ] Create backup
```

---

## Resources

- [MDN CSS Reference](https://developer.mozilla.org/en-US/docs/Web/CSS)
- [JavaScript.info](https://javascript.info/)
- [CSS Tricks](https://css-tricks.com/)
- [Web.dev](https://web.dev/)

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Status**: Ready for Production
