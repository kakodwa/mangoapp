# MangoMart Web App - Quick Start Guide

## 🚀 Get Started in 30 Seconds

### Option 1: Open Directly in Browser
1. Open `index.html` in your favorite web browser
2. That's it! The app loads with sample data and works immediately

### Option 2: Run with Local Server (Recommended)

**Using Python 3:**
```bash
cd web-app
python -m http.server 8000
# Visit: http://localhost:8000
```

**Using Node.js:**
```bash
cd web-app
npx http-server
# Visit: http://localhost:8080
```

**Using PHP:**
```bash
cd web-app
php -S localhost:8000
# Visit: http://localhost:8000
```

## 📱 Test on Mobile

### Android
- Connect device via USB with Developer Mode enabled
- Open Chrome: `chrome://inspect`
- Click "Inspect" on your device
- View responsive design

### iOS
- Use Simulator in Xcode
- Open Safari and navigate to your server IP
- Test touch interactions

## 🎯 Main Features to Try

### 1. Home Page
- Scroll through featured products, shops, and properties
- Click any card to add to cart or view details
- Use quick action buttons for different categories

### 2. Products Page
```
✓ Search by product name
✓ Filter by category (Electronics, Fashion, etc.)
✓ Add items to cart
✓ Sort and organize
```

### 3. Shops Page
- Browse all available shops
- Search by shop name
- View ratings and categories

### 4. Profile
- Click user icon in header
- View account details
- Check wallet balance and earnings

### 5. Shopping Cart
- Click cart icon to see item count
- Add products from any page
- Data persists in browser storage

## 🎨 Customize the App

### Change Brand Colors
Edit `styles/main.css`:
```css
:root {
    --color-primary: #FF8C00;        /* Orange */
    --color-secondary: #2E7D32;      /* Green */
    --color-dark-text: #212121;      /* Text */
}
```

### Add Your Logo
Replace logo in `index.html`:
```html
<div class="navbar-logo">
    <img src="your-logo.png" alt="Logo">
    <span>Your Brand</span>
</div>
```

### Update Product Data
Edit `js/data.js`:
```javascript
window.productsData = [
    {
        id: 1,
        name: 'Your Product',
        price: 5000,
        // ... more fields
    }
];
```

## 🔧 Development Workflow

### File Structure
```
web-app/
├── index.html            # All HTML pages
├── styles/
│   ├── main.css         # Main styles
│   └── animations.css   # Animations
└── js/
    ├── app.js           # App logic
    ├── components.js    # Reusable components
    └── data.js          # Sample data
```

### Make Changes & Preview
1. Edit any CSS in `styles/main.css`
2. Save the file
3. Refresh browser (F5 or Cmd+R)
4. Changes appear instantly

### Add New Features
1. Add HTML structure in `index.html`
2. Write CSS in `styles/main.css`
3. Add logic in `js/app.js`
4. Create components in `js/components.js`

## 🌐 Connect to Backend API

### Replace Mock Data with API
In `js/app.js`:

```javascript
async loadProducts() {
    const response = await fetch('https://your-api.com/products');
    const data = await response.json();
    window.productsData = data;
}
```

### Handle Authentication
```javascript
async handleLogin(username, password) {
    const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
    });
    const { token } = await response.json();
    localStorage.setItem('authToken', token);
}
```

## 📊 Sample Data Available

All sample data is in `js/data.js`:

```javascript
window.productsData    // 12 sample products
window.shopsData       // 6 sample shops
window.propertiesData  // 6 properties
window.eventsData      // 3 events
window.lodgesData      // 4 lodges
```

Use this for testing before connecting to real API.

## 🐛 Common Issues & Solutions

### Issue: Images Not Loading
**Solution**: Images use placeholder URLs. Replace with real URLs in `data.js`

### Issue: Cart Not Persisting
**Solution**: Make sure browser localStorage is enabled. Check browser console.

### Issue: Mobile Menu Not Working
**Solution**: Ensure hamburger icon is visible on mobile. Check viewport meta tag.

### Issue: Styles Not Applying
**Solution**: Clear browser cache (Ctrl+Shift+Delete) and reload page.

## 📱 Responsive Design

Automatically adapts to:
- **Desktop** (1024px+) - Multi-column layouts
- **Tablet** (768px) - 2-3 column grids
- **Mobile** (<768px) - Single column, full-width

Test with browser DevTools:
1. Open DevTools (F12)
2. Click device toggle (Ctrl+Shift+M)
3. Test different screen sizes

## ⚡ Performance Tips

1. **Minify CSS/JS** for production
2. **Optimize Images** (use WebP format)
3. **Lazy Load** images
4. **Cache** API responses
5. **Use CDN** for static assets

## 🚀 Deploy to Production

### Vercel
```bash
npm i -g vercel
vercel --prod
```

### Netlify
```bash
npm i -g netlify-cli
netlify deploy --prod
```

### GitHub Pages
```bash
git subtree push --prefix web-app origin gh-pages
```

### Firebase Hosting
```bash
firebase deploy --only hosting
```

## 🔑 Key Keyboard Shortcuts

- `F12` - Open DevTools
- `Ctrl+Shift+M` - Toggle mobile view
- `Ctrl+Shift+Delete` - Clear cache
- `Ctrl+K` - Search
- `Escape` - Close modal

## 📚 Learn More

- [MDN Web Docs](https://developer.mozilla.org/)
- [CSS Tricks](https://css-tricks.com/)
- [JavaScript.info](https://javascript.info/)
- [Responsive Design](https://responsive.design/)

## 💡 Next Steps

1. ✅ Run the app locally
2. ✅ Explore all pages
3. ✅ Try mobile view
4. ✅ Customize colors/content
5. ✅ Connect to your API
6. ✅ Deploy to production

## 🆘 Need Help?

- Check browser console for errors (F12)
- Verify all files are in correct folders
- Ensure paths in HTML match actual file locations
- Check internet connection for API calls

---

**Ready?** Open `index.html` and start exploring! 🎉

For detailed documentation, see `README.md`
