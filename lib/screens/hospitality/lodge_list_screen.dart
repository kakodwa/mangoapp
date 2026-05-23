import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/lodges_provider.dart';
import '../../widgets/hospitality/lodge_card.dart';
<<<<<<< HEAD
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_filter_widgets.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class LodgeListScreen extends ConsumerStatefulWidget {
  const LodgeListScreen({super.key});

  @override
  ConsumerState<LodgeListScreen> createState() => _LodgeListScreenState();
}

class _LodgeListScreenState extends ConsumerState<LodgeListScreen> {
  final TextEditingController _searchController = TextEditingController();

<<<<<<< HEAD
  bool _showFilters = false;

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'All';
      _selectedDistrict = 'All';
    });
  }

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    final lodgesAsync = ref.watch(lodgesProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Stays & Lodges'),
      ),
=======
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lodgesAsync = ref.watch(lodgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stays & Lodges'),
      ),
      backgroundColor: const Color(0xFFF6F7FB),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

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
                    hintText: 'Search lodges...',
                    onChanged: (_) => setState(() {}),
                    onClear: () => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
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

                const SizedBox(height: 12),

                // DISTRICT FILTER
                const UnifiedFilterSectionTitle(title: "District"),
                UnifiedChipList(
                  items: _districts,
                  selected: _selectedDistrict,
                  onSelect: (val) => setState(() => _selectedDistrict = val),
                  height: 50,
                ),

                const SizedBox(height: 8),

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
                  hintText: 'Search lodges...',
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

          // ================= TYPE FILTER =================
          _buildSectionTitle("Type"),
          _buildChipList(_types, _selectedType, (val) {
            setState(() => _selectedType = val);
          }),

          // ================= DISTRICT FILTER =================
          _buildSectionTitle("District (Malawi)"),
          _buildChipList(_districts, _selectedDistrict, (val) {
            setState(() => _selectedDistrict = val);
          }),

          // ================= CLEAR =================
          if (_selectedType != 'All' ||
              _selectedDistrict != 'All' ||
              _searchController.text.isNotEmpty)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text("Clear filters"),
            ),

          const SizedBox(height: 6),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

          // ================= LIST =================
          Expanded(
            child: lodgesAsync.when(
<<<<<<< HEAD
              loading: () =>
                  const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text(e.toString())),

=======
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(child: Text(e.toString())),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
              data: (lodges) {
                final filtered = lodges.where((lodge) {
                  final matchesSearch = lodge.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

<<<<<<< HEAD
                  final matchesType = _selectedType == 'All' ||
                      lodge.lodgeType.toLowerCase() ==
                          _selectedType.toLowerCase().replaceAll(' ', '_');
=======

                  final matchesType =
                  _selectedType == 'All' ||
                  lodge.lodgeType.toLowerCase() ==
                  _selectedType.toLowerCase().replaceAll(' ', '_');
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

                  final matchesDistrict = _selectedDistrict == 'All' ||
                      lodge.district == _selectedDistrict;

<<<<<<< HEAD
                  return matchesSearch && matchesType && matchesDistrict;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No lodges found"));
=======
                  return matchesSearch &&
                      matchesType &&
                      matchesDistrict;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No lodges found"),
                  );
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(lodgesProvider);
                  },
                  child: ListView.builder(
<<<<<<< HEAD
                    padding: const EdgeInsets.all(12),
=======
                    padding: const EdgeInsets.all(16),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD
=======

  // ================= HELPERS =================

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
              selectedColor: Colors.orange.withOpacity(0.15),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.orange : Colors.black87,
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
}