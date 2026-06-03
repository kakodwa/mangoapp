import 'dart:async';
import 'package:flutter/material.dart';
import '../../providers/search_provider.dart';
import '../../models/search_result_item.dart';

// --- DESIGN SYSTEM & LAYOUT IMPORTS ---
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_dropdown.dart';
import '../../theme/design_system/app_button.dart';

// --- NATIVE DOMAIN MODELS ---
import '../../models/product_model.dart';
import '../../models/property_model.dart';
import '../../models/shop_model.dart';
import '../../models/event_model.dart';
import '../../models/lodge_model.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_scaffold.dart';

// --- PLUGGED NATIVE FEED CARDS ---
import '../../screens/products/product_card.dart';
import '../../screens/shops/shop_card.dart';
import '../../screens/properties/property_card.dart';
import '../../widgets/hospitality/lodge_card.dart';
import '../../widgets/events/event_card.dart';

class UnifiedSearchScreen extends StatefulWidget {
  const UnifiedSearchScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final SearchProvider _provider = SearchProvider();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, String>> _types = [
    {'key': 'all', 'label': 'All items'},
    {'key': 'product', 'label': 'Products'},
    {'key': 'property', 'label': 'Properties'},
    {'key': 'lodge', 'label': 'Lodges'},
    {'key': 'event', 'label': 'Events'},
    {'key': 'shop', 'label': 'Shops'},
  ];

  final List<String> _malawiDistricts = [
    'Balaka', 'Blantyre', 'Chikwawa', 'Chiradzulu', 'Chitipa', 'Dedza', 'Dowa',
    'Karonga', 'Kasungu', 'Likoma', 'Lilongwe', 'Machinga', 'Mangochi', 'Mchinji',
    'Mulanje', 'Mwanza', 'Mzimba', 'Nkhata Bay', 'Nkhotakota', 'Nsanje', 'Ntcheu',
    'Ntchisi', 'Phalombe', 'Rumphi', 'Salima', 'Thyolo', 'Zomba'
  ];

  final List<Map<String, String>> _productCategories = [
    {'key': 'Fashion', 'label': 'Fashion'},
    {'key': 'Electronics', 'label': 'Electronics'},
    {'key': 'Groceries', 'label': 'Groceries'},
    {'key': 'Home & Living', 'label': 'Home & Living'},
    {'key': 'Beauty & Personal Care', 'label': 'Beauty & Personal Care'},
    {'key': 'Health & Wellness', 'label': 'Health & Wellness'},
    {'key': 'Agriculture', 'label': 'Agriculture'},
    {'key': 'Vehicles', 'label': 'Vehicles'},
    {'key': 'Construction & Hardware', 'label': 'Construction & Hardware'},
    {'key': 'Books & Education', 'label': 'Books & Education'},
    {'key': 'Sports & Outdoors', 'label': 'Sports & Outdoors'},
    {'key': 'Baby & Kids', 'label': 'Baby & Kids'},
    {'key': 'Food & Beverages', 'label': 'Food & Beverages'},
    {'key': 'Pets & Animals', 'label': 'Pets & Animals'},
    {'key': 'Office Supplies', 'label': 'Office Supplies'},
    {'key': 'Entertainment', 'label': 'Entertainment'},
    {'key': 'Services', 'label': 'Services'},
    {'key': 'Industrial Equipment', 'label': 'Industrial Equipment'},
  ];

  final List<Map<String, String>> _propertyCategories = [
    {'key': 'house', 'label': 'House'},
    {'key': 'apartment', 'label': 'Apartment'},
    {'key': 'land', 'label': 'Land'},
    {'key': 'commercial', 'label': 'Commercial'},
  ];

  final List<Map<String, String>> _lodgeCategories = [
    {'key': 'hotel', 'label': 'Hotel'},
    {'key': 'lodge', 'label': 'Lodge'},
    {'key': 'guest_house', 'label': 'Guest House'},
    {'key': 'apartment', 'label': 'Apartment'},
    {'key': 'villa', 'label': 'Villa'},
    {'key': 'resort', 'label': 'Resort'},
  ];

