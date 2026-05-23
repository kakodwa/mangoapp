# MangoMart - Multi-Service Marketplace Platform

A comprehensive full-stack platform built with Django REST Framework backend and Flutter mobile frontend, integrating e-commerce, real estate, hospitality booking, event ticketing, and digital wallet services.

## Project Overview

MangoMart is a multi-purpose digital marketplace that combines multiple services into one unified platform:

1. **E-Commerce** – Shop browsing, product management, and order processing  
2. **Real Estate** – Property marketplace with premium unlockable listings  
3. **Hospitality** – Lodge and room booking management system  
4. **Events & Ticketing** – Event discovery and digital ticket purchasing  
5. **Digital Wallet & Payments** – User financial management and transaction handling  

---

# Architecture

## Backend (Django)

- **Framework**: Django REST Framework
- **Database**: PostgreSQL
- **Authentication**: JWT Token Authentication
- **API Style**: RESTful APIs

## Frontend (Flutter)

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Architecture Pattern**: MVVM with Providers

---

# Project Structure

## Backend Structure

```text
backend/
├── config/                 # Django configuration
├── apps/
│   ├── users/              # User management & authentication
│   ├── ecommerce/          # Shops, products & banners
│   ├── orders/             # Orders and deliveries
│   ├── payments/           # Payment processing
│   ├── realestate/         # Properties and listings
│   ├── hospitality/        # Lodges, rooms & bookings
│   ├── events/             # Events and ticketing
│   ├── wallet/             # Digital wallet & transactions
│   └── notifications/      # Notifications (future)
├── manage.py
└── requirements.txt
```

---

## Frontend Structure

```text
mobile/
├── lib/
│   ├── app/                # App shell & navigation
│   ├── core/               # Core utilities & API client
│   ├── models/             # Data models
│   ├── providers/          # Riverpod providers
│   ├── screens/
│   │   ├── auth/           # Authentication
│   │   ├── home/           # Home dashboard
│   │   ├── shops/          # Shop management
│   │   ├── products/       # Products
│   │   ├── cart/           # Shopping cart
│   │   ├── orders/         # Orders
│   │   ├── properties/     # Real estate
│   │   ├── lodges/         # Hospitality & bookings
│   │   ├── events/         # Events & tickets
│   │   ├── wallet/         # Wallet & transactions
│   │   └── profile/        # User profile
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

# Core Features

## E-Commerce

- Browse shops by category
- Product search and filtering
- Shopping cart system
- Secure checkout process
- Order tracking and history
- Delivery management

---

## Real Estate

- Property listings marketplace
- Premium property unlocking system
- Property amenities display
- Reviews and ratings
- City and location filtering
- Image galleries

---

## Hospitality Booking

- Lodge browsing and search
- Room listings with pricing
- Amenities management
- Room availability checking
- Online room booking
- Booking history and confirmations

### Hospitality Features

- Hotel/lodge profile management
- Multiple room types
- Booking date selection
- Guest management
- Booking payment integration
- Booking status tracking

---

## Events & Ticketing

- Browse upcoming events
- Event categories and filtering
- Digital ticket purchasing
- Ticket QR/verification support
- Ticket ownership management
- Event organizer support

### Event Features

- Event management dashboard
- Ticket types and pricing
- Seat/slot management
- Ticket purchase history
- Digital ticket validation
- Event banners and promotions

---

## Digital Wallet

- Wallet balance tracking
- Add funds
- Withdraw funds
- Transaction history
- Wallet-based purchases
- Multi-service payment support

---

## Payments

- Airtel Money integration
- TNM Mpamba integration
- Bank transfer support
- Wallet payments
- Secure transaction handling
- Payment receipts

---

# API Root

## Base Endpoint

```http
GET /api/
```

## Available API Endpoints

```json
{
    "users": "/api/users/",
    "shops": "/api/shops/",
    "products": "/api/products/",
    "orders": "/api/orders/",
    "payments": "/api/payments/",
    "properties": "/api/properties/",
    "banners": "/api/banners/",
    "deliveries": "/api/deliveries/",
    "lodges": "/api/lodges/",
    "rooms": "/api/rooms/",
    "amenities": "/api/amenities/",
    "bookings": "/api/bookings/",
    "events": "/api/events/",
    "tickets": "/api/tickets/"
}
```

---

# Installation & Setup

## Backend Setup

1. Clone the repository
2. Create virtual environment:

```bash
python -m venv venv
```

3. Activate virtual environment

Linux/macOS:

```bash
source venv/bin/activate
```

Windows:

```bash
venv\Scripts\activate
```

4. Install dependencies:

```bash
pip install -r requirements.txt
```

5. Run migrations:

```bash
python manage.py migrate
```

6. Create superuser:

```bash
python manage.py createsuperuser
```

7. Start development server:

```bash
python manage.py runserver
```

---

## Frontend Setup

1. Install Flutter SDK
2. Navigate to mobile folder:

```bash
cd mobile
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run app:

```bash
flutter run
```

---

# Security Features

- JWT authentication
- Secure payment handling
- HTTPS communication
- Encrypted transactions
- Permission-based APIs
- Input validation

---

# Future Enhancements

1. QR Ticket Scanner
2. Google Maps Integration
3. Push Notifications
4. AI Recommendations
5. Hotel Reviews
6. Live Event Streaming
7. Vendor Dashboards
8. Multi-language Support

---

# License

MIT License

---

# Authors

- Backend Team
- Mobile Team
- UI/UX Team

---

# Acknowledgments

- Flutter Community
- Django Community
- Contributors & Testers
