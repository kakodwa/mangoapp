import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/products_provider.dart';
import '../products/product_card.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
<<<<<<< HEAD
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_filter_widgets.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsListScreen> createState() =>
      _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();

<<<<<<< HEAD
  bool _showFilters = false;
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  String _selectedCategory = 'All';
  String _selectedDistrict = 'All';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Groceries',
    'Home',
    'Beauty',
  ];

  // 🇲🇼 Malawi districts (edit if you want full official list)
  final List<String> _districts = [
    'All',
    'Lilongwe',
    'Blantyre',
    'Mzuzu',
    'Zomba',
    'Mangochi',
    'Kasungu',
    'Salima',
    'Dedza',
    'Nkhotakota',
    'Karonga',
    'Chikwawa',
    'Nsanje',
    'Machinga',
    'Balaka',
    'Ntcheu',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedDistrict = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

<<<<<<< HEAD
    return AppScaffold(
=======
    return Scaffold(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      appBar: const MainAppBar(title: 'Products'),
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
                    hintText: 'Search products...',
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
                // CATEGORY FILTER
                UnifiedFilterSectionTitle(title: "Category"),
                UnifiedChipList(
                  items: _categories,
                  selected: _selectedCategory,
                  onSelect: (val) => setState(() => _selectedCategory = val),
                  height: 50,
                ),

                const SizedBox(height: 12),

                // DISTRICT FILTER
                UnifiedFilterSectionTitle(title: "District (Malawi)"),
                UnifiedChipList(
                  items: _districts,
                  selected: _selectedDistrict,
                  onSelect: (val) => setState(() => _selectedDistrict = val),
                  height: 50,
                ),

                const SizedBox(height: 8),

                // CLEAR FILTER
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
=======
          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ================= CATEGORY FILTER =================
          _buildSectionTitle("Category"),
          _buildChipList(_categories, _selectedCategory, (val) {
            setState(() => _selectedCategory = val);
          }),

          // ================= DISTRICT FILTER =================
          _buildSectionTitle("District (Malawi)"),
          _buildChipList(_districts, _selectedDistrict, (val) {
            setState(() => _selectedDistrict = val);
          }),

          // ================= CLEAR FILTER =================
          if (_selectedCategory != 'All' ||
              _selectedDistrict != 'All' ||
              _searchController.text.isNotEmpty)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text("Clear filters"),
            ),

          const SizedBox(height: 6),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

          // ================= PRODUCTS =================
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.mangoOrange,
                ),
              ),

              error: (error, stack) => Center(
                child: Text(error.toString()),
              ),

              data: (products) {
                final filteredProducts = products.where((product) {
                  final matchesSearch = product.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

                  final matchesCategory =
                      _selectedCategory == 'All' ||
                          product.category == _selectedCategory;

                  // ⚠️ IMPORTANT: assumes product has shopDistrict
                  final matchesDistrict =
                      _selectedDistrict == 'All' ||
                          product.shopDistrict == _selectedDistrict;

                  return matchesSearch &&
                      matchesCategory &&
                      matchesDistrict;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text("No products found"),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.mangoOrange,
                  onRefresh: () async {
                    ref.refresh(productsProvider);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;

                      if (constraints.maxWidth >= 1200) {
                        crossAxisCount = 5;
                      } else if (constraints.maxWidth >= 900) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth >= 600) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.58,
                        ),
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: filteredProducts[index],
                          );
                        },
                      );
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
<<<<<<< HEAD
}
=======

  // ================= UI HELPERS =================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChipList(
    List<String> items,
    String selected,
    Function(String) onSelect,
  ) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected == item;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (_) => onSelect(item),
              selectedColor: AppColors.mangoOrange.withOpacity(0.15),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.mangoOrange
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