  @override
  void initState() {
    super.initState();
    _provider.fetchItems();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _provider.fetchItems();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _provider.updateFilters(query: query);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final typeWithSubFilters = _provider.selectedType == 'product' || 
                                       _provider.selectedType == 'property' || 
                                       _provider.selectedType == 'lodge';

            return AnimatedBuilder(
              animation: _provider,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filter Search Results',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),

                        AppDropdown<String>(
                          label: 'Location District',
                          value: _provider.selectedDistrict,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Districts')),
                            ..._malawiDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                          ],
                          onChanged: (val) {
                            _provider.updateFilters(
                              district: val,
                              category: SearchProvider.isUnchanged,
                              listingPurpose: SearchProvider.isUnchanged,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (typeWithSubFilters) ...[
                          AppDropdown<String>(
                            label: 'Sub-Category Group',
                            value: _provider.selectedCategory,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Categories')),
                              if (_provider.selectedType == 'product')
                                ..._productCategories.map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!))),
                              if (_provider.selectedType == 'property')
                                ..._propertyCategories.map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!))),
                              if (_provider.selectedType == 'lodge')
                                ..._lodgeCategories.map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!))),
                            ],
                            onChanged: (val) {
                              _provider.updateFilters(
                                category: val,
                                district: SearchProvider.isUnchanged,
                                listingPurpose: SearchProvider.isUnchanged,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        if (_provider.selectedType == 'property') ...[
                          AppDropdown<String>(
                            label: 'Listing Purpose',
                            value: _provider.selectedListingPurpose,
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Any Purpose (Rent/Sale)')),
                              DropdownMenuItem(value: 'sale', child: Text('For Sale')),
                              DropdownMenuItem(value: 'rent', child: Text('For Rent')),
                            ],
                            onChanged: (val) {
                              _provider.updateFilters(
                                listingPurpose: val,
                                district: SearchProvider.isUnchanged,
                                category: SearchProvider.isUnchanged,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          text: "Apply Active Filters",
                          fullWidth: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: "MangoHub"),
      drawer: const MainDrawer(),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, child) {
          final isFilterActive = _provider.selectedDistrict != null || 
                                 _provider.selectedCategory != null || 
                                 _provider.selectedListingPurpose != null;

          final bool isProductTabOnly = _provider.selectedType == 'product';

          // --- SPLIT THE DATA TO SOLVE THE MIXED LAYOUT BUG NATIVELY ---
          final List<SearchResultItem> productItems = _provider.results.where((e) => e.resultType == 'product').toList();
          final List<SearchResultItem> bannerItems = _provider.results.where((e) => e.resultType != 'product').toList();

          return Column(
            children: [
              // 1. INPUT SEARCH BAR & ACTIONS FILTER BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search matching items...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _provider.updateFilters(query: '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showFilterBottomSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: isFilterActive ? AppColors.mangoOrange.withOpacity(0.15) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFilterActive ? AppColors.mangoOrange : Colors.grey.shade300,
                            width: isFilterActive ? 1.6 : 1,
                          ),
                        ),
                        child: const Icon(Icons.tune_rounded),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. HORIZONTAL SCROLL CHIP TABS
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _types.length,
                  itemBuilder: (context, index) {
                    final type = _types[index];
                    final isSelected = _provider.selectedType == type['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(type['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.primary(context).withOpacity(0.2),
                        checkmarkColor: AppColors.primary(context),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary(context) : AppColors.darkText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (bool selected) {
                          _provider.updateFilters(
                            type: type['key'],
                            district: SearchProvider.isUnchanged,
                            category: null,
                            listingPurpose: null,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // 3. ADAPTIVE HYBRID SLIVER VIEW ENGINE
              Expanded(
                child: _provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.mangoOrange))
                    : _provider.errorMessage.isNotEmpty
                        ? Center(child: Text(_provider.errorMessage, style: const TextStyle(color: Colors.red)))
                        : _provider.results.isEmpty
                            ? const Center(child: Text('No matching items found.'))
                            : RefreshIndicator(
                                onRefresh: () async => _provider.resetSearch(),
                                color: AppColors.mangoOrange,
                                child: CustomScrollView(
                                  controller: _scrollController,
                                  slivers: [
                                    
                                    // =========================================================
                                    // SECTION A: IF THERE ARE PRODUCTS, RENDER THEM IN A 2-COLUMN GRID
                                    // =========================================================
                                    if (isProductTabOnly || productItems.isNotEmpty)
                                      SliverPadding(
                                        padding: const EdgeInsets.all(12.0),
                                        sliver: SliverGrid(
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.72, // Perfect ProductCard layout bounding boxes
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final item = isProductTabOnly ? _provider.results[index] : productItems[index];
                                              return _buildDynamicFeedCard(item);
                                            },
                                            childCount: isProductTabOnly ? _provider.results.length : productItems.length,
                                          ),
                                        ),
                                      ),

                                    // =========================================================
                                    // SECTION B: RENDER PROPERTIES, EVENT BANNERS, SHOPS FULL-WIDTH
                                    // =========================================================
                                    if (!isProductTabOnly && bannerItems.isNotEmpty)
                                      SliverPadding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) => _buildDynamicFeedCard(bannerItems[index]),
                                            childCount: bannerItems.length,
                                          ),
                                        ),
                                      ),

                                    // Infinite scrolling pagination item loading indicators
                                    if (_provider.isLoadingMore)
                                      const SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDynamicFeedCard(SearchResultItem item) {
    switch (item.resultType) {
      
      case 'product':
        final product = Product(
          id: item.id,
          name: item.title,
          slug: '', 
          description: item.subtitle,
          category: item.details['category'] ?? 'Electronics',
          price: item.price ?? 0.0,
          originalPrice: null,
          discountPercentage: 0,
          stock: item.details['stock'] ?? 1,
          sku: item.details['sku'] ?? '',
          isActive: true,
          rating: double.tryParse(item.details['rating']?.toString() ?? '0.0') ?? 0.0,
          totalReviews: 0,
          images: item.imageUrl != null ? [item.imageUrl!] : [],
          shopId: 0,
          shopName: '',
          ownerId: null,
          shopPhoneNumber: null,
          shopDistrict: item.district,
          createdAt: DateTime.now(),
        );
        return ProductCard(product: product);

      case 'property':
        final property = Property(
          id: item.id,
          title: item.title,
          slug: '', 
          description: item.subtitle,
          listingPurpose: item.details['purpose'] ?? 'sale',
          propertyType: item.details['type'] ?? 'house',
          status: 'available',
          city: item.city ?? '',
          district: item.district ?? '',
          address: '',
          sizeSqm: 0.0,
          price: item.price ?? 0.0,
          currency: 'MWK',
          isPubliclyVisible: true,
          unlockFee: 50.0,
          viewCount: 0,
          images: [], 
          ownerId: 0,
          ownerName: '',
          ownerPhoneNumber: null,
          isUnlocked: false,
          createdAt: DateTime.now(),
          latitude: 0.0,
          longitude: 0.0,
        );
        return PropertyCard(property: property);

      case 'shop':
        final shop = Shop(
          id: item.id,
          name: item.title,
          slug: '', 
          description: item.subtitle,
          logo: item.imageUrl ?? '',
          banner: null,
          category: item.details['category'] ?? '',
          city: item.city ?? '',
          district: item.district ?? '',
          address: item.details['address'] ?? '',
          phoneNumber: '',
          email: '',
          isActive: true,
          rating: double.tryParse(item.details['rating']?.toString() ?? '0.0') ?? 0.0,
          totalReviews: 0,
          productCount: 0,
          latitude: 0.0,
          longitude: 0.0,
          status: item.details['status'] ?? 'approved',
          createdAt: DateTime.now(),
        );
        return ShopCard(shop: shop);

      case 'event':
        final event = EventModel(
          id: item.id,
          title: item.title,
          description: item.subtitle,
          venue: item.details['venue'] ?? '',
          city: item.city ?? '',
          district: item.district ?? '',
          eventDate: item.details['event_date'] ?? '',
          startTime: item.details['start_time'] ?? '00:00:00',
          endTime: item.details['end_time'] ?? '00:00:00',
          banner: item.imageUrl ?? '',
          ticketPrice: item.details['regular_ticket_price'] ?? '0.00',
          totalTickets: item.details['total_tickets'] ?? '0',
          availableTickets: item.details['tickets_remaining'] ?? '0',
          isFeatured: item.details['is_featured'] ?? false,
          ticketTypes: [],
          organizerPhoneNumber: null,
        );
        return EventCard(event: event);

      case 'lodge':
        final lodge = Lodge(
          id: item.id,
          name: item.title,
          description: item.subtitle,
          lodgeType: item.details['lodge_type'] ?? 'Lodge',
          city: item.city ?? '',
          district: item.district ?? '',
          address: item.city ?? '',
          phoneNumber: item.details['phone'] ?? '',
          email: '',
          isVerified: false,
          images: item.imageUrl != null ? [item.imageUrl!] : [],
        );
        return LodgeCard(lodge: lodge);

      default:
        return const SizedBox.shrink();
    }
  }
}