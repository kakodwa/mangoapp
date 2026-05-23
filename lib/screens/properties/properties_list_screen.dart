import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/properties_provider.dart';
import 'property_details_screen.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import 'property_card.dart';
import '../../widgets/search_filter_widgets.dart';
import '../../theme/design_system/app_spacing.dart';

class PropertiesListScreen extends ConsumerStatefulWidget {
  const PropertiesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PropertiesListScreen> createState() =>
      _PropertiesListScreenState();
}

class _PropertiesListScreenState
    extends ConsumerState<PropertiesListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  bool _showFilters = false;
  String _selectedType = 'All';
  String _selectedDistrict = 'All';
  String _selectedPurpose = 'All';

  final List<String> _propertyTypes = [
    'All',
    'House',
    'Apartment',
    'Land',
    'Commercial',
  ];

  // 🇲🇼 ALL MALAWI DISTRICTS
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

  final List<String> _listingPurposes = [
    'All',
    'sale',
    'rent',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'All';
      _selectedDistrict = 'All';
      _selectedPurpose = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesProvider);

    return AppScaffold(
      appBar: const MainAppBar(title: 'Properties'),
      drawer: const MainDrawer(),
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [
          // =========================
          // SEARCH + FILTER TOGGLE
          // =========================
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: UnifiedSearchBar(
                    controller: _searchController,
                    hintText: 'Search properties...',
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

          // =========================
          // COLLAPSIBLE FILTERS
          // =========================
          UnifiedCollapsibleFilterPanel(
            isExpanded: _showFilters,
            onToggle: () => setState(() => _showFilters = !_showFilters),
            child: Column(
              children: [
                // PROPERTY TYPE FILTER
                UnifiedFilterSectionTitle(title: "Property Type"),
                UnifiedChipList(
                  items: _propertyTypes,
                  selected: _selectedType,
                  onSelect: (type) => setState(() => _selectedType = type),
                  height: 50,
                ),

                const SizedBox(height: AppSpacing.sm),

                // LISTING PURPOSE FILTER
                UnifiedFilterSectionTitle(title: "Listing Purpose"),
                UnifiedChipList(
                  items: _listingPurposes.map((p) => p.toUpperCase()).toList(),
                  selected: _selectedPurpose.toUpperCase(),
                  onSelect: (purpose) => setState(() => _selectedPurpose = purpose.toLowerCase()),
                  height: 50,
                ),

                const SizedBox(height: AppSpacing.sm),

                // DISTRICT FILTER
                UnifiedDistrictDropdown(
                  districts: _districts,
                  selected: _selectedDistrict,
                  onChanged: (value) => setState(() => _selectedDistrict = value),
                ),

                const SizedBox(height: AppSpacing.xs),

                // CLEAR FILTERS
                UnifiedClearButton(
                  onPressed: _clearFilters,
                  show: _selectedType != 'All' ||
                      _selectedPurpose != 'All' ||
                      _selectedDistrict != 'All' ||
                      _searchController.text.isNotEmpty,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxs),

          // =========================
          // PROPERTY LIST
          // =========================
          Expanded(
            child: propertiesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.mangoOrange,
                ),
              ),

              error: (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.redAccent,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Failed to load properties",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.mangoOrange,
                        ),
                        onPressed: () =>
                            ref.refresh(propertiesProvider),
                        child: Text("Retry"),
                      )
                    ],
                  ),
                ),
              ),

              data: (properties) {
                final filtered = properties.where((p) {
                  // SEARCH
                  final matchesSearch = p.title
                      .toLowerCase()
                      .contains(
                        _searchController.text
                            .toLowerCase(),
                      );

                  // TYPE
                  final matchesType =
                      _selectedType == 'All' ||
                          p.propertyType
                                  .toLowerCase() ==
                              _selectedType.toLowerCase();

                  // DISTRICT
                  final matchesDistrict =
                      _selectedDistrict == 'All' ||
                          p.district.toLowerCase() ==
                              _selectedDistrict
                                  .toLowerCase();

                  // PURPOSE
                  final matchesPurpose =
                      _selectedPurpose == 'All' ||
                          p.listingPurpose
                                  .toLowerCase() ==
                              _selectedPurpose
                                  .toLowerCase();

                  return matchesSearch &&
                      matchesType &&
                      matchesDistrict &&
                      matchesPurpose;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No properties found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.mangoOrange,
                  onRefresh: () async {
                    ref.refresh(propertiesProvider);
                  },

                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final property = filtered[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: PropertyCard(
                          property: property,
                        ),
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
