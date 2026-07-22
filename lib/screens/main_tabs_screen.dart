// lib/screens/main_tabs_screen.dart
import 'dart:async'; // 💼 Crucial import for handling automatic banner rotations
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; //
import 'package:url_launcher/url_launcher.dart'; //

import '../widgets/app_scaffold.dart'; //
import '../widgets/main_app_bar.dart'; //
import '../widgets/main_drawer.dart'; //
import '../widgets/hospitality/lodge_card.dart'; //
import '../widgets/shop_map_modal.dart'; //
import '../widgets/update.dart'; //

import '../models/lodge_model.dart';           //
import '../models/event_model.dart'; //
import '../models/shop_model.dart'; //
import '../models/product_model.dart'; //
import '../models/property_model.dart'; //
import '../models/room_model.dart'; //
import '../../models/payment_status_model.dart'; //

import 'properties/feed_properties_list_screen.dart'; //
import 'properties/my_unlocked_properties_screen.dart'; //
import 'properties/property_details_screen.dart'; //
import 'properties/my_properties_screen.dart'; //
import 'properties/add_property_screen.dart'; //
import 'properties/edit_property_screen.dart'; //
import 'properties/property_unlock_screen.dart'; //

import 'events/feed_event_list_screen.dart'; //
import 'events/my_tickets_screen.dart'; //
import 'events/manage_events_screen.dart'; //
import 'events/create_event_screen.dart'; //
import 'events/event_detail_screen.dart'; //
import 'events/scan_ticket_screen.dart'; //
import 'events/buy_ticket_screen.dart'; //
import 'events/ticket_detail_screen.dart'; //
import 'events/event_tickets_screen.dart'; //

import 'hospitality/feed_lodge_list_screen.dart'; //
import 'hospitality/lodge_owner_dashboard.dart'; //
import 'hospitality/create_lodge_screen.dart'; //
import 'hospitality/edit_lodge_screen.dart'; //
import 'hospitality/lodge_detail_screen.dart'; //
import 'hospitality/my_bookings_screen.dart'; //
import 'hospitality/my_lodges_screen.dart'; //
import 'hospitality/add_room_screen.dart'; //
import 'hospitality/room_detail_screen.dart'; //
import 'hospitality/booking_checkout_screen.dart'; //
import 'hospitality/availability_calendar_screen.dart'; //
import 'hospitality/owner_bookings_screen.dart'; //
import 'hospitality/bookings_scanner_screen.dart'; //

import 'delivery/delivery_code_entry_screen.dart'; //
import 'delivery/seller_delivery_screen.dart'; //

import 'products/product_details_screen.dart'; //
import 'products/feed_products_list_screen.dart'; //
import 'products/add_product_screen.dart'; //
import 'products/edit_product_screen.dart'; //

import 'shops/feed_shops_list_screen.dart'; //
import 'shops/shop_details_screen.dart'; //
import 'shops/my_shop_screen.dart'; //
import 'shops/edit_shop_screen.dart'; //
import 'shops/create_shop_screen.dart'; //
 

import 'wallet/wallet_transactions_screen.dart'; //
import 'wallet/withdrawal_screen.dart'; //
import 'wallet/payout_history_screen.dart'; //

import 'payments/payment_history_screen.dart'; //
import 'payments/payment_checkout_screen.dart'; //
import 'profile/profile_screen.dart'; //
import 'search/unified_search_screen.dart'; //

import 'about/about_screen.dart'; //
import 'about/tour.dart'; //

import 'help/help_screen.dart'; //
import 'home/home_screen.dart'; //
import 'orders/orders_screen.dart'; //

import 'cart/cart_screen.dart'; //
import 'cart/checkout_screen.dart'; //

