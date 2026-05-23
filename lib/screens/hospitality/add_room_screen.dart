import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';

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
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("ADD ROOM ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add room")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Room"),
        backgroundColor: AppColors.mangoOrange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            AppTextField(
              label: "Room Number",
              controller: roomNumber,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Title",
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
              label: "Price Per Night",
              controller: price,
              type: TextFieldType.number,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Capacity",
              controller: capacity,
              type: TextFieldType.number,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Total Rooms",
              controller: totalRooms,
              type: TextFieldType.number,
            ),

            const SizedBox(height: AppSpacing.lg),

            DropdownButtonFormField<String>(
              value: roomType,
              decoration: const InputDecoration(labelText: "Room Type"),
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

            SwitchListTile(
              title: const Text("WiFi"),
              value: hasWifi,
              onChanged: (v) => setState(() => hasWifi = v),
            ),
            SwitchListTile(
              title: const Text("TV"),
              value: hasTv,
              onChanged: (v) => setState(() => hasTv = v),
            ),
            SwitchListTile(
              title: const Text("AC"),
              value: hasAc,
              onChanged: (v) => setState(() => hasAc = v),
            ),
            SwitchListTile(
              title: const Text("Breakfast"),
              value: hasBreakfast,
              onChanged: (v) => setState(() => hasBreakfast = v),
            ),
            SwitchListTile(
              title: const Text("Available"),
              value: isAvailable,
              onChanged: (v) => setState(() => isAvailable = v),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mangoOrange,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)
                    : const Text("Add Room"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}