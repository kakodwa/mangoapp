import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/properties_provider.dart';
import 'property_details_screen.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import 'property_card.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesProvider);

    return Scaffold(
      appBar: const MainAppBar(title: 'Properties'),
      drawer: const MainDrawer(),
      backgroundColor: const Color(0xFFF6F7FB),

      body: Column(
        children: [
          // =========================
          // SEARCH BAR
          // =========================
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
                  hintText: 'Search properties...',
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

          // =========================
          // PROPERTY TYPE FILTER
          // =========================
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _propertyTypes.length,
              itemBuilder: (context, index) {
                final type = _propertyTypes[index];

                return _buildFilterChip(
                  label: type,
                  selected: _selectedType == type,
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              },
            ),
          ),

          // =========================
          // LISTING PURPOSE FILTER
          // =========================
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _listingPurposes.length,
              itemBuilder: (context, index) {
                final purpose = _listingPurposes[index];

                return _buildFilterChip(
                  label: purpose.toUpperCase(),
                  selected: _selectedPurpose == purpose,
                  onTap: () {
                    setState(() {
                      _selectedPurpose = purpose;
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
                const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14),
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDistrict,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value!;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.redAccent,
                      ),

                      const SizedBox(height: 10),

                      const Text(
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
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.mangoOrange,
                        ),
                        onPressed: () =>
                            ref.refresh(propertiesProvider),
                        child: const Text("Retry"),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final property = filtered[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.04),
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