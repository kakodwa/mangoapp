/**
 * API Client for MangoMart Web App
 * Handles all HTTP requests with JWT authentication
 * Base URL: http://127.0.0.1:8000/api/
 */

class ApiClient {
  constructor() {
    this.baseURL = 'http://127.0.0.1:8000/api/';
    this.timeout = 30000; // 30 seconds
    this.headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  // ==================== TOKEN MANAGEMENT ====================
  getAccessToken() {
    return localStorage.getItem('access_token');
  }

  getRefreshToken() {
    return localStorage.getItem('refresh_token');
  }

  setTokens(accessToken, refreshToken) {
    localStorage.setItem('access_token', accessToken);
    localStorage.setItem('refresh_token', refreshToken);
  }

  clearTokens() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user_id');
    localStorage.removeItem('username');
  }

  // ==================== CORE HTTP METHODS ====================
  async request(method, endpoint, options = {}) {
    const url = new URL(this.baseURL + endpoint);
    const config = {
      method,
      headers: { ...this.headers },
      signal: AbortSignal.timeout(this.timeout),
      ...options,
    };

    // Add query parameters
    if (options.params) {
      Object.entries(options.params).forEach(([key, value]) => {
        url.searchParams.append(key, value);
      });
    }

    // Add JWT token if available
    const token = this.getAccessToken();
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    try {
      console.log(`[API] ${method.toUpperCase()} ${endpoint}`, options);
      const response = await fetch(url.toString(), config);

      // Handle 401 Unauthorized - try to refresh token
      if (response.status === 401) {
        const refreshed = await this.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return this.request(method, endpoint, options);
        } else {
          // Redirect to login
          window.app.navigate('auth');
          throw new Error('Unauthorized: Please login again');
        }
      }

      // Handle other errors
      if (!response.ok) {
        const errorData = await this.parseResponse(response);
        const message = errorData.message || errorData.error || errorData.detail || response.statusText;
        const error = new Error(message);
        error.status = response.status;
        error.data = errorData;
        throw error;
      }

      return await this.parseResponse(response);
    } catch (error) {
      console.error(`[API ERROR] ${method.toUpperCase()} ${endpoint}:`, error);
      throw error;
    }
  }

  async parseResponse(response) {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    }
    return await response.text();
  }

  async get(endpoint, params = {}) {
    return this.request('GET', endpoint, { params });
  }

  async post(endpoint, data = {}) {
    return this.request('POST', endpoint, {
      body: JSON.stringify(data),
    });
  }

  async put(endpoint, data = {}) {
    return this.request('PUT', endpoint, {
      body: JSON.stringify(data),
    });
  }

  async patch(endpoint, data = {}) {
    return this.request('PATCH', endpoint, {
      body: JSON.stringify(data),
    });
  }

  async delete(endpoint) {
    return this.request('DELETE', endpoint);
  }

  // ==================== AUTHENTICATION ====================
  async login(username, password) {
    try {
      const response = await this.post('token/', { username, password });
      this.setTokens(response.access, response.refresh);
      
      // Store user info
      const user = await this.getCurrentUser();
      localStorage.setItem('user_id', user.id);
      localStorage.setItem('username', user.username);
      localStorage.setItem('user_data', JSON.stringify(user));
      
      return response;
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    }
  }

  async register(userData) {
    try {
      const response = await this.post('users/register/', {
        username: userData.username,
        email: userData.email,
        password: userData.password,
        first_name: userData.firstName,
        last_name: userData.lastName,
        user_type: userData.userType || 'buyer',
      });
      return response;
    } catch (error) {
      console.error('Registration failed:', error);
      throw error;
    }
  }

  async logout() {
    this.clearTokens();
    return Promise.resolve();
  }

  async refreshToken() {
    try {
      const refreshToken = this.getRefreshToken();
      if (!refreshToken) return false;

      const response = await this.post('token/refresh/', { refresh: refreshToken });
      this.setTokens(response.access, response.refresh);
      return true;
    } catch (error) {
      console.error('Token refresh failed:', error);
      this.clearTokens();
      return false;
    }
  }

  async getCurrentUser() {
    return this.get('users/me/');
  }

  // ==================== PRODUCTS ====================
  async getProducts(params = {}) {
    return this.get('products/', params);
  }

  async getProductById(id) {
    return this.get(`products/${id}/`);
  }

  async createProduct(data) {
    return this.post('products/', data);
  }

  async updateProduct(id, data) {
    return this.put(`products/${id}/`, data);
  }

  async deleteProduct(id) {
    return this.delete(`products/${id}/`);
  }

  // ==================== SHOPS ====================
  async getShops(params = {}) {
    return this.get('shops/', params);
  }

  async getShopById(id) {
    return this.get(`shops/${id}/`);
  }

  async getShopProducts(shopId) {
    return this.get('products/', { shop: shopId });
  }

  // ==================== PROPERTIES ====================
  async getProperties(params = {}) {
    return this.get('properties/', params);
  }

  async getPropertyById(id) {
    return this.get(`properties/${id}/`);
  }

  async createProperty(data) {
    return this.post('properties/', data);
  }

  // ==================== EVENTS ====================
  async getEvents(params = {}) {
    return this.get('events/', params);
  }

  async getEventById(id) {
    return this.get(`events/${id}/`);
  }

  async createEvent(data) {
    return this.post('events/', data);
  }

  // ==================== BANNERS ====================
  async getBanners() {
    return this.get('banners/');
  }

  // ==================== CART / ORDERS ====================
  async getCart() {
    return this.get('cart/');
  }

  async addToCart(productId, quantity = 1) {
    return this.post('cart/add/', {
      product_id: productId,
      quantity,
    });
  }

  async removeFromCart(cartItemId) {
    return this.delete(`cart/${cartItemId}/`);
  }

  async createOrder(data) {
    return this.post('orders/', data);
  }

  async getOrders() {
    return this.get('orders/');
  }

  // ==================== PAYMENTS ====================
  async initiatePayment(paymentData) {
    return this.post('payments/initiate_payment/', paymentData);
  }

  async checkPaymentStatus(reference) {
    return this.get('payments/check_payment_status/', { reference });
  }

  async getMyPayments() {
    return this.get('payments/my_payments/');
  }

  // ==================== UTILITIES ====================
  async uploadFile(file, fieldName = 'image') {
    const formData = new FormData();
    formData.append(fieldName, file);

    const config = {
      method: 'POST',
      headers: {
        // Don't set Content-Type for FormData - browser will do it with boundary
      },
      signal: AbortSignal.timeout(this.timeout),
    };

    const token = this.getAccessToken();
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(this.baseURL + 'upload/', config);
    if (!response.ok) throw new Error('Upload failed');
    return this.parseResponse(response);
  }

  async healthCheck() {
    try {
      const response = await fetch(this.baseURL + 'health/', {
        method: 'GET',
        signal: AbortSignal.timeout(5000),
      });
      return response.ok;
    } catch {
      return false;
    }
  }
}

// Create and export singleton instance
window.apiClient = new ApiClient();
