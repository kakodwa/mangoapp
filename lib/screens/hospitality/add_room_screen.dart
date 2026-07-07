// lib/screens/hospitality/add_room_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../main_tabs_screen.dart';
import '../../widgets/web_footer.dart';

class AddRoomScreen extends ConsumerStatefulWidget {
  final int lodgeId;

  const AddRoomScreen({
    super.key,
    required this.lodgeId,
  });

  @override
  ConsumerState<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends ConsumerState<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  final roomNumber = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final capacity = TextEditingController();
  final totalRooms = TextEditingController();

  String roomType = "single";

  bool hasWifi = false;
  bool hasTv = false;
  bool hasAc = false;
  bool hasBreakfast = false;
  bool isAvailable = true;

  bool loading = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      await api.post(
        "rooms/",
        data: {
          "lodge": widget.lodgeId,
          "room_type": roomType,
          "room_number": roomNumber.text,
          "title": title.text,
          "description": description.text,
          "price_per_night": double.parse(price.text),
          "capacity": int.parse(capacity.text),
          "total_rooms": int.parse(totalRooms.text),
          "has_wifi": hasWifi,
          "has_tv": hasTv,
          "has_ac": hasAc,
          "has_breakfast": hasBreakfast,
          "is_available": isAvailable,
        },
        fromJson: (json) => json,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room added successfully")),
        );
        
        // Return context frame focus index cleanly back to Lodge Dashboard
        MainTabsScreen.of(context)?.setSelectedIndex(30);
      }
    } catch (e) {
      debugPrint("ADD ROOM ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add room")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    // Standalone Scaffold root elements and internal redundant AppBars are extracted 
    // to allow native layout continuity underneath your master tab layout system.
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: "Room Number",
                        controller: roomNumber,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Title / Room Identifier Name",
                        controller: title,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Description",
                        controller: description,
                        type: TextFieldType.multiline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Price Per Night (MWK)",
                        controller: price,
                        type: TextFieldType.number,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Guest Capacity Count",
                        controller: capacity,
                        type: TextFieldType.number,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Total Allocated Units Available",
                        controller: totalRooms,
                        type: TextFieldType.number,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      DropdownButtonFormField<String>(
                        value: roomType,
                        decoration: InputDecoration(
                          labelText: "Room Class Configuration",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: "single", child: Text("Single")),
                          DropdownMenuItem(value: "double", child: Text("Double")),
                          DropdownMenuItem(value: "suite", child: Text("Suite")),
                          DropdownMenuItem(value: "family", child: Text("Family")),
                          DropdownMenuItem(value: "deluxe", child: Text("Deluxe")),
                        ],
                        onChanged: (v) => setState(() => roomType = v!),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Text(
                          "Room Utilities & Amenities",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      
                      SwitchListTile(
                        title: const Text("Wireless WiFi Connectivity"),
                        value: hasWifi,
                        activeColor: AppColors.mangoOrange,
                        onChanged: (v) => setState(() => hasWifi = v),
                      ),
                      SwitchListTile(
                        title: const Text("Television Unit (TV)"),
                        value: hasTv,
                        activeColor: AppColors.mangoOrange,
                        onChanged: (v) => setState(() => hasTv = v),
                      ),
                      SwitchListTile(
                        title: const Text("Air Conditioning (AC)"),
                        value: hasAc,
                        activeColor: AppColors.mangoOrange,
                        onChanged: (v) => setState(() => hasAc = v),
                      ),
                      SwitchListTile(
                        title: const Text("Complimentary Breakfast Staging Included"),
                        value: hasBreakfast,
                        activeColor: AppColors.mangoOrange,
                        onChanged: (v) => setState(() => hasBreakfast = v),
                      ),
                      SwitchListTile(
                        title: const Text("Active Listing Room Status (Available)"),
                        value: isAvailable,
                        activeColor: AppColors.mangoOrange,
                        onChanged: (v) => setState(() => isAvailable = v),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leafGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Add Room Unit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          const SliverToBoxAdapter(child: WebFooter()),
        ],
      ),
    );
  }
}