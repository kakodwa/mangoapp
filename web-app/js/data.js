// ============================================
// SAMPLE DATA - MOCK BACKEND
// ============================================

// Products data
window.productsData = [
    {
        id: 1,
        name: 'Fresh Mangoes Bundle',
        shop: 'Mango Paradise',
        price: 2500,
        category: 'Groceries',
        image: 'https://via.placeholder.com/200x200?text=Fresh+Mangoes',
        rating: 4.8,
        reviews: 125,
        district: 'Lilongwe'
    },
    {
        id: 2,
        name: 'Wireless Headphones',
        shop: 'TechHub',
        price: 8500,
        category: 'Electronics',
        image: 'https://via.placeholder.com/200x200?text=Headphones',
        rating: 4.5,
        reviews: 89,
        district: 'Blantyre'
    },
    {
        id: 3,
        name: 'Cotton T-Shirt',
        shop: 'Fashion Plus',
        price: 3200,
        category: 'Fashion',
        image: 'https://via.placeholder.com/200x200?text=T-Shirt',
        rating: 4.3,
        reviews: 56,
        district: 'Lilongwe'
    },
    {
        id: 4,
        name: 'Rice 10kg',
        shop: 'Quality Grains',
        price: 4500,
        category: 'Groceries',
        image: 'https://via.placeholder.com/200x200?text=Rice',
        rating: 4.7,
        reviews: 234,
        district: 'Mzuzu'
    },
    {
        id: 5,
        name: 'Bed Sheets Set',
        shop: 'Home Comfort',
        price: 5600,
        category: 'Home',
        image: 'https://via.placeholder.com/200x200?text=Bed+Sheets',
        rating: 4.6,
        reviews: 78,
        district: 'Zomba'
    },
    {
        id: 6,
        name: 'Face Moisturizer',
        shop: 'Beauty Essentials',
        price: 2800,
        category: 'Beauty',
        image: 'https://via.placeholder.com/200x200?text=Moisturizer',
        rating: 4.4,
        reviews: 145,
        district: 'Lilongwe'
    },
    {
        id: 7,
        name: 'Smart Watch',
        shop: 'TechHub',
        price: 12500,
        category: 'Electronics',
        image: 'https://via.placeholder.com/200x200?text=Smart+Watch',
        rating: 4.7,
        reviews: 201,
        district: 'Blantyre'
    },
    {
        id: 8,
        name: 'Jeans Pants',
        shop: 'Fashion Plus',
        price: 6200,
        category: 'Fashion',
        image: 'https://via.placeholder.com/200x200?text=Jeans',
        rating: 4.5,
        reviews: 92,
        district: 'Lilongwe'
    },
    {
        id: 9,
        name: 'Kitchen Blender',
        shop: 'Home Appliances',
        price: 8900,
        category: 'Home',
        image: 'https://via.placeholder.com/200x200?text=Blender',
        rating: 4.6,
        reviews: 67,
        district: 'Mangochi'
    },
    {
        id: 10,
        name: 'Body Lotion',
        shop: 'Beauty Essentials',
        price: 1800,
        category: 'Beauty',
        image: 'https://via.placeholder.com/200x200?text=Body+Lotion',
        rating: 4.5,
        reviews: 189,
        district: 'Lilongwe'
    },
    {
        id: 11,
        name: 'USB-C Cable',
        shop: 'TechHub',
        price: 1200,
        category: 'Electronics',
        image: 'https://via.placeholder.com/200x200?text=USB+Cable',
        rating: 4.3,
        reviews: 156,
        district: 'Blantyre'
    },
    {
        id: 12,
        name: 'Denim Jacket',
        shop: 'Fashion Plus',
        price: 9500,
        category: 'Fashion',
        image: 'https://via.placeholder.com/200x200?text=Jacket',
        rating: 4.6,
        reviews: 74,
        district: 'Lilongwe'
    }
];

