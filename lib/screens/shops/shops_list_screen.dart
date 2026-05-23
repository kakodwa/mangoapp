import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shops_provider.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../shops/shop_card.dart';
import '../../widgets/search_filter_widgets.dart';
import '../../theme/design_system/app_spacing.dart';

class ShopsListScreen extends ConsumerStatefulWidget {
  const ShopsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopsListScreen> createState() => _ShopsListScreenState();
}

class _ShopsListScreenState extends ConsumerState<ShopsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _selectedDistrict = 'All';

  bool _showFilters = false;

  final List<String> _categories = [
    'All',
    'Groceries',
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Health & Beauty',
  ];

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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedDistrict = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(shopsProvider);

    return AppScaffold(
      appBar: MainAppBar(
        title: 'Shops',
      ),
      drawer: const MainDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,

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

                const SizedBox(height: AppSpacing.sm),

                // ================= DISTRICT LIKE LODGE SCREEN =================
                const UnifiedFilterSectionTitle(title: "District"),
                UnifiedChipList(
                  items: _districts,
                  selected: _selectedDistrict,
                  onSelect: (d) => setState(() => _selectedDistrict = d),
                  height: 50,
                ),

                const SizedBox(height: AppSpacing.xs),

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

          const SizedBox(height: AppSpacing.xxs),

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

                  return matchesSearch &&
                      matchesCategory &&
                      matchesDistrict;
                }).toList();

                if (filteredShops.isEmpty) {
                  return const Center(child: Text("No shops found"));
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(shopsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: filteredShops.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return ShopCard(shop: filteredShops[index]);
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