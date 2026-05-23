import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/products_provider.dart';
import '../products/product_card.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_filter_widgets.dart';
import '../../theme/design_system/app_spacing.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsListScreen> createState() =>
      _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _showFilters = false;
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

    return AppScaffold(
      appBar: const MainAppBar(title: 'Products'),
      drawer: const MainDrawer(),
      backgroundColor: const Theme.of(context).colorScheme.surfaceContainer,

      body: Column(
        children: [

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

                const SizedBox(height: AppSpacing.sm),

                // DISTRICT FILTER
                UnifiedFilterSectionTitle(title: "District (Malawi)"),
                UnifiedChipList(
                  items: _districts,
                  selected: _selectedDistrict,
                  onSelect: (val) => setState(() => _selectedDistrict = val),
                  height: 50,
                ),

                const SizedBox(height: AppSpacing.xs),

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

          const SizedBox(height: AppSpacing.xxs),

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
                        padding: const EdgeInsets.all(AppSpacing.sm),
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
}