// Shops data
window.shopsData = [
    {
        id: 1,
        name: 'Mango Paradise',
        category: 'Fresh Fruits & Vegetables',
        banner: 'https://via.placeholder.com/300x150?text=Mango+Paradise',
        logo: 'https://via.placeholder.com/50x50?text=MP',
        rating: 4.8,
        reviews: 342,
        district: 'Lilongwe',
        verified: true
    },
    {
        id: 2,
        name: 'TechHub',
        category: 'Electronics & Gadgets',
        banner: 'https://via.placeholder.com/300x150?text=TechHub',
        logo: 'https://via.placeholder.com/50x50?text=TH',
        rating: 4.6,
        reviews: 289,
        district: 'Blantyre',
        verified: true
    },
    {
        id: 3,
        name: 'Fashion Plus',
        category: 'Clothing & Accessories',
        banner: 'https://via.placeholder.com/300x150?text=Fashion+Plus',
        logo: 'https://via.placeholder.com/50x50?text=FP',
        rating: 4.5,
        reviews: 215,
        district: 'Lilongwe',
        verified: false
    },
    {
        id: 4,
        name: 'Quality Grains',
        category: 'Staple Foods',
        banner: 'https://via.placeholder.com/300x150?text=Quality+Grains',
        logo: 'https://via.placeholder.com/50x50?text=QG',
        rating: 4.7,
        reviews: 401,
        district: 'Mzuzu',
        verified: true
    },
    {
        id: 5,
        name: 'Home Comfort',
        category: 'Home & Living',
        banner: 'https://via.placeholder.com/300x150?text=Home+Comfort',
        logo: 'https://via.placeholder.com/50x50?text=HC',
        rating: 4.4,
        reviews: 167,
        district: 'Zomba',
        verified: true
    },
    {
        id: 6,
        name: 'Beauty Essentials',
        category: 'Beauty & Personal Care',
        banner: 'https://via.placeholder.com/300x150?text=Beauty+Essentials',
        logo: 'https://via.placeholder.com/50x50?text=BE',
        rating: 4.5,
        reviews: 298,
        district: 'Lilongwe',
        verified: true
    }
];

// Properties data
window.propertiesData = [
    {
        id: 1,
        name: 'City Center Apartment',
        location: 'Lilongwe, Malawi',
        pricePerNight: 8500,
        image: 'https://via.placeholder.com/300x200?text=City+Apartment',
        beds: 2,
        baths: 1,
        amenities: ['WiFi', 'AC', 'Kitchen'],
        rating: 4.8,
        reviews: 45,
        type: 'apartment'
    },
    {
        id: 2,
        name: 'Lakeside Villa',
        location: 'Mangochi, Malawi',
        pricePerNight: 15000,
        image: 'https://via.placeholder.com/300x200?text=Lakeside+Villa',
        beds: 3,
        baths: 2,
        amenities: ['WiFi', 'Pool', 'Gym'],
        rating: 4.9,
        reviews: 78,
        type: 'villa'
    },
    {
        id: 3,
        name: 'Modern Studio',
        location: 'Blantyre, Malawi',
        pricePerNight: 5500,
        image: 'https://via.placeholder.com/300x200?text=Modern+Studio',
        beds: 1,
        baths: 1,
        amenities: ['WiFi', 'AC'],
        rating: 4.6,
        reviews: 32,
        type: 'studio'
    },
    {
        id: 4,
        name: 'Mountain Retreat',
        location: 'Mzuzu, Malawi',
        pricePerNight: 12000,
        image: 'https://via.placeholder.com/300x200?text=Mountain+Retreat',
        beds: 4,
        baths: 3,
        amenities: ['WiFi', 'Fireplace', 'Balcony'],
        rating: 4.7,
        reviews: 56,
        type: 'house'
    },
    {
        id: 5,
        name: 'Business Hotel',
        location: 'Lilongwe, Malawi',
        pricePerNight: 7200,
        image: 'https://via.placeholder.com/300x200?text=Business+Hotel',
        beds: 2,
        baths: 1,
        amenities: ['WiFi', 'Parking', 'Restaurant'],
        rating: 4.5,
        reviews: 120,
        type: 'hotel'
    },
    {
        id: 6,
        name: 'Beachfront Cottage',
        location: 'Salima, Malawi',
        pricePerNight: 11500,
        image: 'https://via.placeholder.com/300x200?text=Beachfront+Cottage',
        beds: 2,
        baths: 2,
        amenities: ['WiFi', 'Beach Access', 'BBQ'],
        rating: 4.8,
        reviews: 89,
        type: 'cottage'
    }
];

