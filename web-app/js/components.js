// ============================================
// REUSABLE COMPONENTS
// ============================================

/**
 * Create a product card
 */
function createProductCard(product, app) {
    const card = document.createElement('div');
    card.className = 'product-card';
    card.innerHTML = `
        <div class="product-image">
            <img src="${product.image}" alt="${product.name}" onerror="this.src='https://via.placeholder.com/200x200?text=${product.name}'">
        </div>
        <div class="product-info">
            <h3 class="product-name">${product.name}</h3>
            <p class="product-shop">${product.shop}</p>
            <div class="product-price">MK ${product.price.toLocaleString()}</div>
            <div class="product-actions">
                <button class="btn-primary" data-product-id="${product.id}">
                    <i class="fas fa-shopping-cart"></i> Add
                </button>
            </div>
        </div>
    `;

    card.querySelector('button').addEventListener('click', () => {
        app.addToCart(product);
    });

    return card;
}

/**
 * Create a shop card
 */
function createShopCard(shop, app) {
    const card = document.createElement('div');
    card.className = 'shop-card';
    card.innerHTML = `
        <div class="shop-header">
            <img src="${shop.banner}" alt="${shop.name}" onerror="this.src='https://via.placeholder.com/300x150?text=${shop.name}'">
        </div>
        <div class="shop-info">
            <h3 class="shop-name">${shop.name}</h3>
            <p class="shop-category">${shop.category}</p>
            <div class="shop-rating">
                <i class="fas fa-star"></i>
                <span>${shop.rating} (${shop.reviews})</span>
            </div>
            <button class="btn-primary shop-action">View Shop</button>
        </div>
    `;

    return card;
}

/**
 * Create a property card
 */
function createPropertyCard(property) {
    const card = document.createElement('div');
    card.className = 'property-card';
    card.innerHTML = `
        <div class="property-image">
            <img src="${property.image}" alt="${property.name}" onerror="this.src='https://via.placeholder.com/300x200?text=${property.name}'">
            <div class="property-price">MK ${property.pricePerNight.toLocaleString()}/night</div>
        </div>
        <div class="property-info">
            <h3 class="property-name">${property.name}</h3>
            <div class="property-location">
                <i class="fas fa-map-marker-alt"></i>
                <span>${property.location}</span>
            </div>
            <div class="property-details">
                <span><i class="fas fa-bed"></i> ${property.beds}</span>
                <span><i class="fas fa-bath"></i> ${property.baths}</span>
                <span><i class="fas fa-wifi"></i> WiFi</span>
            </div>
        </div>
    `;

    return card;
}

/**
 * Create an event card
 */
function createEventCard(event) {
    const card = document.createElement('div');
    card.className = 'event-card';
    card.innerHTML = `
        <div class="event-image">
            <img src="${event.image}" alt="${event.name}">
            <span class="event-date">${event.date}</span>
        </div>
        <div class="event-info">
            <h3 class="event-name">${event.name}</h3>
            <p class="event-location">
                <i class="fas fa-map-marker-alt"></i> ${event.location}
            </p>
            <p class="event-description">${event.description}</p>
            <div class="event-pricing">
                <span class="event-price">From MK ${event.price.toLocaleString()}</span>
                <button class="btn-primary">Buy Tickets</button>
            </div>
        </div>
    `;

    return card;
}

/**
 * Create a lodge card
 */
function createLodgeCard(lodge) {
    const card = document.createElement('div');
    card.className = 'lodge-card';
    card.innerHTML = `
        <div class="lodge-image">
            <img src="${lodge.image}" alt="${lodge.name}">
        </div>
        <div class="lodge-info">
            <h3 class="lodge-name">${lodge.name}</h3>
            <p class="lodge-location">
                <i class="fas fa-map-marker-alt"></i> ${lodge.location}
            </p>
            <div class="lodge-rating">
                <i class="fas fa-star"></i>
                <span>${lodge.rating}</span>
            </div>
            <p class="lodge-price">From MK ${lodge.pricePerNight.toLocaleString()}/night</p>
            <button class="btn-primary lodge-action">Book Now</button>
        </div>
    `;

    return card;
}

/**
 * Create a delivery item
 */
function createDeliveryItem(delivery) {
    const item = document.createElement('div');
    item.className = 'delivery-item';
    item.innerHTML = `
        <div class="delivery-header">
            <span class="delivery-id">#${delivery.id}</span>
            <span class="delivery-status ${delivery.status.toLowerCase()}">${delivery.status}</span>
        </div>
        <div class="delivery-details">
            <p><strong>From:</strong> ${delivery.from}</p>
            <p><strong>To:</strong> ${delivery.to}</p>
            <p><strong>Date:</strong> ${delivery.date}</p>
            <p><strong>Cost:</strong> MK ${delivery.cost.toLocaleString()}</p>
        </div>
        <div class="delivery-actions">
            <button class="btn-primary btn-sm">Track</button>
            <button class="btn-secondary btn-sm">Details</button>
        </div>
    `;

    return item;
}

/**
 * Create a notification toast
 */
function showToast(message, type = 'info', duration = 3000) {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <i class="fas fa-check-circle"></i>
        <span>${message}</span>
    `;
    
    document.body.appendChild(toast);
    
    // Trigger animation
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Remove after duration
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, duration);
}

/**
 * Create a modal
 */
function createModal(title, content, actions = []) {
    const modal = document.createElement('div');
    modal.className = 'modal';
    
    let actionsHTML = '';
    if (actions.length > 0) {
        actionsHTML = '<div class="modal-actions">' + 
            actions.map(action => 
                `<button class="btn-${action.type || 'primary'}" data-action="${action.id}">${action.label}</button>`
            ).join('') + 
            '</div>';
    }
    
    modal.innerHTML = `
        <div class="modal-backdrop"></div>
        <div class="modal-content">
            <div class="modal-header">
                <h2>${title}</h2>
                <button class="modal-close"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                ${content}
            </div>
            ${actionsHTML}
        </div>
    `;
    
    // Close handlers
    modal.querySelector('.modal-close').addEventListener('click', () => modal.remove());
    modal.querySelector('.modal-backdrop').addEventListener('click', () => modal.remove());
    
    // Action handlers
    actions.forEach(action => {
        const btn = modal.querySelector(`[data-action="${action.id}"]`);
        if (btn && action.callback) {
            btn.addEventListener('click', action.callback);
        }
    });
    
    document.body.appendChild(modal);
    return modal;
}

/**
 * Create a loading spinner
 */
function createSpinner() {
    const spinner = document.createElement('div');
    spinner.className = 'spinner';
    spinner.innerHTML = `
        <div class="spinner-ring"></div>
        <p>Loading...</p>
    `;
    return spinner;
}

/**
 * Format currency
 */
function formatCurrency(amount, currency = 'MK') {
    return `${currency} ${amount.toLocaleString('en-US')}`;
}

/**
 * Format date
 */
function formatDate(date) {
    return new Date(date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

/**
 * Format time
 */
function formatTime(time) {
    return new Date(time).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
    });
}

/**
 * Validate email
 */
function isValidEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

/**
 * Validate phone
 */
function isValidPhone(phone) {
    const re = /^[\d\s\-\+\(\)]{10,}$/;
    return re.test(phone);
}
