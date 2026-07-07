import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/room_model.dart';
import '../../providers/api_provider.dart';

import '../../widgets/web_footer.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/app_scaffold.dart';

class EditRoomScreen extends ConsumerStatefulWidget {
  final Room room;

  const EditRoomScreen({
    super.key,
    required this.room,
  });

  @override
  ConsumerState<EditRoomScreen> createState() =>
      _EditRoomScreenState();
}

class _EditRoomScreenState
    extends ConsumerState<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController roomNumber;
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController price;
  late final TextEditingController capacity;

  String roomType = "single";

  bool hasWifi = false;
  bool hasTv = false;
  bool hasAc = false;
  bool hasBreakfast = false;
  bool isAvailable = true;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    final room = widget.room;

    roomNumber = TextEditingController(
      text: room.roomNumber,
    );

    title = TextEditingController(
      text: room.title,
    );

    description = TextEditingController(
      text: room.description,
    );

    price = TextEditingController(
      text: room.pricePerNight.toString(),
    );

    capacity = TextEditingController(
      text: room.capacity.toString(),
    );

    roomType = room.roomType;

    hasWifi = room.hasWifi;
    hasTv = room.hasTv;
    hasAc = room.hasAc;
    hasBreakfast = room.hasBreakfast;
    isAvailable = room.isAvailable;
  }

  @override
  void dispose() {
    roomNumber.dispose();
    title.dispose();
    description.dispose();
    price.dispose();
    capacity.dispose();
    super.dispose();
  }

  Future<void> updateRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      await api.patch(
        "rooms/${widget.room.id}/",
        data: {
          "lodge": widget.room.lodge,
          "room_type": roomType,
          "room_number": roomNumber.text,
          "title": title.text,
          "description": description.text,
          "price_per_night":
              double.parse(price.text),
          "capacity":
              int.parse(capacity.text),
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
          const SnackBar(
            content:
                Text("Room updated successfully"),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("UPDATE ROOM ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update room: $e"),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Edit Room'),),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [

            /// ROOM NUMBER
            AppTextField(
              label: "Room Number",
              controller: roomNumber,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            /// TITLE
            AppTextField(
              label: "Room Title",
              controller: title,
            ),

            const SizedBox(height: AppSpacing.md),

            /// DESCRIPTION
            AppTextField(
              label: "Description",
              controller: description,
              type: TextFieldType.multiline,
              maxLines: 4,
            ),

            const SizedBox(height: AppSpacing.md),

            /// PRICE
            AppTextField(
              label: "Price Per Night",
              controller: price,
              type: TextFieldType.number,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            /// CAPACITY
            AppTextField(
              label: "Capacity",
              controller: capacity,
              type: TextFieldType.number,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ROOM TYPE
            DropdownButtonFormField<String>(
              value: roomType,
              decoration: InputDecoration(
                labelText: "Room Type",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "single",
                  child: Text("Single"),
                ),
                DropdownMenuItem(
                  value: "double",
                  child: Text("Double"),
                ),
                DropdownMenuItem(
                  value: "suite",
                  child: Text("Suite"),
                ),
                DropdownMenuItem(
                  value: "family",
                  child: Text("Family"),
                ),
                DropdownMenuItem(
                  value: "deluxe",
                  child: Text("Deluxe"),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  roomType = v!;
                });
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            /// FEATURES
            Text(
              "Room Features",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            buildSwitchTile(
              title: "WiFi",
              value: hasWifi,
              onChanged: (v) {
                setState(() => hasWifi = v);
              },
            ),

            buildSwitchTile(
              title: "TV",
              value: hasTv,
              onChanged: (v) {
                setState(() => hasTv = v);
              },
            ),

            buildSwitchTile(
              title: "Air Conditioning",
              value: hasAc,
              onChanged: (v) {
                setState(() => hasAc = v);
              },
            ),

            buildSwitchTile(
              title: "Breakfast Included",
              value: hasBreakfast,
              onChanged: (v) {
                setState(() => hasBreakfast = v);
              },
            ),

            buildSwitchTile(
              title: "Room Available",
              value: isAvailable,
              onChanged: (v) {
                setState(() => isAvailable = v);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            /// UPDATE BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : updateRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.mangoOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.surface,
                      )
                    : Text(
                        "Update Room",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}