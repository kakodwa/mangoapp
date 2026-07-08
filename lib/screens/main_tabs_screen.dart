// lib/screens/main_tabs_screen.dart
import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/main_drawer.dart';
import '../widgets/hospitality/lodge_card.dart';

import '../models/lodge_model.dart';           
import '../models/event_model.dart'; 
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/property_model.dart';
import '../../models/payment_status_model.dart';

import 'properties/feed_properties_list_screen.dart';
import 'properties/my_unlocked_properties_screen.dart';
import 'properties/property_details_screen.dart';
import 'properties/my_properties_screen.dart';
import 'properties/add_property_screen.dart';
import 'properties/edit_property_screen.dart';

import 'events/feed_event_list_screen.dart';
import 'events/my_tickets_screen.dart';
import 'events/manage_events_screen.dart';
import 'events/create_event_screen.dart';
import 'events/event_detail_screen.dart'; 

import 'hospitality/feed_lodge_list_screen.dart';
import 'hospitality/lodge_owner_dashboard.dart';
import 'hospitality/create_lodge_screen.dart';
import 'hospitality/edit_lodge_screen.dart';
import 'hospitality/lodge_detail_screen.dart'; 
import 'hospitality/my_bookings_screen.dart';
import 'hospitality/my_lodges_screen.dart';
import 'hospitality/add_room_screen.dart';

import 'delivery/delivery_code_entry_screen.dart';
import 'delivery/seller_delivery_screen.dart';

import 'products/product_details_screen.dart'; 
import 'products/feed_products_list_screen.dart';
import 'products/add_product_screen.dart';
import 'products/edit_product_screen.dart';

import 'shops/feed_shops_list_screen.dart';
import 'shops/shop_details_screen.dart'; 
import 'shops/my_shop_screen.dart'; 
import 'shops/edit_shop_screen.dart';
import 'shops/create_shop_screen.dart';

import 'wallet/wallet_transactions_screen.dart';
import 'wallet/withdrawal_screen.dart';
import 'wallet/payout_history_screen.dart';

import 'payments/payment_history_screen.dart';
import 'payments/payment_checkout_screen.dart'; 
import 'profile/profile_screen.dart';
import 'search/unified_search_screen.dart';
import 'about/about_screen.dart';
import 'help/help_screen.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';
import 'cart/cart_screen.dart';
import 'cart/checkout_screen.dart';

// --- PROVIDER IMPORTS ---
import '../providers/products_provider.dart'; 
// 🌟 Import your router mixin explicitly to read data elements globally
import '../router/app_router.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  static MainTabsScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainTabsScreenState>();
  }

  static MainTabsScreenState? getInstance() {
    return MainTabsScreenState.instance;
  }

  @override
  State<MainTabsScreen> createState() => MainTabsScreenState();
}

// 🌟 FIX: Made class public (removed underscore) so MainTabsScreenState.instance is accessible globally
class MainTabsScreenState extends State<MainTabsScreen> with AppRouterMixin {
  int _currentIndex = 0;
  int? _activeProductId; 
  int? _activeShopId; 
  Lodge? _activeLodge;
  int? _activePropertyId; 
  EventModel? _activeEvent; 

  List<CartItem>? _checkoutItems; 
  double? _checkoutTotal;

  int? _paymentTransactionId;
  double? _paymentAmount;
  String? _paymentPurpose;
  String? _paymentReferenceType;
  void Function(PaymentStatusModel)? _paymentOnSuccess;

  late final List<Widget> _screens;
  static MainTabsScreenState? instance;

