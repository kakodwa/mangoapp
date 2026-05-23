/**
 * MangoMart Web App - Main Application Logic with API Integration
 */

class MangoMartApp {
  constructor() {
    this.currentUser = null;
    this.cart = [];
    this.products = [];
    this.shops = [];
    this.properties = [];
    this.events = [];
    this.banners = [];
    this.currentPage = 'home';
    this.isLoading = false;
    this.loadFromStorage();
    this.setupEventListeners();
  }

  // ==================== INITIALIZATION ====================
  async init() {
    console.log('[v0] App initializing...');
    this.showLoadingSpinner(true);

    try {
      // Check if server is available
      const serverAvailable = await apiClient.healthCheck();
      if (!serverAvailable) {
        console.warn('[v0] Server not available at http://127.0.0.1:8000/api/');
        this.showConnectionError();
        // Still load demo data for offline use
        this.loadDemoData();
      } else {
        console.log('[v0] Server available, loading data from API');
        await this.loadDataFromAPI();
      }
    } catch (error) {
      console.error('[v0] Initialization error:', error);
      this.loadDemoData();
    } finally {
      this.showLoadingSpinner(false);
      this.navigate('home');
    }
  }

  // ==================== API DATA LOADING ====================
  async loadDataFromAPI() {
    try {
      // Try to get banners
      try {
        const bannersRes = await apiClient.getBanners();
        this.banners = Array.isArray(bannersRes) ? bannersRes : bannersRes.results || [];
        console.log('[v0] Loaded banners:', this.banners.length);
      } catch (e) {
        console.warn('[v0] Failed to load banners:', e.message);
      }

      // Get products
      try {
        const productsRes = await apiClient.getProducts({ limit: 100 });
        this.products = Array.isArray(productsRes) ? productsRes : productsRes.results || [];
        console.log('[v0] Loaded products:', this.products.length);
      } catch (e) {
        console.warn('[v0] Failed to load products:', e.message);
      }

      // Get shops
      try {
        const shopsRes = await apiClient.getShops({ limit: 100 });
        this.shops = Array.isArray(shopsRes) ? shopsRes : shopsRes.results || [];
        console.log('[v0] Loaded shops:', this.shops.length);
      } catch (e) {
        console.warn('[v0] Failed to load shops:', e.message);
      }

      // Get properties
      try {
        const propsRes = await apiClient.getProperties({ limit: 100 });
        this.properties = Array.isArray(propsRes) ? propsRes : propsRes.results || [];
        console.log('[v0] Loaded properties:', this.properties.length);
      } catch (e) {
        console.warn('[v0] Failed to load properties:', e.message);
      }

      // Get events
      try {
        const eventsRes = await apiClient.getEvents({ limit: 100 });
        this.events = Array.isArray(eventsRes) ? eventsRes : eventsRes.results || [];
        console.log('[v0] Loaded events:', this.events.length);
      } catch (e) {
        console.warn('[v0] Failed to load events:', e.message);
      }

      // Check authentication
      try {
        if (apiClient.getAccessToken()) {
          this.currentUser = await apiClient.getCurrentUser();
          console.log('[v0] User authenticated:', this.currentUser.username);
        }
      } catch (e) {
        console.warn('[v0] Failed to load user:', e.message);
        apiClient.clearTokens();
      }
    } catch (error) {
      console.error('[v0] Error loading data from API:', error);
      throw error;
    }
  }

  // ==================== DEMO DATA FALLBACK ====================
  loadDemoData() {
    console.log('[v0] Loading demo data (offline mode)');
    this.products = window.productsData || [];
    this.shops = window.shopsData || [];
    this.properties = window.propertiesData || [];
    this.events = window.eventsData || [];
    this.banners = this.generateDemoBanners();
  }

  generateDemoBanners() {
    return [
      {
        id: 1,
        title: 'Fresh Mangoes',
        subtitle: 'Get the best quality',
        image: 'https://via.placeholder.com/1200x300?text=Fresh+Mangoes',
      },
      {
        id: 2,
        title: 'Farm Fresh Products',
        subtitle: 'Direct from farmers',
        image: 'https://via.placeholder.com/1200x300?text=Farm+Fresh',
      },
      {
        id: 3,
        title: 'Amazing Properties',
        subtitle: 'Find your dream home',
        image: 'https://via.placeholder.com/1200x300?text=Properties',
      },
    ];
  }

