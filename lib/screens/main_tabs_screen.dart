// lib/screens/main_tabs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Added to safely evaluate web execution compile states
import 'package:url_launcher/url_launcher.dart'; // ✅ Added to handle app store link redirections

import '../widgets/app_scaffold.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/main_drawer.dart';
import '../widgets/hospitality/lodge_card.dart';

import '../models/lodge_model.dart';           
import '../models/event_model.dart'; 
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/property_model.dart';
import '../models/room_model.dart'; 
import '../../models/payment_status_model.dart';

import 'properties/feed_properties_list_screen.dart';
import 'properties/my_unlocked_properties_screen.dart';
import 'properties/property_details_screen.dart';
import 'properties/my_properties_screen.dart';
import 'properties/add_property_screen.dart';
import 'properties/edit_property_screen.dart';
import 'properties/property_unlock_screen.dart'; 

import 'events/feed_event_list_screen.dart';
import 'events/my_tickets_screen.dart';
import 'events/manage_events_screen.dart';
import 'events/create_event_screen.dart';
import 'events/event_detail_screen.dart'; 
import 'events/scan_ticket_screen.dart'; 
import 'events/buy_ticket_screen.dart'; 

import 'hospitality/feed_lodge_list_screen.dart';
import 'hospitality/lodge_owner_dashboard.dart';
import 'hospitality/create_lodge_screen.dart';
import 'hospitality/edit_lodge_screen.dart';
import 'hospitality/lodge_detail_screen.dart'; 
import 'hospitality/my_bookings_screen.dart';
import 'hospitality/my_lodges_screen.dart';
import 'hospitality/add_room_screen.dart';
import 'hospitality/room_detail_screen.dart'; 
import 'hospitality/booking_checkout_screen.dart';
import 'hospitality/availability_calendar_screen.dart'; 

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
import 'about/tour.dart';

import 'help/help_screen.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';
import 'cart/cart_screen.dart';
import 'cart/checkout_screen.dart';

import '../providers/products_provider.dart'; 
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

class MainTabsScreenState extends State<MainTabsScreen> with AppRouterMixin {
  int _currentIndex = 0;
  int? _activeProductId; 
  int? _activeShopId; 
  Lodge? _activeLodge;
  int? _activePropertyId; 
  EventModel? _activeEvent; 

  // Property Unlock state parameters
  int? _unlockPropertyId;
  String? _unlockPropertyTitle;
  double? _unlockPropertyFee;

  // Hospitality Room details parameters
  Room? _activeRoom;
  List<String>? _activeRoomLodgeImages;

  // Hospitality Booking parameters
  Room? _checkoutBookingRoom;

  List<CartItem>? _checkoutItems; 
  double? _checkoutTotal;

  int? _paymentTransactionId;
  double? _paymentAmount;
  String? _paymentPurpose;
  String? _packageReferenceType;
  void Function(PaymentStatusModel)? _paymentOnSuccess;

  int? _calendarRoomId;

  // ✅ New State Tracker: Controls user-dismissibility for the web banner
  bool _showInstallBanner = true;

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

  void navigateToPropertyUnlock({
    required int propertyId,
    required String propertyTitle,
    required double unlockFee,
  }) {
    setState(() {
      _unlockPropertyId = propertyId;
      _unlockPropertyTitle = propertyTitle;
      _unlockPropertyFee = unlockFee;
      _currentIndex = 46;
    });
  }

  void navigateToRoomDetails(Room room, List<String> lodgeImages) {
    setState(() {
      _activeRoom = room;
      _activeRoomLodgeImages = lodgeImages;
      _currentIndex = 47;
    });
  }

  void navigateToBookingCheckout(Room room) {
    setState(() {
      _checkoutBookingRoom = room;
      _currentIndex = 48;
    });
  }

