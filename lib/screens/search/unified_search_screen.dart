// lib/screens/search/unified_search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/search_provider.dart';
import '../../models/search_result_item.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_dropdown.dart';

// --- NATIVE DOMAIN MODELS ---
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../models/property_model.dart';
import '../../models/shop_model.dart';
import '../../models/event_model.dart';
import '../../models/lodge_model.dart';

// --- PLUGGED NATIVE FEED CARDS ---
import '../../screens/products/product_card.dart';
import '../../screens/shops/shop_card.dart';
import '../../screens/properties/property_card.dart';
import '../../widgets/hospitality/lodge_card.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/web_footer.dart';

class UnifiedSearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialType;
  final String? initialCategory;

  const UnifiedSearchScreen({
    Key? key,
    this.initialQuery,
    this.initialType,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final SearchProvider _provider = SearchProvider();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  Timer? _debounce;

  // Voice Search setup
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool _isFilterPanelExpanded = false;

  String? _selectedSubCategory;
  String? _selectedBrand;

  final List<Map<String, String>> _types = [
    {'key': 'product', 'label': 'Products'},
    {'key': 'shop', 'label': 'Shops'},
    {'key': 'all', 'label': 'All Items'},
    {'key': 'property', 'label': 'Properties'},
    {'key': 'lodge', 'label': 'Lodges'},
    {'key': 'event', 'label': 'Events'},
  ];

  final List<String> _malawiDistricts = [
    'Balaka', 'Blantyre', 'Chikwawa', 'Chiradzulu', 'Chitipa', 'Dedza', 'Dowa',
    'Karonga', 'Kasungu', 'Likoma', 'Lilongwe', 'Machinga', 'Mangochi', 'Mchinji',
    'Mulanje', 'Mwanza', 'Mzimba', 'Nkhata Bay', 'Nkhotakota', 'Nsanje', 'Ntcheu',
    'Ntchisi', 'Phalombe', 'Rumphi', 'Salima', 'Thyolo', 'Zomba', 'China', 'USA', 'Canada',
    'Tanzania', 'South Africa', 'Other',
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

  final Map<String, Map<String, List<String>>> _categorySubCategoryBrands = {
    'Electronics': {
      'Smartphones': ['Apple', 'Samsung', 'Xiaomi', 'Google', 'OnePlus'],
      'Tablets': ['Apple (iPad)', 'Samsung Galaxy Tab', 'Lenovo Tab', 'Amazon Fire'],
      'Laptops': ['Lenovo', 'Dell', 'HP', 'Apple MacBook', 'ASUS'],
      'Desktop Computers': ['Dell', 'HP', 'Apple iMac', 'Lenovo ThinkCentre'],
      'Computer Accessories': ['Logitech', 'Razer', 'Corsair', 'Anker'],
      'Printers & Scanners': ['HP', 'Canon', 'Epson', 'Brother'],
    },
    'Groceries': {
      'Rice & Grains': ["Ben's Original", 'Mahatma', 'Tilda', 'Lundberg'],
      'Flour': ['Gold Medal', 'King Arthur', 'Pillsbury'],
    },
    'Fashion': {
      'Shirts': ['Ralph Lauren', 'Tommy Hilfiger', 'Calvin Klein'],
      'Shoes': ['Nike', 'Adidas', 'Puma', 'Reebok'],
    },
  };

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
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialQuery != null && widget.initialCategory != null) {
      final subMap = _categorySubCategoryBrands[widget.initialCategory];
      if (subMap != null && subMap.containsKey(widget.initialQuery)) {
        _selectedSubCategory = widget.initialQuery;
      }
    }

    _provider.updateFilters(
      query: widget.initialQuery,
      type: widget.initialType ?? 'product',
      category: widget.initialCategory,
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _provider.fetchItems();
    }
  }

  void _onSearchSubmitted() {
    _provider.updateFilters(query: _searchController.text.trim());
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _provider.updateFilters(query: query);
    });
  }

  Future<void> _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (val) => setState(() => _isListening = false),
        onStatus: (val) {
          if (val == 'done') setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
            });
            _onSearchChanged(val.recognizedWords);
            if (val.finalResult) {
              setState(() => _isListening = false);
              _onSearchSubmitted();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _speech.stop();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.mangoOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: AppColors.mangoOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Matching Results Found 🔍',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We couldn\'t find anything matching your search query or filters. Try searching for something else or clearing active filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mangoOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset Search & Filters'),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _selectedSubCategory = null;
                        _selectedBrand = null;
                      });
                      _provider.resetSearch();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: WebFooter(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, child) {
        final double screenWidth = MediaQuery.of(context).size.width;

        final isFilterActive = _provider.selectedDistrict != null ||
            _provider.selectedCategory != null ||
            _provider.selectedListingPurpose != null ||
            _selectedSubCategory != null ||
            _selectedBrand != null;

        final bool isProductTabOnly = _provider.selectedType == 'product';

        final List<SearchResultItem> productItems =
            _provider.results.where((e) => e.resultType == 'product').toList();
        final List<SearchResultItem> bannerItems =
            _provider.results.where((e) => e.resultType != 'product').toList();

        double cardAspectRatio = screenWidth >= 900 ? 0.72 : 0.62;

        int productColumns = 2;
        if (screenWidth >= 1200)
          productColumns = 5;
        else if (screenWidth >= 900)
          productColumns = 4;
        else if (screenWidth >= 600) productColumns = 3;

        int bannerColumns = 1;
        if (screenWidth >= 1200)
          bannerColumns = 3;
        else if (screenWidth >= 800) bannerColumns = 2;

        final typeWithSubFilters = _provider.selectedType == 'product' ||
            _provider.selectedType == 'property' ||
            _provider.selectedType == 'lodge';

        final Map<String, List<String>>? subCategoryMap =
            _categorySubCategoryBrands[_provider.selectedCategory];
        final List<String> availableSubCategories = subCategoryMap?.keys.toList() ?? [];
        final List<String> availableBrands =
            (_selectedSubCategory != null && subCategoryMap != null)
                ? (subCategoryMap[_selectedSubCategory] ?? [])
                : [];

        final double gridHorizontalPadding =
            screenWidth > 1224 ? (screenWidth - 1200) / 2 : 12;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F5),
          body: SafeArea(
            child: Column(
              children: [
                // ================= ORANGE MARKETPLACE SEARCH CONTAINER =================
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CATEGORY SEGMENT TABS ---
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _types.map((type) {
                              final isSelected = _provider.selectedType == type['key'];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedSubCategory = null;
                                    _selectedBrand = null;
                                  });
                                  _provider.updateFilters(
                                    type: type['key'],
                                    district: SearchProvider.isUnchanged,
                                    category: null,
                                    listingPurpose: null,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        type['label']!,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? AppColors.mangoOrange : AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 3,
                                        width: isSelected ? 32 : 0,
                                        decoration: BoxDecoration(
                                          color: AppColors.mangoOrange,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- SEARCH FORM COMPONENT ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.mangoOrange,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mangoOrange.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.only(left: 18, right: 6, top: 6, bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {});
                                    _onSearchChanged(val);
                                  },
                                  onSubmitted: (_) => _onSearchSubmitted(),
                                  style: const TextStyle(fontSize: 15, color: AppColors.darkText),
                                  decoration: InputDecoration(
                                    hintText: 'Search products, shops, lodges, properties...',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),

                              // Voice Search Button
                              if (_searchController.text.isEmpty)
                                IconButton(
                                  icon: Icon(
                                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                    color: _isListening ? AppColors.mangoOrange : Colors.grey.shade500,
                                    size: 22,
                                  ),
                                  onPressed: _listenVoice,
                                  tooltip: 'Voice Search',
                                ),

                              // Clear Text Button
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.cancel_rounded, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    _onSearchChanged('');
                                  },
                                ),

                              // Filter Toggle Button
                              IconButton(
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: isFilterActive || _isFilterPanelExpanded
                                      ? AppColors.mangoOrange
                                      : Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isFilterPanelExpanded = !_isFilterPanelExpanded;
                                  });
                                },
                              ),
                              const SizedBox(width: 4),

                              // Orange Search Button
                              InkWell(
                                onTap: _onSearchSubmitted,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.mangoLight, AppColors.mangoOrange],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.search_rounded, color: Colors.white, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Search',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // EXPANDABLE FILTER PANEL
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: _isFilterPanelExpanded ? null : 0,
                    child: _isFilterPanelExpanded
                        ? Container(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.start,
                              children: [
                                SizedBox(
                                  width: screenWidth >= 600 ? 220 : double.infinity,
                                  child: AppDropdown<String>(
                                    label: 'District',
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
                                ),

                                if (typeWithSubFilters)
                                  SizedBox(
                                    width: screenWidth >= 600 ? 220 : double.infinity,
                                    child: AppDropdown<String>(
                                      label: 'Category',
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
                                        setState(() {
                                          _selectedSubCategory = null;
                                          _selectedBrand = null;
                                        });
                                        _provider.updateFilters(
                                          category: val,
                                          district: SearchProvider.isUnchanged,
                                          listingPurpose: SearchProvider.isUnchanged,
                                        );
                                      },
                                    ),
                                  ),

                                if (_provider.selectedType == 'product' && _provider.selectedCategory != null && availableSubCategories.isNotEmpty)
                                  SizedBox(
                                    width: screenWidth >= 600 ? 220 : double.infinity,
                                    child: AppDropdown<String>(
                                      label: 'Subcategory',
                                      value: availableSubCategories.contains(_selectedSubCategory) ? _selectedSubCategory : null,
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('All Subcategories')),
                                        ...availableSubCategories.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedSubCategory = val;
                                          _selectedBrand = null;
                                        });
                                        _provider.updateFilters(query: val ?? '');
                                      },
                                    ),
                                  ),

                                if (_provider.selectedType == 'product' && _selectedSubCategory != null && availableBrands.isNotEmpty)
                                  SizedBox(
                                    width: screenWidth >= 600 ? 220 : double.infinity,
                                    child: AppDropdown<String>(
                                      label: 'Brand',
                                      value: availableBrands.contains(_selectedBrand) ? _selectedBrand : null,
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('All Brands')),
                                        ...availableBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedBrand = val;
                                        });
                                      },
                                    ),
                                  ),

                                if (_provider.selectedType == 'property')
                                  SizedBox(
                                    width: screenWidth >= 600 ? 220 : double.infinity,
                                    child: AppDropdown<String>(
                                      label: 'Purpose',
                                      value: _provider.selectedListingPurpose,
                                      items: const [
                                        DropdownMenuItem(value: null, child: Text('Any Purpose')),
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
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: _provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.mangoOrange))
                      : _provider.errorMessage.isNotEmpty
                          ? Center(child: Text(_provider.errorMessage, style: const TextStyle(color: Colors.red)))
                          : _provider.results.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: () async => _provider.resetSearch(),
                                  color: AppColors.mangoOrange,
                                  child: CustomScrollView(
                                    controller: _scrollController,
                                    slivers: [
                                      if (isProductTabOnly || productItems.isNotEmpty)
                                        SliverPadding(
                                          padding: EdgeInsets.symmetric(horizontal: gridHorizontalPadding, vertical: 12.0),
                                          sliver: SliverGrid(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: productColumns,
                                              childAspectRatio: cardAspectRatio,
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

                                      if (!isProductTabOnly && bannerItems.isNotEmpty)
                                        SliverPadding(
                                          padding: EdgeInsets.symmetric(horizontal: gridHorizontalPadding, vertical: 12.0),
                                          sliver: SliverGrid(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: bannerColumns,
                                              childAspectRatio: bannerColumns == 1 ? 1.3 : 1.1,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                            ),
                                            delegate: SliverChildBuilderDelegate(
                                              (context, index) => _buildDynamicFeedCard(bannerItems[index]),
                                              childCount: bannerItems.length,
                                            ),
                                          ),
                                        ),

                                      if (_provider.isLoadingMore)
                                        const SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16),
                                            child: Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),
                                          ),
                                        ),

                                      const SliverToBoxAdapter(
                                        child: WebFooter(),
                                      ),
                                    ],
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

  Widget _buildDynamicFeedCard(SearchResultItem item) {
    final String type = item.resultType ?? '';

    switch (type) {
      case 'product':
        final String fallbackImage = item.imageUrl ?? item.details['image'] ?? '';
        final product = Product(
          id: item.id,
          ownerId: item.details['owner'],
          shopId: item.details['shop'] ?? 0,
          shopName: item.details['shop_name'] ?? 'Market Shop',
          shopDistrict: item.district,
          shopPhoneNumber: item.details['shop_phone_number']?.toString(),
          name: item.title,
          slug: item.details['slug'] ?? '',
          description: item.subtitle,
          image: fallbackImage.isNotEmpty ? fallbackImage : null,
          category: item.details['category'] ?? '',
          subCategory: item.details['sub_category'] ?? '',
          brand: item.details['brand'] ?? '',
          price: double.tryParse(item.price?.toString() ?? '0') ?? 0.0,
          originalPrice: item.details['original_price'] != null
              ? double.tryParse(item.details['original_price'].toString())
              : null,
          discountPercentage: item.details['discount_percentage'] ?? 0,
          stock: item.details['stock'] ?? 0,
          sku: item.details['sku'] ?? '',
          isActive: item.details['is_active'] ?? true,
          rating: double.tryParse(item.details['rating']?.toString() ?? '0') ?? 0.0,
          totalReviews: item.details['total_reviews'] ?? 0,
          createdAt: DateTime.tryParse(item.details['created_at'] ?? '') ?? DateTime.now(),
          images: fallbackImage.isNotEmpty ? [fallbackImage] : const [],
          variants: const [],
        );
        return ProductCard(product: product);

      case 'shop':
        final shop = Shop(
          id: item.id,
          name: item.title,
          slug: item.details['slug'] ?? '',
          description: item.subtitle,
          logo: item.details['logo'] ?? '',
          banner: item.imageUrl ?? item.details['banner'],
          category: item.details['category'] ?? '',
          latitude: double.tryParse(item.details['latitude']?.toString() ?? '0') ?? 0.0,
          longitude: double.tryParse(item.details['longitude']?.toString() ?? '0') ?? 0.0,
          address: item.details['address'] ?? '',
          city: item.city ?? '',
          district: item.district ?? '',
          phoneNumber: item.details['phone_number'] ?? '',
          email: item.details['email'] ?? '',
          status: item.details['status'] ?? 'pending',
          isActive: item.details['is_active'] ?? false,
          rating: double.tryParse(item.details['rating']?.toString() ?? '0') ?? 0.0,
          totalReviews: item.details['total_reviews'] ?? 0,
          createdAt: DateTime.tryParse(item.details['created_at'] ?? '') ?? DateTime.now(),
          productCount: item.details['product_count'],
        );
        return ShopCard(shop: shop);

      case 'property':
        final String mainImage = item.imageUrl ?? item.details['image'] ?? '';
        final propertyImages = mainImage.isNotEmpty
            ? [PropertyImage(id: 0, image: mainImage, isPrimary: true)]
            : <PropertyImage>[];

        final property = Property(
          id: item.id,
          ownerId: item.details['owner'] ?? 0,
          title: item.title,
          slug: item.details['slug'] ?? '',
          description: item.subtitle,
          listingPurpose: item.details['listing_purpose'] ?? 'sale',
          propertyType: item.details['property_type'] ?? 'house',
          status: item.details['status'] ?? 'available',
          latitude: double.tryParse(item.details['latitude']?.toString() ?? '0') ?? 0.0,
          longitude: double.tryParse(item.details['longitude']?.toString() ?? '0') ?? 0.0,
          address: item.details['address'] ?? '',
          city: item.city ?? '',
          district: item.district ?? '',
          bedrooms: item.details['bedrooms'],
          bathrooms: item.details['bathrooms'],
          sizeSqm: double.tryParse(item.details['size_sqm']?.toString() ?? '0') ?? 0.0,
          price: double.tryParse(item.price?.toString() ?? '0') ?? 0.0,
          currency: item.details['currency'] ?? 'MWK',
          isPubliclyVisible: item.details['is_publicly_visible'] ?? true,
          unlockFee: double.tryParse(item.details['unlock_fee']?.toString() ?? '0') ?? 50.0,
          viewCount: item.details['view_count'] ?? 0,
          images: propertyImages,
          ownerName: item.details['owner_name'] ?? '',
          ownerPhoneNumber: item.details['owner_phone_number']?.toString(),
          isUnlocked: item.details['is_unlocked'] ?? false,
          createdAt: DateTime.tryParse(item.details['created_at'] ?? '') ?? DateTime.now(),
        );
        return PropertyCard(property: property);

      case 'event':
        final event = EventModel(
          id: item.id,
          title: item.title,
          description: item.subtitle,
          venue: item.details['venue'] ?? '',
          district: item.district ?? '',
          city: item.city ?? '',
          latitude: double.tryParse(item.details['latitude']?.toString() ?? ''),
          longitude: double.tryParse(item.details['longitude']?.toString() ?? ''),
          eventDate: item.details['event_date'] ?? '',
          startTime: item.details['start_time'] ?? '00:00:00',
          endTime: item.details['end_time'] ?? '00:00:00',
          banner: item.imageUrl ?? item.details['banner'] ?? '',
          ticketPrice: double.tryParse(item.details['regular_ticket_price']?.toString() ?? '0') ?? 0.0,
          totalTickets: int.tryParse(item.details['total_tickets']?.toString() ?? '0') ?? 0,
          availableTickets: int.tryParse(item.details['tickets_remaining']?.toString() ?? '0') ?? 0,
          isFeatured: item.details['is_featured'] ?? false,
          organizerPhoneNumber: item.details['organizer_phone_number']?.toString(),
          ticketTypes: const [],
        );
        return EventCard(event: event);

      case 'lodge':
        final List<String> lodgeImages = [];
        if (item.imageUrl != null) {
          lodgeImages.add(item.imageUrl!);
        } else if (item.details['banner'] != null) {
          lodgeImages.add(item.details['banner']);
        }

        final lodge = Lodge(
          id: item.id,
          name: item.title,
          description: item.subtitle,
          lodgeType: item.details['lodge_type'] ?? 'Lodge',
          city: item.city ?? '',
          district: item.district ?? '',
          address: item.details['address'] ?? item.city ?? '',
          phoneNumber: item.details['phone_number'] ?? '',
          email: item.details['email'] ?? '',
          isVerified: item.details['is_verified'] ?? false,
          images: lodgeImages,
          latitude: double.tryParse(item.details['latitude']?.toString() ?? ''),
          longitude: double.tryParse(item.details['longitude']?.toString() ?? ''),
          ownerId: item.details['owner_id'] ?? item.details['owner'],
          ownerPhoneNumber: item.details['owner_phone_number']?.toString(),
        );
        return LodgeCard(lodge: lodge);

      default:
        return const SizedBox.shrink();
    }
  }
}