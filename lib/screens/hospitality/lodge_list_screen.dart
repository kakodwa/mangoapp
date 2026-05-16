import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/lodges_provider.dart';
import '../../widgets/hospitality/lodge_card.dart';

class LodgeListScreen extends ConsumerStatefulWidget {
  const LodgeListScreen({super.key});

  @override
  ConsumerState<LodgeListScreen> createState() => _LodgeListScreenState();
}

class _LodgeListScreenState extends ConsumerState<LodgeListScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'All';
      _selectedDistrict = 'All';
    });
  }

  @override
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

      body: Column(
        children: [

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

          // ================= LIST =================
          Expanded(
            child: lodgesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (lodges) {
                final filtered = lodges.where((lodge) {
                  final matchesSearch = lodge.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());


                  final matchesType =
                  _selectedType == 'All' ||
                  lodge.lodgeType.toLowerCase() ==
                  _selectedType.toLowerCase().replaceAll(' ', '_');

                  final matchesDistrict = _selectedDistrict == 'All' ||
                      lodge.district == _selectedDistrict;

                  return matchesSearch &&
                      matchesType &&
                      matchesDistrict;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No lodges found"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(lodgesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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
}