  void navigateToBuyTicket(EventModel event) {
    setState(() {
      _activeEvent = event;
      _currentIndex = 45;
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
      _packageReferenceType = referenceType;
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

  void navigateToMangoHubTour() {
    setState(() {
      _currentIndex = 43;
    });
  }

  void navigateToCreateEvent() { setState(() { _currentIndex = 40; }); }

  void navigateToAvailabilityCalendar(int roomId) {
    setState(() {
      _calendarRoomId = roomId;
      _currentIndex = 49;
    });
  }

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
      case 43: return "MalaTrade Guide";
      case 44: return "Scan Ticket Panel";
      case 45: return "Select Tickets";
      case 46: return "Unlock Property"; 
      case 47: return _activeRoom != null ? "${_activeRoom!.roomNumber}" : "Room Details";
      case 48: return "Booking Checkout";
      case 49: return "Room Availability Calendar";
      default: return "MalaTrade";
    }
  }

  // ✅ SMART BANNER BUILDER: Targets mobile web browsers uniquely without intruding on desktops or native apps
  Widget _buildWebInstallBanner(BuildContext context) {
    if (!kIsWeb || !_showInstallBanner) return const SizedBox.shrink();

    final bool isMobileWeb = Theme.of(context).platform == TargetPlatform.android ||
                        Theme.of(context).platform == TargetPlatform.iOS;

    if (!isMobileWeb) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close/Dismiss Button icon
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _showInstallBanner = false),
          ),
          const SizedBox(width: 12),
          // App Representation Icon Thumbnail Layout
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          // Banner Description Text Informational Frame
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Use MalaTrade App",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Get faster page load metrics & seamless trading workflows.",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Trigger Button Action
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              final String storeUrl = Theme.of(context).platform == TargetPlatform.iOS
                  ? "${Uri.base.origin}/app/download/" 
                  : "https://mangobackend-yayy.onrender.com/app/download/";
              
