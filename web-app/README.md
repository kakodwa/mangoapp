# MangoMart Web Application

A responsive, modern web-based marketplace application ported from the Flutter "mangoapp". This is a complete HTML/CSS/JavaScript implementation of the MangoMart platform with all key features and pages.

## 📋 Overview

MangoMart is a comprehensive multi-category marketplace platform that includes:

- **Products Marketplace** - Buy and sell various products
- **Shops** - Browse and visit vendor shops
- **Properties** - List and book residential properties
- **Events** - Discover and book event tickets
- **Hospitality** - Book lodges and accommodations
- **Delivery** - Manage deliveries and logistics
- **User Profile** - Manage user account and wallet
- **Shopping Cart** - Add and manage products

## 🎨 Design System

The web application follows the exact design system from the Flutter app:

### Colors
- **Primary Brand Color**: `#FF8C00` (Mango Orange)
- **Secondary Color**: `#2E7D32` (Leaf Green)
- **Light Variant**: `#FFA726` (Mango Light)
- **Dark Text**: `#212121`

### Typography
- **Font Family**: System fonts (Segoe UI, Roboto, SF Pro Display)
- **Display Sizes**: 32px, 28px, 24px
- **Heading Sizes**: 20px, 18px, 16px
- **Body Sizes**: 16px, 14px, 12px

### Spacing System
- XS: 4px
- SM: 8px
- MD: 12px
- LG: 16px
- XL: 20px
- 2XL: 24px
- 3XL: 32px

## 📁 Project Structure

```
web-app/
├── index.html          # Main HTML file with all pages
├── README.md           # This file
├── styles/
│   └── main.css        # Complete styling with responsive design
└── js/
    ├── app.js          # Main app logic and routing
    ├── components.js   # Reusable component builders
    └── data.js         # Mock data and sample content
```

## 🚀 Getting Started

### Quick Start
1. Open `index.html` in a modern web browser
2. The application will load with sample data
3. Navigate between pages using the navigation menu

### Running Locally with a Server
```bash
# Using Python 3
python -m http.server 8000

# Using Python 2
python -m SimpleHTTPServer 8000

# Using Node.js http-server
npx http-server

# Using PHP
php -S localhost:8000
```

Then visit: `http://localhost:8000`

## 📱 Features & Pages

### Home Page
- **Banner Carousel** - Rotating promotional banners
- **Quick Actions** - Fast access to main categories
- **Featured Sections** - Showcase shops, products, and properties

### Products Page
- **Search & Filter** - Find products by name and category
- **Product Grid** - Responsive grid layout
- **Categories** - Electronics, Fashion, Groceries, Home, Beauty
- **Add to Cart** - Quick shopping cart management

### Shops Page
- **Shop Directory** - Browse all available shops
- **Shop Cards** - View ratings, categories, and details
- **Search** - Find shops by name

### Properties Page
- **Property Listings** - Browse available properties
- **Filters** - Search by location and amenities
- **Property Cards** - Display price, beds, baths, amenities

### Events Page
- **Event Listings** - Upcoming events and activities
- **Ticket Purchase** - Buy event tickets
- **Event Details** - View dates, locations, descriptions

### Hospitality Page
- **Lodge Bookings** - Reserve accommodations
- **Booking System** - Check availability and prices
- **Lodge Details** - Room information and amenities

### Profile Page
- **User Information** - Display user details and role
- **Wallet Stats** - Show balance, earnings, withdrawals
- **Menu Options** - Quick access to account features

### Authentication
- **Login** - User authentication
- **Registration** - Create new accounts
- **Session Management** - Persistent user sessions

## 💻 Responsive Design

The application is fully responsive across all device sizes:

- **Desktop** (1024px+) - Full multi-column layouts
- **Tablet** (768px-1023px) - Optimized grid layouts
- **Mobile** (< 768px) - Single column, mobile-optimized UI

Key responsive breakpoints:
- `1024px` - Large desktop adjustments
- `768px` - Tablet and below
- `480px` - Small mobile devices

## 🔧 Key JavaScript Components

### App Class (`app.js`)
Main application controller handling:
- Page routing and navigation
- Authentication and user management
- Cart operations
- Data filtering and search

### Component Functions (`components.js`)
Reusable components for creating:
- Product cards
- Shop cards
- Property cards
- Event cards
- Modals and toasts
- Utilities (formatting, validation)

