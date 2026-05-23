# MangoMart - E-Commerce & Real Estate Platform

A comprehensive full-stack application built with Django REST Framework backend and Flutter mobile frontend, integrating e-commerce, real estate marketplace, and digital wallet services.

## Project Overview

MultiConnect is a multi-purpose platform that combines three main services:
1. **E-Commerce**: Shop browsing, product management, and order processing
2. **Real Estate**: Property marketplace with payment-locked detailed views
3. **Digital Wallet**: User financial management and transaction handling

## Architecture

### Backend (Django)
- **Framework**: Django REST Framework
- **Database**: PostgreSQL
- **API Style**: RESTful with token-based authentication

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Architecture Pattern**: MVVM with Providers

## Project Structure

### Backend Structure
```
backend/
├── config/              # Django configuration
├── apps/
│   ├── users/          # User management & authentication
│   ├── ecommerce/      # Shop and product management
│   ├── realestate/     # Property and listing management
│   ├── wallet/         # Digital wallet & transactions
│   ├── orders/         # Order processing
│   └── payments/       # Payment processing
├── manage.py
└── requirements.txt
```

### Frontend Structure
```
mobile/
├── lib/
│   ├── app/            # App shell with navigation
│   ├── core/           # Core utilities (API client, theme)
│   ├── models/         # Data models
│   ├── providers/      # Riverpod providers
│   ├── screens/        # UI screens
│   │   ├── auth/       # Authentication screens
│   │   ├── home/       # Home screen
│   │   ├── shops/      # Shop browsing
│   │   ├── products/   # Product management
│   │   ├── properties/ # Real estate
│   │   ├── cart/       # Shopping cart
│   │   ├── orders/     # Order history
│   │   └── profile/    # User profile
│   └── main.dart       # App entry point
├── pubspec.yaml
└── README.md
```

## Key Features

### E-Commerce
- Browse shops by category
- View detailed product information
- Shopping cart management
- Checkout with multiple payment methods
- Order history and tracking
- Product search and filtering

### Real Estate
- Property listings with location-based browsing
- Price and type filtering
- Locked property details (payment-protected)
- Property amenities and features display
- Review system
- Property map view (by city)

### Digital Wallet
- Wallet balance display
- Add funds functionality
- Withdrawal requests
- Transaction history
- Multi-currency support (MWK)

### Payments
- Mobile Money integration (Airtel, MTN, TNM)
- Bank transfer support
- Wallet-based payments
- Secure payment processing
- Transaction receipts

## Installation & Setup

### Backend Setup
1. Clone the repository
2. Create virtual environment: `python -m venv venv`
3. Activate virtual environment: `source venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Configure database in `settings.py`
6. Run migrations: `python manage.py migrate`
7. Create superuser: `python manage.py createsuperuser`
8. Start server: `python manage.py runserver`

### Frontend Setup
1. Ensure Flutter is installed: `flutter doctor`
2. Navigate to mobile directory: `cd mobile`
3. Get dependencies: `flutter pub get`
4. Configure API endpoint in `.env` or `lib/core/config/app_config.dart`
5. Run application: `flutter run`

## API Documentation

### Authentication Endpoints
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login
- `POST /api/auth/logout/` - User logout
- `GET /api/auth/user/` - Get current user
- `POST /api/auth/refresh/` - Refresh token

### E-Commerce Endpoints
- `GET /api/shops/` - List all shops
- `GET /api/shops/{id}/` - Shop details
- `GET /api/products/` - List products
- `GET /api/products/{id}/` - Product details
- `POST /api/orders/` - Create order
- `GET /api/orders/` - User orders

### Real Estate Endpoints
- `GET /api/properties/` - List properties
- `GET /api/properties/{id}/` - Property details
- `POST /api/properties/{id}/unlock/` - Unlock property
- `GET /api/properties/unlocked/` - User's unlocked properties

### Wallet Endpoints
- `GET /api/wallet/` - Get wallet balance
- `POST /api/wallet/add_funds/` - Add funds
- `POST /api/wallet/withdraw/` - Request withdrawal
- `GET /api/transactions/` - Transaction history

## Technology Stack

### Backend
- Django 4.x
- Django REST Framework
- PostgreSQL
- Celery (for async tasks)
- Django Channels (for WebSocket)
- Redis (for caching)

### Frontend
- Flutter 3.x
- Riverpod (state management)
- Dio (HTTP client)
- Freezed (code generation)
- Google Maps (future integration)

## Features in Detail

### Shopping Cart System
- Add/remove items
- Update quantities
- Calculate totals
- Persistent cart state

### Checkout Flow
1. Review cart items
2. Enter delivery address
3. Select payment method
4. Process payment
5. Order confirmation
6. Order tracking

### Property Unlock System
1. Browse properties
2. Select property
3. Choose unlock payment method
4. Process payment
5. Gain access to full details
6. Permanent access maintained

### User Profile Management
- View account information
- Update profile
- Manage saved addresses
- Payment method management
- Wishlist management

## State Management

The app uses Riverpod for state management with the following patterns:

- **FutureProvider**: For async data fetching (products, properties, orders)
- **StateProvider**: For simple state (current user, selected filters)
- **StateNotifierProvider**: For complex state mutations (cart, wallet)

Example:
```dart
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList('products/', fromJson: (json) => Product.fromJson(json));
});
```

## Error Handling

The app implements comprehensive error handling:
- Network error recovery
- User-friendly error messages
- Automatic retry mechanisms
- Offline support (cached data)

## Performance Optimizations

1. Image optimization and lazy loading
2. Pagination for large lists
3. Data caching with Riverpod
4. Efficient state updates
5. Code splitting and modularization

## Security

- Token-based authentication (JWT)
- Secure API communication (HTTPS)
- Password hashing on backend
- Input validation on both sides
- Protected payment transactions
- User data encryption

## Testing

### Backend Tests
- Unit tests for models and serializers
- Integration tests for API endpoints
- Authentication tests
- Payment processing tests

### Frontend Tests
- Widget tests for UI components
- Provider tests for business logic
- Integration tests for flows

## Future Enhancements

1. Real Google Maps integration
2. Augmented Reality for property viewing
3. Live chat support
4. Push notifications
5. Advanced analytics dashboard
6. Recommendation engine
7. Social features (reviews, ratings)
8. Video property tours
9. Virtual property tours
10. Advanced payment options

## API Rate Limiting

- 100 requests per minute for authenticated users
- 10 requests per minute for unauthenticated users

## Deployment

### Backend Deployment (Heroku/Railway)
1. Configure environment variables
2. Set up PostgreSQL database
3. Run migrations
4. Collect static files
5. Deploy

### Frontend Deployment
- iOS: Build and submit to App Store
- Android: Build APK/AAB and submit to Google Play

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Write tests
5. Submit pull request

## License

This project is licensed under the MIT License

## Support

For issues and feature requests, please create an issue on the repository.

## Authors

- Backend Team
- Mobile Team
- UI/UX Team

## Acknowledgments

- Flutter community
- Django community
- Contributors and testers