              final uri = Uri.parse(storeUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text("Install", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int displayIndex = _currentIndex;
    if (_currentIndex == 12) displayIndex = 2;
    if (_currentIndex == 13) displayIndex = 1;
    if (_currentIndex == 14) displayIndex = 5;
    if (_currentIndex == 15) displayIndex = 3;
    if (_currentIndex == 16) displayIndex = 4;
    
    if (_currentIndex >= 17 && _currentIndex <= 40) displayIndex = 6;
    if (_currentIndex == 41) displayIndex = 8;
    if (_currentIndex == 42) displayIndex = 8;
    if (_currentIndex == 43) displayIndex = 0;
    if (_currentIndex == 44) displayIndex = 4; 
    if (_currentIndex == 45) displayIndex = 4; 
    if (_currentIndex == 46) displayIndex = 3; 

    if (_currentIndex == 47) displayIndex = 5; 
    if (_currentIndex == 48) displayIndex = 5; 
    if (_currentIndex == 49) displayIndex = 5; 

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

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.15), 
          child: Column(
            children: [
              // ✅ INJECTED SMART APP INSTALLATION BANNER: Safely evaluates on top of inner viewport screens
              _buildWebInstallBanner(context),
              
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    ...List.generate(_screens.length, (index) {
                      return LazyLoadTab(
                        isSelected: _currentIndex == index,
                        child: _screens[index],
                      );
                    }),

                    _activeProductId != null ? ProductDetailsScreen(key: ValueKey('p_$_activeProductId'), productId: _activeProductId!) : const Center(child: Text("No product selected")),
                    _activeShopId != null ? ShopDetailsScreen(key: ValueKey('s_$_activeShopId'), shopId: _activeShopId!) : const Center(child: Text("No shop selected")),
                    _activeLodge != null ? LodgeDetailScreen(key: ValueKey('l_${_activeLodge!.id}'), lodge: _activeLodge!) : const Center(child: Text("No lodge selected")),
                    _activePropertyId != null ? PropertyDetailsScreen(key: ValueKey('prop_$_activePropertyId'), propertyId: _activePropertyId!) : const Center(child: Text("No property selected")),
                    _activeEvent != null ? EventDetailScreen(key: ValueKey('event__${_activeEvent!.id}'), event: _activeEvent!) : const Center(child: Text("No event selected")),

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
                    _activeEditShop != null ? EditShopScreen(key: ValueKey('edit_shop_${_activeEditShop!.id}'), shop: _activeEditShop!) : const Center(child: Text("No shop selected")),
                    const CreateShopScreen(),
                    _activeEditProduct != null ? EditProductScreen(key: ValueKey('edit_product_${_activeEditProduct!.id}'), product: _activeEditProduct!) : const Center(child: Text("No product selected")),
                    const AddPropertyScreen(),
                    PropertyFormScreen(key: ValueKey('prop_form_${_activeFormProperty?.id ?? 0}'), property: _activeFormProperty),
                    const CreateLodgeScreen(),
                    _activeEditLodge != null ? EditLodgeScreen(key: ValueKey('edit_lodge_${_activeEditLodge!.id}'), lodge: _activeEditLodge!) : const Center(child: Text("No lodge selected")),
                    const MyLodgesScreen(),
                    _activeLodgeRoomId != null ? AddRoomScreen(key: ValueKey('add_room_to_$_activeLodgeRoomId'), lodgeId: _activeLodgeRoomId!) : const Center(child: Text("No lodge selected for rooms modification")),
                    const AddEventScreen(),

                    _checkoutItems != null && _checkoutTotal != null ? CheckoutScreen(key: ValueKey('checkout_t_${_checkoutTotal.hashCode}'), items: _checkoutItems!, total: _checkoutTotal!) : const Center(child: Text("Checkout session inactive")),
                    _paymentTransactionId != null && _paymentAmount != null && _paymentPurpose != null && _packageReferenceType != null && _paymentOnSuccess != null ? PaymentCheckoutScreen(key: ValueKey('payment_view_tx_$_paymentTransactionId'), transactionId: _paymentTransactionId!, amount: _paymentAmount!, purpose: _paymentPurpose!, referenceType: _packageReferenceType!, onSuccess: _paymentOnSuccess!) : const Center(child: Text("Payment session inactive")),
                    
                    const MangoHubScreen(),
                    const ScanTicketScreen(), 
                    
                    _activeEvent != null 
                        ? BuyTicketScreen(key: ValueKey('buy_t_${_activeEvent!.id}'), event: _activeEvent!)
                        : const Center(child: Text("No active purchase pipeline session initialization coordinates found")),

                    _unlockPropertyId != null && _unlockPropertyTitle != null && _unlockPropertyFee != null
                        ? PropertyUnlockScreen(
                            key: ValueKey('unlock_prop_$_unlockPropertyId'),
                            propertyId: _unlockPropertyId!,
                            propertyTitle: _unlockPropertyTitle!,
                            unlockFee: _unlockPropertyFee!,
                          )
                        : const Center(child: Text("No active property unlock request initialized")),

                    _activeRoom != null && _activeRoomLodgeImages != null 
                        ? RoomDetailScreen(
                            key: ValueKey('room_dt_${_activeRoom!.id}'), 
                            room: _activeRoom!, 
                            lodgeImages: _activeRoomLodgeImages!,
                          )
                        : const Center(child: Text("No active room detail view initialized")),

                    _checkoutBookingRoom != null 
                        ? BookingCheckoutScreen(
                            key: ValueKey('book_room_${_checkoutBookingRoom!.id}'),
                            room: _checkoutBookingRoom!,
                          )
                        : const Center(child: Text("No active booking checkout pipeline initialized")),
                    _calendarRoomId != null
                        ? AvailabilityCalendarScreen(
                            key: ValueKey('room_cal_$_calendarRoomId'),
                            roomId: _calendarRoomId!,
                          )
                        : const Center(child: Text("No active calendar preview session initialized")),
                  ],
                ),
              ),
            ],
          ),
        ),
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