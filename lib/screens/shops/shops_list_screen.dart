import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shops_provider.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
<<<<<<< HEAD
import '../../widgets/app_scaffold.dart';
import '../shops/shop_card.dart';
import '../../widgets/search_filter_widgets.dart';
=======
import '../shops/shop_card.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class ShopsListScreen extends ConsumerStatefulWidget {
  const ShopsListScreen({Key? key}) : super(key: key);

  @override
<<<<<<< HEAD
  ConsumerState<ShopsListScreen> createState() => _ShopsListScreenState();
}

class _ShopsListScreenState extends ConsumerState<ShopsListScreen> {
  final TextEditingController _searchController = TextEditingController();
=======
  ConsumerState<ShopsListScreen> createState() =>
      _ShopsListScreenState();
}

class _ShopsListScreenState
    extends ConsumerState<ShopsListScreen> {
  final TextEditingController _searchController =
      TextEditingController();
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

  String _selectedCategory = 'All';
  String _selectedDistrict = 'All';

<<<<<<< HEAD
  bool _showFilters = false;

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  final List<String> _categories = [
    'All',
    'Groceries',
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Health & Beauty',
  ];

<<<<<<< HEAD
=======
  // 🇲🇼 MALAWI DISTRICTS
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  final List<String> _districts = [
    'All',
    'Balaka',
    'Blantyre',
    'Chikwawa',
    'Chiradzulu',
    'Chitipa',
    'Dedza',
    'Dowa',
    'Karonga',
    'Kasungu',
    'Likoma',
    'Lilongwe',
    'Machinga',
    'Mangochi',
    'Mchinji',
    'Mulanje',
    'Mwanza',
    'Mzimba',
    'Neno',
    'Nkhata Bay',
    'Nkhotakota',
    'Nsanje',
    'Ntcheu',
    'Ntchisi',
    'Phalombe',
    'Rumphi',
    'Salima',
    'Thyolo',
    'Zomba',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedDistrict = 'All';
    });
=======
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor:
            AppColors.mangoOrange.withOpacity(0.15),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? AppColors.mangoOrange
              : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  }

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(shopsProvider);

<<<<<<< HEAD
    return AppScaffold(
      appBar: MainAppBar(
        title: 'Shops',
      ),
=======
    return Scaffold(
      appBar: const MainAppBar(title: 'Shops'),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      drawer: const MainDrawer(),
      backgroundColor: const Color(0xFFF6F7FB),

      body: Column(
        children: [
<<<<<<< HEAD

          // ================= SEARCH + FILTER TOGGLE =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: UnifiedSearchBar(
                    controller: _searchController,
                    hintText: 'Search shops...',
                    onChanged: (_) => setState(() {}),
                    onClear: () => setState(() {}),
                  ),
                ),
                UnifiedFilterToggle(
                  isExpanded: _showFilters,
                  onPressed: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                ),
              ],
            ),
          ),

          // ================= COLLAPSIBLE FILTERS =================
          UnifiedCollapsibleFilterPanel(
            isExpanded: _showFilters,
            onToggle: () => setState(() => _showFilters = !_showFilters),
            child: Column(
              children: [

                // CATEGORY FILTER (chips)
                const UnifiedFilterSectionTitle(title: "Category"),
                UnifiedChipList(
                  items: _categories,
                  selected: _selectedCategory,
                  onSelect: (c) => setState(() => _selectedCategory = c),
                  height: 50,
                ),

                const SizedBox(height: 12),

                // ================= DISTRICT LIKE LODGE SCREEN =================
                const UnifiedFilterSectionTitle(title: "District"),
                UnifiedChipList(
                  items: _districts,
                  selected: _selectedDistrict,
                  onSelect: (d) => setState(() => _selectedDistrict = d),
                  height: 50,
                ),

                const SizedBox(height: 8),

                // CLEAR FILTERS
                UnifiedClearButton(
                  onPressed: _clearFilters,
                  show: _selectedCategory != 'All' ||
                      _selectedDistrict != 'All' ||
                      _searchController.text.isNotEmpty,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ================= LIST =================
          Expanded(
            child: shopsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (shops) {
                final filteredShops = shops.where((shop) {
                  final matchesSearch = shop.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

                  final matchesCategory = _selectedCategory == 'All' ||
                      shop.category.toLowerCase() ==
                          _selectedCategory.toLowerCase();

                  // ================= SAME STYLE AS LODGE =================
                  final matchesDistrict =
                      _selectedDistrict == 'All' ||
                      shop.district == _selectedDistrict;
=======
          // =========================
          // SEARCH BAR
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search shops...',
                  prefixIcon:
                      const Icon(Icons.search),
                  suffixIcon:
                      _searchController
                              .text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                              ),
                              onPressed: () {
                                _searchController
                                    .clear();
                                setState(() {});
                              },
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // =========================
          // CATEGORY FILTER
          // =========================
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category =
                    _categories[index];

                return _buildFilterChip(
                  label: category,
                  selected:
                      _selectedCategory ==
                          category,
                  onTap: () {
                    setState(() {
                      _selectedCategory =
                          category;
                    });
                  },
                );
              },
            ),
          ),

          // =========================
          // DISTRICT FILTER
          // =========================
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              6,
              16,
              6,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  )
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDistrict,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  items: _districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict =
                          value!;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // =========================
          // SHOP LIST
          // =========================
          Expanded(
            child: shopsAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.mangoOrange,
                ),
              ),

              error: (error, _) => Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color:
                            Colors.redAccent,
                      ),

                      const SizedBox(
                          height: 10),

                      const Text(
                        "Failed to load shops",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      Text(
                        error.toString(),
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(
                          height: 16),

                      ElevatedButton(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors
                                  .mangoOrange,
                        ),
                        onPressed: () =>
                            ref.refresh(
                          shopsProvider,
                        ),
                        child:
                            const Text("Retry"),
                      )
                    ],
                  ),
                ),
              ),

              data: (shops) {
                final filteredShops =
                    shops.where((shop) {
                  // SEARCH
                  final matchesSearch =
                      shop.name
                          .toLowerCase()
                          .contains(
                            _searchController
                                .text
                                .toLowerCase(),
                          );

                  // CATEGORY
                  final matchesCategory =
                      _selectedCategory ==
                              'All' ||
                          shop.category
                                  .toLowerCase() ==
                              _selectedCategory
                                  .toLowerCase();

                  // DISTRICT
                  final matchesDistrict =
                      _selectedDistrict ==
                              'All' ||
                          shop.district
                                  .toLowerCase() ==
                              _selectedDistrict
                                  .toLowerCase();
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

                  return matchesSearch &&
                      matchesCategory &&
                      matchesDistrict;
                }).toList();

                if (filteredShops.isEmpty) {
<<<<<<< HEAD
                  return const Center(child: Text("No shops found"));
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(shopsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredShops.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return ShopCard(shop: filteredShops[index]);
=======
                  return const Center(
                    child: Text(
                      "No shops found",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color:
                      AppColors.mangoOrange,
                  onRefresh: () async {
                    ref.refresh(
                      shopsProvider,
                    );
                  },
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount:
                        filteredShops.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(
                      height: 10,
                    ),
                    itemBuilder:
                        (context, index) {
                      return ShopCard(
                        shop:
                            filteredShops[
                                index],
                      );
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}