// Events data
window.eventsData = [
    {
        id: 1,
        name: 'Lilongwe Music Festival 2024',
        location: 'Lilongwe, Malawi',
        date: '2024-06-15',
        time: '18:00',
        image: 'https://via.placeholder.com/300x200?text=Music+Festival',
        description: 'Join us for the biggest music festival of the year featuring local and international artists.',
        price: 5000,
        capacity: 5000,
        ticketsSold: 3200
    },
    {
        id: 2,
        name: 'Tech Conference Africa',
        location: 'Blantyre, Malawi',
        date: '2024-07-10',
        time: '09:00',
        image: 'https://via.placeholder.com/300x200?text=Tech+Conference',
        description: 'Explore the latest in African technology innovation and startups.',
        price: 8500,
        capacity: 1000,
        ticketsSold: 650
    },
    {
        id: 3,
        name: 'Food & Wine Expo',
        location: 'Lilongwe, Malawi',
        date: '2024-08-20',
        time: '12:00',
        image: 'https://via.placeholder.com/300x200?text=Food+Expo',
        description: 'Experience culinary delights from across Malawi and beyond.',
        price: 3500,
        capacity: 2000,
        ticketsSold: 1400
    }
];

// Lodges data
window.lodgesData = [
    {
        id: 1,
        name: 'Lilongwe Grand Hotel',
        location: 'Lilongwe City Center',
        pricePerNight: 12500,
        image: 'https://via.placeholder.com/300x200?text=Grand+Hotel',
        beds: 40,
        rooms: 20,
        amenities: ['WiFi', 'Restaurant', 'Gym', 'Pool'],
        rating: 4.7,
        reviews: 245
    },
    {
        id: 2,
        name: 'Lake Malawi Resort',
        location: 'Mangochi, Malawi',
        pricePerNight: 18500,
        image: 'https://via.placeholder.com/300x200?text=Lake+Resort',
        beds: 60,
        rooms: 30,
        amenities: ['WiFi', 'Beach', 'Water Sports', 'Spa'],
        rating: 4.9,
        reviews: 412
    },
    {
        id: 3,
        name: 'Blantyre Inn',
        location: 'Blantyre City',
        pricePerNight: 8900,
        image: 'https://via.placeholder.com/300x200?text=Blantyre+Inn',
        beds: 30,
        rooms: 15,
        amenities: ['WiFi', 'Restaurant', 'Parking'],
        rating: 4.4,
        reviews: 156
    },
    {
        id: 4,
        name: 'Mzuzu Mountain Lodge',
        location: 'Mzuzu, Malawi',
        pricePerNight: 14200,
        image: 'https://via.placeholder.com/300x200?text=Mountain+Lodge',
        beds: 50,
        rooms: 25,
        amenities: ['WiFi', 'Fireplace', 'Hiking', 'Restaurant'],
        rating: 4.6,
        reviews: 178
    }
];

// Banners data
window.bannersData = [
    {
        id: 1,
        title: 'Summer Sale 2024',
        subtitle: 'Get up to 50% off on selected items',
        image: 'https://via.placeholder.com/1200x400?text=Summer+Sale',
        url: 'https://example.com/summer-sale',
        ctaText: 'Shop Now'
    },
    {
        id: 2,
        title: 'New Arrivals',
        subtitle: 'Check out our latest products',
        image: 'https://via.placeholder.com/1200x400?text=New+Arrivals',
        url: 'https://example.com/new-arrivals',
        ctaText: 'Explore'
    }
];

console.log('[v0] Sample data loaded successfully');