  @override
  void initState() {
    super.initState();

    debugPrint("1. initState");

    instance = this;

    debugPrint("2. Before addPostFrameCallback");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("3. Inside addPostFrameCallback");
      initializeRouting();
    });

    debugPrint("4. After addPostFrameCallback");

    _screens = [
      HomeScreen(onDeliveryTap: () => _changeTab(9)),
      const ShopsListScreen(),        
      const ProductsListScreen(),     
      const PropertiesListScreen(),   
      const EventListScreen(),        
      const LodgeListScreen(),        
      const ProfileScreen(),          
      const UnifiedSearchScreen(),    
      const CartScreen(),             
      const DeliveryCodeScreen(),     
      const AboutScreen(),            
      const HelpSupportScreen(),      
    ];
  }

  @override
  void dispose() {
    disposeRouting();
    super.dispose();
  }

  void navigateToProductDetails(int productId) {
    setState(() {
      _activeProductId = productId;
      _currentIndex = 12;
    });
  }

  void navigateToShopDetails(int shopId) {
    setState(() {
      _activeShopId = shopId;
      _currentIndex = 13;
    });
  }

  void navigateToLodgeDetails(Lodge lodge) {
    setState(() {
      _activeLodge = lodge;
      _currentIndex = 14;
    });
  }

  void navigateToPropertyDetails(int propertyId) {
    setState(() {
      _activePropertyId = propertyId;
      _currentIndex = 15;
    });
  }

  void navigateToEventDetails(EventModel event) {
    setState(() {
      _activeEvent = event;
      _currentIndex = 16;
    });
  }

  void navigateToCheckout(List<CartItem> items, double total) { 
    setState(() {
      _checkoutItems = items;
      _checkoutTotal = total;
      _currentIndex = 41;
    });
  }

  void navigateToPayment({
    required int transactionId,
    required double amount,
    required String purpose,
    required String referenceType,
    required Function(PaymentStatusModel) onSuccess,
  }) {
    setState(() {
      _paymentTransactionId = transactionId;
      _paymentAmount = amount;
      _paymentPurpose = purpose;
      _paymentReferenceType = referenceType;
      _paymentOnSuccess = onSuccess;
      _currentIndex = 42; 
    });
  }

  void setSelectedIndex(int index) {
    _changeTab(index);
  }

  void _changeTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void navigateToAddProduct() { setState(() { _currentIndex = 17; }); }
  void navigateToMyShop() { setState(() { _currentIndex = 18; }); }
  void navigateToSellerDeliveries() { setState(() { _currentIndex = 19; }); }
  void navigateToWalletTransactions() { setState(() { _currentIndex = 20; }); }
  void navigateToPaymentHistory() { setState(() { _currentIndex = 21; }); }
  void navigateToWithdrawal() { setState(() { _currentIndex = 22; }); }
  void navigateToPayoutHistory() { setState(() { _currentIndex = 23; }); }
  void navigateToOrders() { setState(() { _currentIndex = 24; }); }
  void navigateToMyBookings() { setState(() { _currentIndex = 25; }); }
  void navigateToMyTickets() { setState(() { _currentIndex = 26; }); }
  void navigateToMyUnlockedProperties() { setState(() { _currentIndex = 27; }); }
  void navigateToMyProperties() { setState(() { _currentIndex = 28; }); }
  void navigateToManageEvents() { setState(() { _currentIndex = 29; }); }
  void navigateToLodgeDashboard() { setState(() { _currentIndex = 30; }); }

  Shop? _activeEditShop;
  void navigateToEditShop(Shop shop) {
    setState(() {
      _activeEditShop = shop;
      _currentIndex = 31;
    });
  }

  void navigateToCreateShop() { setState(() { _currentIndex = 32; }); }

  Product? _activeEditProduct;
  void navigateToEditProduct(Product product) {
    setState(() {
      _activeEditProduct = product;
      _currentIndex = 33;
    });
  }

  void navigateToVerifyAddProperty() { setState(() { _currentIndex = 34; }); }
  
  Property? _activeFormProperty;
  void navigateToPropertyForm(Property? property) {
    setState(() {
      _activeFormProperty = property;
      _currentIndex = 35;
    });
  }
  
  void navigateToCreateLodge() { setState(() { _currentIndex = 36; }); }
  
  Lodge? _activeEditLodge;
  void navigateToEditLodge(Lodge lodge) {
    setState(() {
      _activeEditLodge = lodge;
      _currentIndex = 37;
    });
  }
  
  void navigateToMyLodges() { setState(() { _currentIndex = 38; }); }
  
  int? _activeLodgeRoomId;
  void navigateToAddRoom(int lodgeId) {
    setState(() {
      _activeLodgeRoomId = lodgeId;
      _currentIndex = 39;
    });
  }
  void navigateToCreateEvent() { setState(() { _currentIndex = 40; }); }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 9: return "Delivery Rider";
      case 10: return "About App";
      case 11: return "Help";
      case 12: return "Product Details";
      case 13: return "Shop Details";
      case 14: return "Lodge Details";
      case 15: return "Property Details";
      case 16: return "Event Details";
      case 17: return "Add Product";
      case 18: return "My Shop";
      case 19: return "Seller Deliveries";
      case 20: return "Wallet Activity";
      case 21: return "Payment History";
      case 22: return "Cashout Wallet";
      case 23: return "Cashout History";
      case 24: return "My Orders";
      case 25: return "My Bookings";
      case 26: return "My Tickets";
      case 27: return "Unlocked Properties";
      case 28: return "My Properties";
      case 29: return "Manage Events";
      case 30: return "Lodge Dashboard";
      case 31: return "Edit Shop";
      case 32: return "Create Shop";
      case 33: return "Edit Product";
      case 34: return "Post Property";
      case 35: return "Edit Property";
      case 36: return "Create Lodge";
      case 37: return "Edit Lodge";
      case 38: return "My Lodges";
      case 39: return "Add Room";
      case 40: return "Create Event";
      case 41: return "Checkout";
      case 42: return "Secure Payment"; 
      default: return "MangoHub";
    }
  }

  @override
  Widget build(BuildContext context) {
    int displayIndex = _currentIndex;
    if (_currentIndex == 12) displayIndex = 2;
    if (_currentIndex == 13) displayIndex = 1;
    if (_currentIndex == 14) displayIndex = 5;
    if (_currentIndex == 15) displayIndex = 3;
    if (_currentIndex == 16) displayIndex = 4;
    if (_currentIndex == 17) displayIndex = 6;
    if (_currentIndex == 18) displayIndex = 6;
    if (_currentIndex == 19) displayIndex = 6;
    if (_currentIndex == 20) displayIndex = 6;
    if (_currentIndex == 21) displayIndex = 6;
    if (_currentIndex == 22) displayIndex = 6;
    if (_currentIndex == 23) displayIndex = 6;
    if (_currentIndex == 24) displayIndex = 6;
    if (_currentIndex == 25) displayIndex = 6;
    if (_currentIndex == 26) displayIndex = 6;
    if (_currentIndex == 27) displayIndex = 6;
    if (_currentIndex == 28) displayIndex = 6;
    if (_currentIndex == 29) displayIndex = 6;
    if (_currentIndex == 30) displayIndex = 6;
    if (_currentIndex == 31) displayIndex = 6;
    if (_currentIndex == 32) displayIndex = 6;
    if (_currentIndex == 41) displayIndex = 8;
    if (_currentIndex == 42) displayIndex = 8;

    if (_currentIndex >= 17 && _currentIndex <= 40) displayIndex = 6;

    return AppScaffold(
      currentIndex: displayIndex,
      onTabSelected: _changeTab,
      appBar: MainAppBar(
        title: _getAppBarTitle(),
        onProfileTap: () => _changeTab(6),
        onSearchTap: () => _changeTab(7),
        onCartTap: () => _changeTab(8),
      ),
      drawer: MainDrawer(
        onAboutTap: () => _changeTab(10),
        onHelpTap: () => _changeTab(11),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ...List.generate(_screens.length, (index) {
            return LazyLoadTab(
              isSelected: _currentIndex == index,
              child: _screens[index],
            );
          }),

          _activeProductId != null 
              ? ProductDetailsScreen(key: ValueKey('p_$_activeProductId'), productId: _activeProductId!)
              : const Center(child: Text("No product selected")),

          _activeShopId != null 
              ? ShopDetailsScreen(key: ValueKey('s_$_activeShopId'), shopId: _activeShopId!)
              : const Center(child: Text("No shop selected")),

          _activeLodge != null 
              ? LodgeDetailScreen(key: ValueKey('l_${_activeLodge!.id}'), lodge: _activeLodge!)
              : const Center(child: Text("No lodge selected")),

          _activePropertyId != null 
              ? PropertyDetailsScreen(key: ValueKey('prop_$_activePropertyId'), propertyId: _activePropertyId!)
              : const Center(child: Text("No property selected")),

          _activeEvent != null
              ? EventDetailScreen(key: ValueKey('event__${_activeEvent!.id}'), event: _activeEvent!)
              : const Center(child: Text("No event selected")),

          const AddProductScreen(),
          const MyShopScreen(),
          const SellerDeliveryScreen(),
          const WalletTransactionsScreen(),
          const PaymentHistoryScreen(),
          const WithdrawalScreen(),
          const PayoutHistoryScreen(),
          const OrdersScreen(),
          const MyBookingsScreen(),
          const MyTicketsScreen(),
          const MyUnlockedPropertiesScreen(),
          const MyPropertiesScreen(),
          const ManageEventsScreen(),
          const LodgeOwnerDashboard(),
          _activeEditShop != null 
          ? EditShopScreen(key: ValueKey('edit_shop_${_activeEditShop!.id}'), shop: _activeEditShop!)
          : const Center(child: Text("No shop selected")),
          const CreateShopScreen(),
          _activeEditProduct != null 
          ? EditProductScreen(key: ValueKey('edit_product_${_activeEditProduct!.id}'), product: _activeEditProduct!)
          : const Center(child: Text("No product selected")),
          const AddPropertyScreen(),
          PropertyFormScreen(
            key: ValueKey('prop_form_${_activeFormProperty?.id ?? 0}'), 
            property: _activeFormProperty,),
          const CreateLodgeScreen(),
          _activeEditLodge != null 
          ? EditLodgeScreen(key: ValueKey('edit_lodge_${_activeEditLodge!.id}'), lodge: _activeEditLodge!)
          : const Center(child: Text("No lodge selected")),
          const MyLodgesScreen(),
          _activeLodgeRoomId != null
          ? AddRoomScreen(key: ValueKey('add_room_to_$_activeLodgeRoomId'), lodgeId: _activeLodgeRoomId!)
          : const Center(child: Text("No lodge selected for rooms modification")),
          const AddEventScreen(),

          _checkoutItems != null && _checkoutTotal != null
              ? CheckoutScreen(
                  key: ValueKey('checkout_t_${_checkoutTotal.hashCode}'),
                  items: _checkoutItems!,
                  total: _checkoutTotal!,
                )
              : const Center(child: Text("Checkout session inactive")),

          _paymentTransactionId != null && _paymentAmount != null && _paymentPurpose != null && _paymentReferenceType != null && _paymentOnSuccess != null
              ? PaymentCheckoutScreen(
                  key: ValueKey('payment_view_tx_$_paymentTransactionId'),
                  transactionId: _paymentTransactionId!,
                  amount: _paymentAmount!,
                  purpose: _paymentPurpose!,
                  referenceType: _paymentReferenceType!,
                  onSuccess: _paymentOnSuccess!,
                )
              : const Center(child: Text("Payment session inactive")),
        ],
      ),
    );
  }
}

class LazyLoadTab extends StatefulWidget {
  final bool isSelected;
  final Widget child;

  const LazyLoadTab({
    super.key,
    required this.isSelected,
    required this.child,
  });

  @override
  State<LazyLoadTab> createState() => _LazyLoadTabState();
}

class _LazyLoadTabState extends State<LazyLoadTab> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isSelected && !_initialized) {
      _initialized = true;
    }
    return _initialized ? widget.child : const SizedBox.shrink();
  }
}