import '../providers/products_provider.dart'; //
import '../router/app_router.dart'; //
import '../core/api/api_client.dart'; //

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
  int _currentIndex = 0; //
  String? _searchQuery;//
  int? _activeProductId; //
  int? _activeShopId; //
  Lodge? _activeLodge; //
  int? _activePropertyId; //
  EventModel? _activeEvent; //
  dynamic _activeTicket; //

  int? _unlockPropertyId; //
  String? _unlockPropertyTitle; //
  double? _unlockPropertyFee; //

  Room? _activeRoom; //
  List<String>? _activeRoomLodgeImages; //

  Room? _checkoutBookingRoom; //

  List<CartItem>? _checkoutItems; //
  double? _checkoutTotal; //

  int? _paymentTransactionId; //
  double? _paymentAmount; //
  String? _paymentPurpose; //
  String? _packageReferenceType; //
  void Function(PaymentStatusModel)? _paymentOnSuccess; //

  int? _calendarRoomId; //

  double? _shopMapLat; // 👈 Coordinates for shop map route
  double? _shopMapLng; // 👈 Coordinates for shop map route

  static bool _hasBeenDismissedGlobal = false; //
  bool _showAdBanner = true; //

  // Dynamic Advert Placement Engine States
  List<Map<String, dynamic>> _allBackendAds = []; //
  Map<String, dynamic>? _activeBackendAd; //
  bool _isLoadingAd = true; //
  
  // Carousel Controller & Active Rotation Timer
  PageController? _bannerPageController; //
  Timer? _bannerTimer; //

  late final List<Widget> _screens; //
  static MainTabsScreenState? instance; //

  // 👈 History stack tracker to enable true procedural pop/back logic inside IndexedStack
  final List<int> _navigationHistory = [];

  @override
  void initState() {
    super.initState();
    instance = this; //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeRouting(); //
      _fetchBackendAdvert(); //
    });

    if (_hasBeenDismissedGlobal) {
      _showAdBanner = false; //
    }

    _screens = [
      HomeScreen(onDeliveryTap: () => _changeTab(9)), //
      const ShopsListScreen(),        //
      const ProductsListScreen(),     //
      const PropertiesListScreen(),   //
      const EventListScreen(),        //
      const LodgeListScreen(),        //
      const ProfileScreen(),          //
      UnifiedSearchScreen(
        key: ValueKey(_searchQuery),
        initialQuery: _searchQuery,
      ), // 7
      const CartScreen(),             //
      const DeliveryCodeScreen(),     //
      const AboutScreen(),            //
      const HelpSupportScreen(),      //
    ];
  }

 Future<void> _fetchBackendAdvert() async {
    try {
      final client = ApiClient(); //
      final response = await client.fetchBanners(); //
      if (response.isNotEmpty) { //
        // Filter out empty or illegal subtitles immediately at fetch boundary level
        final parsedBanners = List<Map<String, dynamic>>.from(response).where((ad) { //
          final String sub = (ad['subtitle'] ?? '').toString().trim(); //
          return sub == 'text banner' || sub == 'install app'; //
        }).toList(); //

        if (parsedBanners.isNotEmpty) { //
          setState(() {
            _allBackendAds = parsedBanners; //
            _activeBackendAd = parsedBanners.first; //
            _isLoadingAd = false; //
          });

          // Initialize auto-rotation slider timeline loop rules
          if (_allBackendAds.length > 1) { //
            _bannerPageController = PageController(); //
            _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) { //
              if (_bannerPageController != null && _bannerPageController!.hasClients) { //
                // Re-calculate the filtered list right here so the timer knows the real target length
                final validAdsCount = _allBackendAds.where((ad) { //
                  final sub = (ad['subtitle'] ?? '').toString().trim(); //
                  return sub == 'text banner' || (sub == 'install app' && kIsWeb); //
                }).length;

                if (validAdsCount <= 1) return; // No need to cycle if there's only 1 valid ad on this platform

                int currentPage = _bannerPageController!.page?.round() ?? 0; //
                int nextPage = currentPage + 1; //
                
                if (nextPage >= validAdsCount) { //
                  nextPage = 0; //
                }
                
                _bannerPageController!.animateToPage( //
                  nextPage,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                );
              }
            });
          }
        } else {
          setState(() => _isLoadingAd = false); //
        }
      } else {
        setState(() => _isLoadingAd = false); //
      }
    } catch (e) {
      setState(() => _isLoadingAd = false); //
    }
  }

  @override
  void dispose() {
    _bannerPageController?.dispose(); //
    _bannerTimer?.cancel(); //
    disposeRouting(); //
    super.dispose();
  }

  // Method to evaluate if we are currently displaying a detail or third-level viewport
  bool _isDetailScreen() {
    final detailIndices = {
      12, 13, 14, 15, 16, // Primary Details
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, // Secondary Dashboard menus
      31, 32, 33, 34, 35, 36, 37, 38, 39, 40, // Forms & Creation pages
      41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54 // Checkouts & Shop Map Modal
    };
    return detailIndices.contains(_currentIndex);
  }

  // Pops the top layout index from history
  void _navigateBack() {
    if (_navigationHistory.isNotEmpty) {
      setState(() {
        _currentIndex = _navigationHistory.removeLast();
      });
    } else {
      setState(() {
        switch (_currentIndex) {
          case 12: _currentIndex = 2; break; // Product details -> Product list
          case 13: _currentIndex = 1; break; // Shop details -> Shop list
          case 14: _currentIndex = 5; break; // Lodge details -> Lodge list
          case 15: _currentIndex = 3; break; // Property details -> Property list
          case 16: _currentIndex = 4; break; // Event details -> Event list
          case 47: _currentIndex = 14; break; // Room details -> Lodge details
          case 48: _currentIndex = 47; break; // Booking Checkout -> Room details
          case 54: _currentIndex = 13; break; // Shop Map -> Shop details
          default: _currentIndex = 0; // Fallback: Dashboard
        }
      });
    }
  }

  void navigateToProductDetails(int productId) {
    setState(() {
      _activeProductId = productId; //
      _changeTab(12); //
    });
  }

  void navigateToShopDetails(int shopId) {
    setState(() {
      _activeShopId = shopId; //
      _changeTab(13); //
    });
  }

  void navigateToShopMap(double lat, double lng) {
    setState(() {
      _shopMapLat = lat;
      _shopMapLng = lng;
      _changeTab(54);
    });
  }

  void navigateToLodgeDetails(Lodge lodge) {
    setState(() {
      _activeLodge = lodge; //
      _changeTab(14); //
    });
  }

  void navigateToPropertyDetails(int propertyId) {
    setState(() {
      _activePropertyId = propertyId; //
      _changeTab(15); //
    });
  }

  void navigateToEventDetails(EventModel event) {
    setState(() {
      _activeEvent = event; //
      _changeTab(16); //
    });
  }

  void navigateToTicketDetails(dynamic ticket) {
    setState(() {
      _activeTicket = ticket; //
      _changeTab(50); //
    });
  }

  void navigateToPropertyUnlock({
    required int propertyId,
    required String propertyTitle,
    required double unlockFee,
  }) {
    setState(() {
      _unlockPropertyId = propertyId; //
      _unlockPropertyTitle = propertyTitle; //
      _unlockPropertyFee = unlockFee; //
      _changeTab(46); //
    });
  }

  void navigateToRoomDetails(Room room, List<String> lodgeImages) {
    setState(() {
      _activeRoom = room; //
      _activeRoomLodgeImages = lodgeImages; //
      _changeTab(47); //
    });
  }

  void navigateToBookingCheckout(Room room) {
    setState(() {
      _checkoutBookingRoom = room; //
      _changeTab(48); //
    });
  }

  void navigateToBuyTicket(EventModel event) {
    setState(() {
      _activeEvent = event; //
      _changeTab(45); //
    });
  }

  void navigateToCheckout(List<CartItem> items, double total) { 
    setState(() {
      _checkoutItems = items; //
      _checkoutTotal = total; //
      _changeTab(41); //
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
      _paymentTransactionId = transactionId; //
      _paymentAmount = amount; //
      _paymentPurpose = purpose; //
      _packageReferenceType = referenceType; //
      _paymentOnSuccess = onSuccess; //
      _changeTab(42); //
    });
  }

  void setSelectedIndex(int index, {String? searchQuery}) {
    _changeTab(index, searchQuery: searchQuery);
  }

  void _changeTab(int index, {String? searchQuery}) {
    if (_currentIndex == index && searchQuery == null) return;
    setState(() {
      _navigationHistory.add(_currentIndex);
      _currentIndex = index;
      if (searchQuery != null) {
        _searchQuery = searchQuery;
      }
    });
  }

  void navigateToAddProduct() { _changeTab(17); }
  void navigateToMyShop() { _changeTab(18); }
  void navigateToSellerDeliveries() { _changeTab(19); }
  void navigateToWalletTransactions() { _changeTab(20); }
  void navigateToPaymentHistory() { _changeTab(21); }
  void navigateToWithdrawal() { _changeTab(22); }
  void navigateToPayoutHistory() { _changeTab(23); }
  void navigateToOrders() { _changeTab(24); }
  void navigateToMyBookings() { _changeTab(25); }
  void navigateToMyTickets() { _changeTab(26); }
  void navigateToMyUnlockedProperties() { _changeTab(27); }
  void navigateToMyProperties() { _changeTab(28); }
  void navigateToManageEvents() { _changeTab(29); }
  void navigateToLodgeDashboard() { _changeTab(30); }

  Shop? _activeEditShop;
  void navigateToEditShop(Shop shop) {
    setState(() {
      _activeEditShop = shop; //
      _changeTab(31);
    });
  }

  void navigateToCreateShop() { _changeTab(32); }

  Product? _activeEditProduct;
  void navigateToEditProduct(Product product) {
    setState(() {
      _activeEditProduct = product; //
      _changeTab(33);
    });
  }

  void navigateToVerifyAddProperty() { _changeTab(34); }
  
  Property? _activeFormProperty;
  void navigateToPropertyForm(Property? property) {
    setState(() {
      _activeFormProperty = property; //
      _changeTab(35);
    });
  }
  
  void navigateToCreateLodge() { _changeTab(36); }
  
  Lodge? _activeEditLodge;
  void navigateToEditLodge(Lodge lodge) {
    setState(() {
      _activeEditLodge = lodge; //
      _changeTab(37);
    });
  }
  
  void navigateToMyLodges() { _changeTab(38); }
  
  int? _activeLodgeRoomId;
  void navigateToAddRoom(int lodgeId) {
    setState(() {
      _activeLodgeRoomId = lodgeId; //
      _changeTab(39);
    });
  }

  void navigateToMangoHubTour() { _changeTab(43); }
  void navigateToCreateEvent() { _changeTab(40); }

  void navigateToAvailabilityCalendar(int roomId) {
    setState(() {
      _calendarRoomId = roomId; //
      _changeTab(49);
    });
  }

  void navigateToOwnerBookings() { _changeTab(51); }
  void navigateToBookingScanner() { _changeTab(52); }

  void navigateToEventTickets(EventModel event) {
    setState(() {
      _activeEvent = event; //
      _changeTab(53);
    });
  }

  String _getAppBarTitle() {
    switch (_currentIndex) { //
      case 9: return "Delivery Rider"; //
      case 10: return "About App"; //
      case 11: return "Help"; //
      case 12: return "Product Details"; //
      case 13: return "Shop Details"; //
      case 14: return "Lodge Details"; //
      case 15: return "Property Details"; //
      case 16: return "Event Details"; //
      case 17: return "Add Product"; //
      case 18: return "My Shop"; //
      case 19: return "Seller Deliveries"; //
      case 20: return "Wallet Activity"; //
      case 21: return "Payment History"; //
      case 22: return "Cashout Wallet"; //
      case 23: return "Cashout History"; //
      case 24: return "My Orders"; //
      case 25: return "My Bookings"; //
      case 26: return "My Tickets"; //
      case 27: return "Unlocked Properties"; //
      case 28: return "My Properties"; //
      case 29: return "Manage Events"; //
      case 30: return "Lodge Dashboard"; //
      case 31: return "Edit Shop"; //
      case 32: return "Create Shop"; //
      case 33: return "Edit Product"; //
      case 34: return "Post Property"; //
      case 35: return "Edit Property"; //
      case 36: return "Create Lodge"; //
      case 37: return "Edit Lodge"; //
      case 38: return "My Lodges"; //
      case 39: return "Add Room"; //
      case 40: return "Create Event"; //
      case 41: return "Checkout"; //
      case 42: return "Secure Payment";  //
      case 43: return "MalaTrade Guide"; //
      case 44: return "Scan Ticket Panel"; //
      case 45: return "Select Tickets"; //
      case 46: return "Unlock Property";  //
      case 47: return _activeRoom != null ? "${_activeRoom!.roomNumber}" : "Room Details"; //
      case 48: return "Booking Checkout"; //
      case 49: return "Room Availability Calendar"; //
      case 50: return "Ticket Details"; //
      case 51: return "Owner Bookings"; //
      case 52: return "Scan Booking QR"; //
      case 53: return "Sold Tickets"; //
      case 54: return "Shop Navigation"; // 👈 AppBar Title for ShopMapModal
      default: return "MalaTrade"; //
    }
  }

  Widget _buildUnifiedBackendBanner(BuildContext context) {
    if (!_showAdBanner || _isLoadingAd || _hasBeenDismissedGlobal || _allBackendAds.isEmpty || _activeBackendAd == null) { //
      return const SizedBox.shrink(); //
    }

    final String subtitle = (_activeBackendAd!['subtitle'] ?? '').toString().trim();  //
    final String imageUrl = _activeBackendAd!['image_url'] ?? _activeBackendAd!['image'] ?? '';  //
    final String targetUrl = _activeBackendAd!['target_url'] ?? _activeBackendAd!['url'] ?? '';  //
    final String title = _activeBackendAd!['title'] ?? 'Download the MalaTrade App';  //

    if (subtitle != 'install app' && subtitle != 'text banner') { //
      return const SizedBox.shrink(); //
    }

    if (subtitle == 'install app') { //
      if (!kIsWeb) return const SizedBox.shrink();  //

      return Container(
        width: double.infinity, //
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, //
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)), //
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)) //
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), //
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000), //
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey), //
                  padding: EdgeInsets.zero, //
                  constraints: const BoxConstraints(), //
                  onPressed: () {
                    setState(() {
                      _showAdBanner = false; //
                      _hasBeenDismissedGlobal = true; //
                      _bannerTimer?.cancel(); //
                    });
                  },
                ),
                const SizedBox(width: 12), //
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), //
                  child: SizedBox(
                    width: 40, //
                    height: 40, //
                    child: imageUrl.isNotEmpty //
                        ? Image.network(imageUrl, fit: BoxFit.fill) //
                        : Container(
                            color: Theme.of(context).colorScheme.primary, //
                            child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 22), //
                          ),
                  ),
                ),
                const SizedBox(width: 12), //
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //
                    mainAxisSize: MainAxisSize.min, //
                    children: [
                      Text(
                        title, //
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), //
                      ),
                      Text(
                        "Get faster page load metrics & seamless trading workflows.", //
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600), //
                        maxLines: 1, //
                        overflow: TextOverflow.ellipsis, //
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), //
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary, //
                    foregroundColor: Colors.white, //
                    elevation: 0, //
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), //
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), //
                  ),
                  onPressed: () async {
                    if (targetUrl.isNotEmpty) { //
                      final uri = Uri.parse(targetUrl); //
                      if (await canLaunchUrl(uri)) { //
                        await launchUrl(uri, mode: LaunchMode.externalApplication); //
                      }
                    }
                  },
                  child: const Text("Install", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), //
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (subtitle == 'text banner') { //
      final validAds = _allBackendAds.where((ad) { //
        final sub = (ad['subtitle'] ?? '').toString().trim(); //
        return sub == 'text banner' || (sub == 'install app' && kIsWeb); //
      }).toList(); //

      if (validAds.isEmpty) return const SizedBox.shrink(); //

      return LayoutBuilder(
        builder: (context, constraints) {

          const double bannerAspectRatio = 90 / 728; //
          final double maxWidth = constraints.maxWidth > 728 ? 728 : constraints.maxWidth; //
          final double computedHeight = maxWidth * bannerAspectRatio; //

          return Center(
            child: Container(
               constraints: const BoxConstraints(maxWidth: 728), //
               width: double.infinity, //
               height: computedHeight, //
               margin: const EdgeInsets.symmetric(vertical: 4), //
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,  //
                      child: PageView.builder(
                        controller: _bannerPageController, //
                        itemCount: validAds.length,  //
                        onPageChanged: (index) {
                          setState(() {
                            _activeBackendAd = validAds[index]; //
                          });
                        },
                        itemBuilder: (context, index) {
                          final ad = validAds[index];  //
                          final String currentImgUrl = ad['image_url'] ?? ad['image'] ?? ''; //
                          final String currentTargetUrl = ad['target_url'] ?? ad['url'] ?? ''; //

                          return GestureDetector(
                            onTap: () async {
                              if (currentTargetUrl.isNotEmpty) { //
                                final uri = Uri.parse(currentTargetUrl); //
                                if (await canLaunchUrl(uri)) { //
                                  await launchUrl(uri, mode: LaunchMode.externalApplication); //
                                }
                              }
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click, //
                              child: Image.network(
                                currentImgUrl, //
                                fit: BoxFit.cover, //
                                gaplessPlayback: true,  //
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: Colors.grey.shade200, //
                                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 14)), //
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 4,
                    child: CircleAvatar(
                      radius: 12,  //
                      backgroundColor: Colors.black.withOpacity(0.4), //
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 14, color: Colors.white), //
                        padding: EdgeInsets.zero, //
                        constraints: const BoxConstraints(), //
                        onPressed: () {
                          setState(() {
                            _showAdBanner = false; //
                            _hasBeenDismissedGlobal = true; //
                            _bannerTimer?.cancel(); //
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink(); //
  }

  @override
  Widget build(BuildContext context) {
    int displayIndex = _currentIndex; //
    if (_currentIndex == 12) displayIndex = 2; //
    if (_currentIndex == 13) displayIndex = 1; //
    if (_currentIndex == 14) displayIndex = 5; //
    if (_currentIndex == 15) displayIndex = 3; //
    if (_currentIndex == 16) displayIndex = 4; //
    
    if (_currentIndex >= 17 && _currentIndex <= 40) displayIndex = 6; //
    if (_currentIndex == 41) displayIndex = 8; //
    if (_currentIndex == 42) displayIndex = 8; //
    if (_currentIndex == 43) displayIndex = 0; //
    if (_currentIndex == 44) displayIndex = 4;  //
    if (_currentIndex == 45) displayIndex = 4;  //
    if (_currentIndex == 46) displayIndex = 3;  //

    if (_currentIndex == 47) displayIndex = 5;  //
    if (_currentIndex == 48) displayIndex = 5;  //
    if (_currentIndex == 49) displayIndex = 5;  //
    if (_currentIndex == 50) displayIndex = 4; //
    if (_currentIndex == 51) displayIndex = 6;  //
    if (_currentIndex == 52) displayIndex = 6; //
    if (_currentIndex == 53) displayIndex = 4; //
    if (_currentIndex == 54) displayIndex = 1; // 👈 Highlights Shops tab in Bottom Navigation Bar

    return AppScaffold(
      currentIndex: displayIndex, //
      onTabSelected: _changeTab, //
      appBar: MainAppBar(
        title: _getAppBarTitle(), //
        onProfileTap: () => _changeTab(6), //
        onSearchTap: () => _changeTab(7), //
        onCartTap: () => _changeTab(8), //
        leading: _isDetailScreen() 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back',
                onPressed: _navigateBack,
              )
            : null,
      ),
      drawer: MainDrawer(
        onAboutTap: () => _changeTab(10), //
        onHelpTap: () => _changeTab(11), //
      ),

      body: Container(
        width: double.infinity, //
        height: double.infinity, //
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'), 
            fit: BoxFit.cover, //
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.15),  //
          child: Column(
            children: [
              _buildUnifiedBackendBanner(context),  //
              const UpdatesTicker(), //
              Expanded(
                child: IndexedStack(
                  index: _currentIndex, //
                  children: [
                    ...List.generate(_screens.length, (index) { //
                      return LazyLoadTab(
                        isSelected: _currentIndex == index, //
                        child: _screens[index], //
                      );
                    }),

                    _activeProductId != null ? ProductDetailsScreen(key: ValueKey('p_$_activeProductId'), productId: _activeProductId!) : const Center(child: Text("No product selected")), //
                    _activeShopId != null ? ShopDetailsScreen(key: ValueKey('s_$_activeShopId'), shopId: _activeShopId!) : const Center(child: Text("No shop selected")), //
                    _activeLodge != null ? LodgeDetailScreen(key: ValueKey('l_${_activeLodge!.id}'), lodge: _activeLodge!) : const Center(child: Text("No lodge selected")), //
                    _activePropertyId != null ? PropertyDetailsScreen(key: ValueKey('prop_$_activePropertyId'), propertyId: _activePropertyId!) : const Center(child: Text("No property selected")), //
                    _activeEvent != null ? EventDetailScreen(key: ValueKey('event__${_activeEvent!.id}'), event: _activeEvent!) : const Center(child: Text("No event selected")), //

                    const AddProductScreen(), //
                    const MyShopScreen(), //
                    const SellerDeliveryScreen(), //
                    const WalletTransactionsScreen(), //
                    const PaymentHistoryScreen(), //
                    const WithdrawalScreen(), //
                    const PayoutHistoryScreen(), //
                    const OrdersScreen(), //
                    const MyBookingsScreen(), //
                    const MyTicketsScreen(), //
                    const MyUnlockedPropertiesScreen(), //
                    const MyPropertiesScreen(), //
                    const ManageEventsScreen(), //
                    const LodgeOwnerDashboard(), //
                    _activeEditShop != null ? EditShopScreen(key: ValueKey('edit_shop_${_activeEditShop!.id}'), shop: _activeEditShop!) : const Center(child: Text("No shop selected")), //
                    const CreateShopScreen(), //
                    _activeEditProduct != null ? EditProductScreen(key: ValueKey('edit_product_${_activeEditProduct!.id}'), product: _activeEditProduct!) : const Center(child: Text("No product selected")), //
                    const AddPropertyScreen(), //
                    PropertyFormScreen(key: ValueKey('prop_form_${_activeFormProperty?.id ?? 0}'), property: _activeFormProperty), //
                    const CreateLodgeScreen(), //
                    _activeEditLodge != null ? EditLodgeScreen(key: ValueKey('edit_lodge_${_activeEditLodge!.id}'), lodge: _activeEditLodge!) : const Center(child: Text("No lodge selected")), //
                    const MyLodgesScreen(), //
                    _activeLodgeRoomId != null ? AddRoomScreen(key: ValueKey('add_room_to_$_activeLodgeRoomId'), lodgeId: _activeLodgeRoomId!) : const Center(child: Text("No lodge selected for rooms modification")), //
                    const AddEventScreen(), //

                    _checkoutItems != null && _checkoutTotal != null ? CheckoutScreen(key: ValueKey('checkout_t_${_checkoutTotal.hashCode}'), items: _checkoutItems!, total: _checkoutTotal!) : const Center(child: Text("Checkout session inactive")), //
                    _paymentTransactionId != null && _paymentAmount != null && _paymentPurpose != null && _packageReferenceType != null && _paymentOnSuccess != null ? PaymentCheckoutScreen(key: ValueKey('payment_view_tx_$_paymentTransactionId'), transactionId: _paymentTransactionId!, amount: _paymentAmount!, purpose: _paymentPurpose!, referenceType: _packageReferenceType!, onSuccess: _paymentOnSuccess!) : const Center(child: Text("Payment session inactive")), //
                    
                    const MangoHubScreen(), //
                    const ScanTicketScreen(), //
                    
                    _activeEvent != null //
                        ? BuyTicketScreen(key: ValueKey('buy_t_${_activeEvent!.id}'), event: _activeEvent!) //
                        : const Center(child: Text("No active purchase pipeline session initialization coordinates found")), //

                    _unlockPropertyId != null && _unlockPropertyTitle != null && _unlockPropertyFee != null //
                        ? PropertyUnlockScreen( //
                            key: ValueKey('unlock_prop_$_unlockPropertyId'), //
                            propertyId: _unlockPropertyId!, //
                            propertyTitle: _unlockPropertyTitle!, //
                            unlockFee: _unlockPropertyFee!, //
                          ) //
                        : const Center(child: Text("No active property unlock request initialized")), //

                    _activeRoom != null && _activeRoomLodgeImages != null //
                        ? RoomDetailScreen( //
                            key: ValueKey('room_dt_${_activeRoom!.id}'), //
                            room: _activeRoom!, //
                            lodgeImages: _activeRoomLodgeImages!, //
                          ) //
                        : const Center(child: Text("No active room detail view initialized")), //

                    _checkoutBookingRoom != null //
                        ? BookingCheckoutScreen( //
                            key: ValueKey('book_room_${_checkoutBookingRoom!.id}'), //
                            room: _checkoutBookingRoom!, //
                          ) //
                        : const Center(child: Text("No active booking checkout pipeline initialized")), //
                    _calendarRoomId != null //
                        ? AvailabilityCalendarScreen( //
                            key: ValueKey('room_cal_$_calendarRoomId'), //
                            roomId: _calendarRoomId!, //
                          ) //
                        : const Center(child: Text("No active calendar preview session initialized")), //

                    _activeTicket != null ? TicketDetailScreen(key: ValueKey('ticket_${_activeTicket.id}'), ticket: _activeTicket!) : const Center(child: Text("No ticket selected")), //
                    const OwnerBookingsScreen(), //
                    const BookingQrScannerScreen(), //
                    _activeEvent != null //
                        ? EventTicketsScreen(key: ValueKey('ev_tickets_${_activeEvent!.id}'), event: _activeEvent!) //
                        : const Center(child: Text("No active event selected for ticket viewing")), //
                        
                    // 👈 ShopMapModal Widget Route Entry
                    _shopMapLat != null && _shopMapLng != null
                        ? ShopMapModal(
                            key: ValueKey('shop_map_${_shopMapLat}_$_shopMapLng'),
                            shopLat: _shopMapLat!,
                            shopLng: _shopMapLng!,
                          )
                        : const Center(child: Text("No shop location selected")),
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
    return _initialized ? widget.child : const SizedBox.shrink(); //
  }
}