  // ==================== UI STATE MANAGEMENT ====================
  showLoadingSpinner(show = true) {
    const spinner = document.getElementById('loadingSpinner');
    if (spinner) {
      spinner.style.display = show ? 'flex' : 'none';
    }
  }

  showConnectionError() {
    const message =
      'Server not available. Using demo data. ' +
      'Ensure backend is running at http://127.0.0.1:8000/';
    console.warn('[v0]', message);
    this.showNotification(message, 'info');
  }

  showNotification(message, type = 'info') {
    // Create or reuse notification element
    let notif = document.getElementById('notification');
    if (!notif) {
      notif = document.createElement('div');
      notif.id = 'notification';
      notif.className = 'notification';
      document.body.appendChild(notif);
    }

    notif.textContent = message;
    notif.className = `notification notification-${type}`;
    notif.style.display = 'block';

    setTimeout(() => {
      notif.style.display = 'none';
    }, 4000);
  }

  // ==================== NAVIGATION ====================
  setupEventListeners() {
    // Navigation links
    document.querySelectorAll('.nav-link').forEach((link) => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const page = e.target.getAttribute('href').substring(1);
        this.navigate(page);
      });
    });

    // Action buttons
    document.getElementById('searchBtn')?.addEventListener('click', () => this.showSearch());
    document.getElementById('cartBtn')?.addEventListener('click', () => this.navigate('cart'));
    document.getElementById('profileBtn')?.addEventListener('click', () => this.navigate('profile'));
    document.getElementById('hamburger')?.addEventListener('click', () => this.toggleMobileMenu());

    // Close mobile menu when link clicked
    document.querySelectorAll('.nav-link').forEach((link) => {
      link.addEventListener('click', () => {
        const hamburger = document.getElementById('hamburger');
        if (hamburger) {
          hamburger.classList.remove('active');
          const menu = document.getElementById('navbarMenu');
          if (menu) menu.classList.remove('active');
        }
      });
    });
  }

  navigate(page) {
    this.currentPage = page;
    this.showLoadingSpinner(true);

    // Hide all pages
    document.querySelectorAll('[data-page]').forEach((el) => {
      el.style.display = 'none';
    });

    // Show selected page
    const pageEl = document.querySelector(`[data-page="${page}"]`);
    if (pageEl) {
      pageEl.style.display = 'block';
      window.scrollTo(0, 0);

      // Render page content
      setTimeout(() => this.renderPage(page), 0);
    }

    this.showLoadingSpinner(false);
  }

  renderPage(page) {
    console.log('[v0] Rendering page:', page);

    switch (page) {
      case 'home':
        this.renderHome();
        break;
      case 'products':
        this.renderProducts();
        break;
      case 'shops':
        this.renderShops();
        break;
      case 'properties':
        this.renderProperties();
        break;
      case 'events':
        this.renderEvents();
        break;
      case 'hospitality':
        this.renderHospitality();
        break;
      case 'cart':
        this.renderCart();
        break;
      case 'profile':
        this.renderProfile();
        break;
      case 'auth':
        this.renderAuth();
        break;
    }
  }

  toggleMobileMenu() {
    const hamburger = document.getElementById('hamburger');
    const menu = document.getElementById('navbarMenu');
    hamburger?.classList.toggle('active');
    menu?.classList.toggle('active');
  }

  // ==================== PAGE RENDERING ====================
  renderHome() {
    const container = document.querySelector('[data-page="home"] .page-content');
    if (!container) return;

    let html = '';

    // Banner carousel
    if (this.banners.length > 0) {
      html += '<section class="banner-section">';
      html += '<div class="banner-carousel">';
      this.banners.forEach((banner, idx) => {
        html += `
          <div class="banner-slide" style="display: ${idx === 0 ? 'block' : 'none'}">
            <div class="banner-content">
              <h1>${banner.title || 'Welcome to MangoMart'}</h1>
              <p>${banner.subtitle || 'Quality products at great prices'}</p>
            </div>
          </div>
        `;
      });
      html += '</div></section>';
    }

    // Featured products
    if (this.products.length > 0) {
      html += `
        <section class="featured-section">
          <h2>Featured Products</h2>
          <div class="products-grid">
      `;
      this.products.slice(0, 4).forEach((product) => {
        html += this.renderProductCard(product);
      });
      html += '</div></section>';
    }

    // Featured shops
    if (this.shops.length > 0) {
      html += `
        <section class="featured-section">
          <h2>Featured Shops</h2>
          <div class="shops-grid">
      `;
      this.shops.slice(0, 3).forEach((shop) => {
        html += this.renderShopCard(shop);
      });
      html += '</div></section>';
    }

    container.innerHTML = html;
    this.attachEventListeners();
  }

  renderProducts() {
    const container = document.querySelector('[data-page="products"] .page-content');
    if (!container) return;

    let html = `
      <div class="products-header">
        <h1>All Products</h1>
        <div class="filter-controls">
          <input type="text" id="searchInput" placeholder="Search products..." class="search-input">
          <select id="categoryFilter" class="filter-select">
            <option value="">All Categories</option>
            <option value="Electronics">Electronics</option>
            <option value="Groceries">Groceries</option>
            <option value="Fashion">Fashion</option>
            <option value="Home">Home</option>
          </select>
        </div>
      </div>
      <div class="products-grid" id="productsGrid">
    `;

    this.products.forEach((product) => {
      html += this.renderProductCard(product);
    });

    html += '</div>';
    container.innerHTML = html;

    // Setup search and filter
    const searchInput = document.getElementById('searchInput');
    const categoryFilter = document.getElementById('categoryFilter');

    searchInput?.addEventListener('input', () => this.filterProducts());
    categoryFilter?.addEventListener('change', () => this.filterProducts());

    this.attachEventListeners();
  }

  renderShops() {
    const container = document.querySelector('[data-page="shops"] .page-content');
    if (!container) return;

    let html = '<h1>Shops</h1><div class="shops-grid">';

    this.shops.forEach((shop) => {
      html += this.renderShopCard(shop);
    });

    html += '</div>';
    container.innerHTML = html;
    this.attachEventListeners();
  }

  renderProperties() {
    const container = document.querySelector('[data-page="properties"] .page-content');
    if (!container) return;

    let html = '<h1>Properties</h1><div class="properties-grid">';

    this.properties.forEach((property) => {
      html += this.renderPropertyCard(property);
    });

    html += '</div>';
    container.innerHTML = html;
    this.attachEventListeners();
  }

  renderEvents() {
    const container = document.querySelector('[data-page="events"] .page-content');
    if (!container) return;

    let html = '<h1>Events</h1><div class="events-grid">';

    this.events.forEach((event) => {
      html += this.renderEventCard(event);
    });

    html += '</div>';
    container.innerHTML = html;
    this.attachEventListeners();
  }

  renderHospitality() {
    const container = document.querySelector('[data-page="hospitality"] .page-content');
    if (!container) return;

    let html = '<h1>Hospitality</h1><div class="properties-grid">';

    this.properties
      .filter((p) => p.type === 'lodge' || p.category === 'Hospitality')
      .forEach((property) => {
        html += this.renderPropertyCard(property);
      });

    html += '</div>';
    container.innerHTML = html;
    this.attachEventListeners();
  }

  renderCart() {
    const container = document.querySelector('[data-page="cart"] .page-content');
    if (!container) return;

    if (this.cart.length === 0) {
      container.innerHTML = '<p class="empty-state">Your cart is empty</p>';
      return;
    }

    let html = '<h1>Shopping Cart</h1><div class="cart-items">';
    let total = 0;

    this.cart.forEach((item, idx) => {
      const subtotal = item.price * item.quantity;
      total += subtotal;
      html += `
        <div class="cart-item">
          <img src="${item.image || 'https://via.placeholder.com/100'}" alt="${item.name}">
          <div class="item-details">
            <h3>${item.name}</h3>
            <p>$${item.price.toFixed(2)}</p>
          </div>
          <div class="item-quantity">
            <input type="number" min="1" value="${item.quantity}" 
              onchange="app.updateCartQuantity(${idx}, this.value)">
          </div>
          <div class="item-subtotal">$${subtotal.toFixed(2)}</div>
          <button class="btn-delete" onclick="app.removeFromCart(${idx})">
            <i class="fas fa-trash"></i>
          </button>
        </div>
      `;
    });

    html += `
        </div>
        <div class="cart-summary">
          <h3>Total: $${total.toFixed(2)}</h3>
          <button class="btn-primary" onclick="app.checkout()">Checkout</button>
        </div>
      `;

    container.innerHTML = html;
  }

  renderProfile() {
    const container = document.querySelector('[data-page="profile"] .page-content');
    if (!container) return;

    if (!this.currentUser) {
      container.innerHTML = `
        <div class="profile-empty">
          <p>Please login to view your profile</p>
          <button class="btn-primary" onclick="app.navigate('auth')">Login</button>
        </div>
      `;
      return;
    }

    const html = `
      <div class="profile-container">
        <h1>Profile</h1>
        <div class="profile-info">
          <div class="profile-item">
            <label>Username</label>
            <p>${this.currentUser.username}</p>
          </div>
          <div class="profile-item">
            <label>Email</label>
            <p>${this.currentUser.email}</p>
          </div>
          <div class="profile-item">
            <label>Name</label>
            <p>${this.currentUser.first_name} ${this.currentUser.last_name}</p>
          </div>
        </div>
        <button class="btn-danger" onclick="app.logout()">Logout</button>
      </div>
    `;

    container.innerHTML = html;
  }

  renderAuth() {
    const container = document.querySelector('[data-page="auth"] .page-content');
    if (!container) return;

    const html = `
      <div class="auth-container">
        <div class="auth-form">
          <h1>Login</h1>
          <form onsubmit="app.handleLogin(event)">
            <input type="text" id="loginUsername" placeholder="Username" required>
            <input type="password" id="loginPassword" placeholder="Password" required>
            <button type="submit" class="btn-primary">Login</button>
          </form>
          <p>Don't have an account? <a href="#" onclick="app.showRegisterForm()">Register</a></p>
        </div>
      </div>
    `;

    container.innerHTML = html;
  }

  // ==================== CARD RENDERING ====================
  renderProductCard(product) {
    const image = product.image || product.images?.[0] || 'https://via.placeholder.com/150';
    const discount = product.discount_percentage || 0;

    return `
      <div class="product-card">
        <div class="product-image">
          <img src="${image}" alt="${product.name}" onerror="this.src='https://via.placeholder.com/150'">
          ${discount > 0 ? `<span class="discount-badge">${discount}%</span>` : ''}
        </div>
        <div class="product-info">
          <h3>${product.name}</h3>
          <p class="product-shop">${product.shop_name || 'Shop'}</p>
          <div class="product-rating">
            <span class="rating">${product.rating || 0}★</span>
            <span class="reviews">(${product.total_reviews || 0})</span>
          </div>
          <div class="product-price">
            <span class="price">$${product.price}</span>
            ${product.original_price ? `<span class="original-price">$${product.original_price}</span>` : ''}
          </div>
          <button class="btn-add-cart" onclick="app.addToCart({
            id: ${product.id},
            name: '${product.name}',
            price: ${product.price},
            image: '${image}'
          })">
            <i class="fas fa-shopping-cart"></i> Add to Cart
          </button>
        </div>
      </div>
    `;
  }

  renderShopCard(shop) {
    return `
      <div class="shop-card">
        <div class="shop-header">
          <img src="${shop.image || 'https://via.placeholder.com/200'}" alt="${shop.name}" 
            onerror="this.src='https://via.placeholder.com/200'">
        </div>
        <div class="shop-info">
          <h3>${shop.name}</h3>
          <p class="shop-location">${shop.location || 'Location'}</p>
          <div class="shop-rating">
            <span class="rating">${shop.rating || 0}★</span>
            <span class="status">${shop.is_active ? 'Open' : 'Closed'}</span>
          </div>
        </div>
      </div>
    `;
  }

  renderPropertyCard(property) {
    return `
      <div class="property-card">
        <div class="property-image">
          <img src="${property.image || 'https://via.placeholder.com/200'}" 
            alt="${property.name}" onerror="this.src='https://via.placeholder.com/200'">
        </div>
        <div class="property-info">
          <h3>${property.name || property.title}</h3>
          <p class="property-location">${property.location || 'Location'}</p>
          <div class="property-details">
            <span>${property.bedrooms || 0} Beds</span>
            <span>${property.bathrooms || 0} Baths</span>
          </div>
          <div class="property-price">
            <span class="price">$${property.price || 0}</span>
            <span class="period">${property.period || 'per month'}</span>
          </div>
          <button class="btn-primary" onclick="app.showNotification('Property inquiry sent!', 'success')">
            Inquire Now
          </button>
        </div>
      </div>
    `;
  }

  renderEventCard(event) {
    return `
      <div class="event-card">
        <div class="event-image">
          <img src="${event.image || 'https://via.placeholder.com/200'}" 
            alt="${event.name}" onerror="this.src='https://via.placeholder.com/200'">
          <span class="event-date">${event.date || 'TBD'}</span>
        </div>
        <div class="event-info">
          <h3>${event.name || event.title}</h3>
          <p class="event-location">${event.location || 'Location'}</p>
          <p class="event-description">${event.description || ''}</p>
          <div class="event-price">
            <span class="price">$${event.price || 0}</span>
          </div>
          <button class="btn-primary" onclick="app.addToCart({
            id: ${event.id},
            name: '${event.name || event.title}',
            price: ${event.price || 0},
            type: 'event'
          })">
            Book Ticket
          </button>
        </div>
      </div>
    `;
  }

  // ==================== CART MANAGEMENT ====================
  addToCart(product) {
    const existing = this.cart.find((p) => p.id === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      this.cart.push({ ...product, quantity: 1 });
    }
    this.saveCart();
    this.updateCartCount();
    this.showNotification(`${product.name} added to cart!`, 'success');
  }

  removeFromCart(index) {
    this.cart.splice(index, 1);
    this.saveCart();
    this.updateCartCount();
    this.renderCart();
  }

  updateCartQuantity(index, quantity) {
    this.cart[index].quantity = parseInt(quantity) || 1;
    this.saveCart();
  }

  updateCartCount() {
    const count = this.cart.reduce((sum, item) => sum + item.quantity, 0);
    document.querySelector('.cart-count').textContent = count;
  }

  checkout() {
    this.showNotification('Proceeding to checkout...', 'info');
    setTimeout(() => {
      this.showNotification('Order placed successfully!', 'success');
      this.cart = [];
      this.saveCart();
      this.updateCartCount();
      this.navigate('home');
    }, 2000);
  }

  // ==================== AUTHENTICATION ====================
  async handleLogin(event) {
    event.preventDefault();
    this.showLoadingSpinner(true);

    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;

    try {
      await apiClient.login(username, password);
      this.currentUser = await apiClient.getCurrentUser();
      this.showNotification('Login successful!', 'success');
      this.navigate('home');
    } catch (error) {
      this.showNotification(error.message || 'Login failed', 'error');
    } finally {
      this.showLoadingSpinner(false);
    }
  }

  async logout() {
    await apiClient.logout();
    this.currentUser = null;
    this.showNotification('Logged out', 'info');
    this.navigate('home');
  }

  showRegisterForm() {
    this.showNotification('Registration feature coming soon!', 'info');
  }

  showSearch() {
    const query = prompt('Search products...');
    if (query) {
      this.navigate('products');
      document.getElementById('searchInput').value = query;
      this.filterProducts();
    }
  }

  filterProducts() {
    const searchQuery = document.getElementById('searchInput')?.value.toLowerCase() || '';
    const categoryFilter = document.getElementById('categoryFilter')?.value || '';

    const filtered = this.products.filter(
      (p) =>
        p.name.toLowerCase().includes(searchQuery) &&
        (!categoryFilter || p.category === categoryFilter)
    );

    const grid = document.getElementById('productsGrid');
    if (grid) {
      grid.innerHTML = filtered.map((p) => this.renderProductCard(p)).join('');
      this.attachEventListeners();
    }
  }

  attachEventListeners() {
    document.querySelectorAll('.btn-add-cart').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        // Data passed via onclick attribute
      });
    });
  }

  // ==================== STORAGE ====================
  saveCart() {
    localStorage.setItem('cart', JSON.stringify(this.cart));
  }

  loadFromStorage() {
    const cart = localStorage.getItem('cart');
    if (cart) {
      this.cart = JSON.parse(cart);
      this.updateCartCount();
    }
  }
}

// Initialize app
const app = window.app = new MangoMartApp();
document.addEventListener('DOMContentLoaded', () => {
  app.init();
});
