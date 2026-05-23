import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';

import '../../providers/lodges_provider.dart';
import '../../widgets/hospitality/lodge_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_filter_widgets.dart';
import '../../theme/design_system/app_spacing.dart';

class LodgeListScreen extends ConsumerStatefulWidget {
  const LodgeListScreen({super.key});

  @override
  ConsumerState<LodgeListScreen> createState() => _LodgeListScreenState();
}

class _LodgeListScreenState extends ConsumerState<LodgeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _showFilters = false;

  String _selectedType = 'All';
  String _selectedDistrict = 'All';

  final List<String> _types = [
    'All',
    'Hotel',
    'Lodge',
    'Guest House',
    'Apartment',
    'Villa',
    'Resort',
  ];

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
      _selectedType = 'All';
      _selectedDistrict = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lodgesAsync = ref.watch(lodgesProvider);

    return AppScaffold(

      appBar: const MainAppBar(title: 'Stays & Lodges'),
      drawer: const MainDrawer(),

      body: Column(
        children: [

          // ================= SEARCH + FILTER TOGGLE =================
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: UnifiedSearchBar(
                    controller: _searchController,
                    hintText: 'Search lodges...',
                    onChanged: (_) => setState(() {}),
                    onClear: () => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
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

                // TYPE FILTER
                const UnifiedFilterSectionTitle(title: "Type"),
                UnifiedChipList(
                  items: _types,
                  selected: _selectedType,
                  onSelect: (val) => setState(() => _selectedType = val),
                  height: 50,
                ),

                const SizedBox(height: AppSpacing.sm),

                // DISTRICT FILTER
                const UnifiedFilterSectionTitle(title: "District"),
                UnifiedChipList(
                  items: _districts,
                  selected: _selectedDistrict,
                  onSelect: (val) => setState(() => _selectedDistrict = val),
                  height: 50,
                ),

                const SizedBox(height: AppSpacing.xs),

                // CLEAR BUTTON
                UnifiedClearButton(
                  onPressed: _clearFilters,
                  show: _selectedType != 'All' ||
                      _selectedDistrict != 'All' ||
                      _searchController.text.isNotEmpty,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxs),

          // ================= LIST =================
          Expanded(
            child: lodgesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text(e.toString())),

              data: (lodges) {
                final filtered = lodges.where((lodge) {
                  final matchesSearch = lodge.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

                  final matchesType = _selectedType == 'All' ||
                      lodge.lodgeType.toLowerCase() ==
                          _selectedType.toLowerCase().replaceAll(' ', '_');

                  final matchesDistrict = _selectedDistrict == 'All' ||
                      lodge.district == _selectedDistrict;

                  return matchesSearch && matchesType && matchesDistrict;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No lodges found"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(lodgesProvider);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return LodgeCard(lodge: filtered[index]);
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