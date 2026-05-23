// ============================================
// APP INITIALIZATION & ROUTING
// ============================================

class MangoMartApp {
    constructor() {
        this.currentPage = 'home';
        this.cart = [];
        this.user = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupRouting();
        this.loadCart();
        this.checkAuth();
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const page = link.getAttribute('href').substring(1);
                this.navigateTo(page);
            });
        });

        // Hamburger menu
        const hamburger = document.getElementById('hamburger');
        hamburger.addEventListener('click', () => {
            hamburger.classList.toggle('active');
            document.getElementById('navbarMenu').classList.toggle('active');
        });

        // Quick action buttons
        document.querySelectorAll('.quick-action-btn').forEach((btn, index) => {
            btn.addEventListener('click', () => {
                const pages = ['shops', 'properties', 'delivery', 'hospitality', 'events', 'events'];
                this.navigateTo(pages[index]);
            });
        });

        // Search and filter
        document.getElementById('productSearch')?.addEventListener('input', () => this.filterProducts());
        document.getElementById('shopSearch')?.addEventListener('input', () => this.filterShops());
        document.getElementById('propertySearch')?.addEventListener('input', () => this.filterProperties());

        // Filter chips
        document.querySelectorAll('.chip').forEach(chip => {
            chip.addEventListener('click', (e) => {
                document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
                e.target.classList.add('active');
                this.filterProducts();
            });
        });

        // Cart button
        document.getElementById('cartBtn').addEventListener('click', () => {
            this.showCart();
        });

        // Profile button
        document.getElementById('profileBtn').addEventListener('click', () => {
            if (this.user) {
                this.navigateTo('profile');
            } else {
                this.navigateTo('auth');
            }
        });

        // Login form
        document.getElementById('loginForm')?.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        document.getElementById('toggleRegister')?.addEventListener('click', () => {
            this.navigateTo('register');
        });

        // Menu items
        document.querySelectorAll('.menu-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const action = item.textContent.trim();
                this.handleMenuAction(action);
            });
        });
    }

    setupRouting() {
        window.addEventListener('hashchange', () => {
            const hash = window.location.hash.substring(1) || 'home';
            this.navigateTo(hash);
        });
    }

    navigateTo(page) {
        // Close mobile menu
        const hamburger = document.getElementById('hamburger');
        hamburger.classList.remove('active');
        document.getElementById('navbarMenu').classList.remove('active');

        // Hide all pages
        document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));

        // Show selected page
        const pageEl = document.getElementById(page);
        if (pageEl) {
            pageEl.classList.add('active');
            this.currentPage = page;
            window.location.hash = page;

            // Load content
            if (page === 'home') {
                this.loadHome();
            } else if (page === 'products') {
                this.loadProducts();
            } else if (page === 'shops') {
                this.loadShops();
            } else if (page === 'properties') {
                this.loadProperties();
            }
        }
    }

    checkAuth() {
        const userData = localStorage.getItem('user');
        if (userData) {
            this.user = JSON.parse(userData);
        }
    }

    handleLogin() {
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        if (!username || !password) {
            alert('Please fill in all fields');
            return;
        }

        // Simulate login (in production, call API)
        const user = {
            id: 1,
            username: username,
            firstName: 'John',
            lastName: 'Doe',
            email: `${username}@example.com`,
            userType: 'buyer'
        };

        localStorage.setItem('user', JSON.stringify(user));
        this.user = user;
        alert('Login successful!');
        this.navigateTo('home');
    }

    handleMenuAction(action) {
        if (action === 'Logout') {
            localStorage.removeItem('user');
            this.user = null;
            alert('Logged out successfully');
            this.navigateTo('home');
        }
    }

    loadCart() {
        const cartData = localStorage.getItem('cart');
        if (cartData) {
            this.cart = JSON.parse(cartData);
        }
        this.updateCartCount();
    }

    saveCart() {
        localStorage.setItem('cart', JSON.stringify(this.cart));
        this.updateCartCount();
    }

    updateCartCount() {
        const cartCount = document.querySelector('.cart-count');
        if (cartCount) {
            cartCount.textContent = this.cart.length;
        }
    }

    addToCart(product) {
        const cartItem = this.cart.find(item => item.id === product.id);
        if (cartItem) {
            cartItem.quantity += 1;
        } else {
            this.cart.push({ ...product, quantity: 1 });
        }
        this.saveCart();
        alert(`${product.name} added to cart!`);
    }

    showCart() {
        if (this.cart.length === 0) {
            alert('Your cart is empty');
            return;
        }
        alert(`Your cart has ${this.cart.length} items`);
    }

    // Page loaders
    loadHome() {
        this.loadFeaturedShops();
        this.loadFeaturedProducts();
        this.loadFeaturedProperties();
    }

    loadFeaturedShops() {
        const container = document.getElementById('shopsContainer');
        if (!container) return;

        container.innerHTML = '';
        const featuredShops = window.shopsData.slice(0, 3);
        
        featuredShops.forEach(shop => {
            container.appendChild(createShopCard(shop, this));
        });
    }

    loadFeaturedProducts() {
        const container = document.getElementById('productsContainer');
        if (!container) return;

        container.innerHTML = '';
        const featuredProducts = window.productsData.slice(0, 4);
        
        featuredProducts.forEach(product => {
            container.appendChild(createProductCard(product, this));
        });
    }

    loadFeaturedProperties() {
        const container = document.getElementById('propertiesContainer');
        if (!container) return;

        container.innerHTML = '';
        const featuredProperties = window.propertiesData.slice(0, 3);
        
        featuredProperties.forEach(property => {
            container.appendChild(createPropertyCard(property));
        });
    }

    loadProducts() {
        const container = document.getElementById('productsPageContainer');
        if (!container) return;

        container.innerHTML = '';
        window.productsData.forEach(product => {
            container.appendChild(createProductCard(product, this));
        });
    }

    loadShops() {
        const container = document.getElementById('shopsPageContainer');
        if (!container) return;

        container.innerHTML = '';
        window.shopsData.forEach(shop => {
            container.appendChild(createShopCard(shop, this));
        });
    }

    loadProperties() {
        const container = document.getElementById('propertiesPageContainer');
        if (!container) return;

        container.innerHTML = '';
        window.propertiesData.forEach(property => {
            container.appendChild(createPropertyCard(property));
        });
    }

    filterProducts() {
        const search = document.getElementById('productSearch')?.value.toLowerCase() || '';
        const activeChip = document.querySelector('.chip.active')?.textContent.trim().toLowerCase() || 'all';
        
        const filtered = window.productsData.filter(p => {
            const matchesSearch = p.name.toLowerCase().includes(search);
            const matchesCategory = activeChip === 'all' || p.category.toLowerCase() === activeChip;
            return matchesSearch && matchesCategory;
        });

        const container = document.getElementById('productsPageContainer');
        if (container) {
            container.innerHTML = '';
            filtered.forEach(product => {
                container.appendChild(createProductCard(product, this));
            });
        }
    }

    filterShops() {
        const search = document.getElementById('shopSearch')?.value.toLowerCase() || '';
        
        const filtered = window.shopsData.filter(s => {
            return s.name.toLowerCase().includes(search);
        });

        const container = document.getElementById('shopsPageContainer');
        if (container) {
            container.innerHTML = '';
            filtered.forEach(shop => {
                container.appendChild(createShopCard(shop, this));
            });
        }
    }

    filterProperties() {
        const search = document.getElementById('propertySearch')?.value.toLowerCase() || '';
        
        const filtered = window.propertiesData.filter(p => {
            return p.name.toLowerCase().includes(search) || p.location.toLowerCase().includes(search);
        });

        const container = document.getElementById('propertiesPageContainer');
        if (container) {
            container.innerHTML = '';
            filtered.forEach(property => {
                container.appendChild(createPropertyCard(property));
            });
        }
    }
}

// ============================================
// APP INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    window.app = new MangoMartApp();
});