### Mock Data (`data.js`)
Sample data arrays:
- `productsData` - 12 sample products
- `shopsData` - 6 sample shops
- `propertiesData` - 6 properties
- `eventsData` - 3 sample events
- `lodgesData` - 4 sample lodges

## 🎯 Navigation

### Top Navigation Bar
- **Logo** - Click to go home
- **Nav Links** - Home, Products, Shops, Properties, Events, Hospitality
- **Search** - Product search (expandable)
- **Cart** - Shopping cart with item count
- **Profile** - User account menu
- **Hamburger** - Mobile menu toggle

### Internal Navigation
- Hash-based routing: `#home`, `#products`, `#shops`, etc.
- Click any card to navigate
- Back button available in mobile menu

## 📦 Cart Management

Features:
- Add products to cart with one click
- Cart count displays in header
- Cart data persists in localStorage
- Remove items functionality
- View cart summary

## 👤 User Profiles

Supported User Types:
- **Buyer** - Regular customer
- **Shop Owner** - Manage shop and products
- **Hospitality Owner** - Manage lodges and bookings
- **Delivery Partner** - Manage deliveries
- **Event Organizer** - Manage events

## 🔐 Data Persistence

Uses browser localStorage for:
- User session data
- Shopping cart
- Favorites/Wishlist
- User preferences

## 🌐 API Integration

To connect to a backend API:

1. Update endpoints in `app.js`
2. Replace `window.shopsData` with API calls
3. Use fetch or axios for requests

Example:
```javascript
// Replace mock data with API calls
async function loadProducts() {
    const response = await fetch('/api/products');
    window.productsData = await response.json();
}
```

## 🎨 Customization

### Changing Brand Colors
Edit CSS variables in `main.css`:
```css
:root {
    --color-primary: #FF8C00;        /* Change brand color */
    --color-secondary: #2E7D32;      /* Change secondary */
    --color-dark-text: #212121;      /* Change text color */
}
```

### Modifying Layouts
All grids are responsive CSS Grid:
```css
.products-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
}
```

### Adding New Pages
1. Add section in HTML: `<section id="newpage" class="page"></section>`
2. Add navigation link
3. Add loader function in `app.js`
4. Add routing case in `navigateTo()`

## 🐛 Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+
- Mobile browsers (iOS Safari, Chrome Mobile)

## ⚡ Performance

Features:
- Lazy loading for images
- Efficient CSS with minimal repaints
- No heavy dependencies
- Fast page transitions
- Optimized bundle size

## 📊 Component Statistics

- **Pages**: 9 (Home, Products, Shops, Properties, Events, Hospitality, Profile, Auth)
- **Card Components**: 4 (Product, Shop, Property, Event)
- **Reusable Functions**: 15+
- **CSS Classes**: 100+
- **Lines of Code**: ~3000

## 🔄 Development Workflow

1. Edit HTML in `index.html`
2. Update styles in `styles/main.css`
3. Add logic in `js/app.js`
4. Create components in `js/components.js`
5. Update data in `js/data.js`
6. Test in browser and mobile devices

## 📚 Flutter to Web Conversion

This web app mirrors the Flutter app structure:
- Same color scheme and typography
- Same page structure and flow
- Same functional features
- Same user experience adapted for web

Key differences:
- Navigation: Hash-based instead of Stack Navigator
- Storage: localStorage instead of Shared Preferences
- Images: URLs instead of asset paths
- Styling: CSS instead of Flutter widgets

## 🚀 Deployment

### Static Hosting (Vercel, GitHub Pages, Netlify)
Simply upload the `web-app` folder to your hosting service.

### Vercel Deployment
```bash
vercel --prod
```

### GitHub Pages
```bash
git subtree push --prefix web-app origin gh-pages
```

## 📝 License

This web application is a responsive version of the MangoMart Flutter application.

## 👨‍💻 Development

Created as a responsive web-based version of the Flutter MangoMart marketplace application. All core functionality has been ported to HTML/CSS/JavaScript while maintaining the original design system and user experience.

## 📞 Support

For issues or questions, refer to:
- Flutter app documentation
- Web standards documentation
- Browser console for debug messages

---

**Version**: 1.0.0
**Last Updated**: 2024
**Status**: Active Development
