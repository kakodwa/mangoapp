import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';

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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              /// ROOM NUMBER (IMPORTANT UNIQUE FIELD)
              TextFormField(
                controller: roomNumber,
                decoration: const InputDecoration(labelText: "Room Number"),
                validator: (v) =>
                    v!.isEmpty ? "Room number required" : null,
              ),

              const SizedBox(height: 10),

              /// TITLE
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              const SizedBox(height: 10),

              /// DESCRIPTION
              TextFormField(
                controller: description,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              /// PRICE
              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Price Per Night"),
              ),

              const SizedBox(height: 10),

              /// CAPACITY
              TextFormField(
                controller: capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Capacity"),
              ),

              const SizedBox(height: 10),

              /// TOTAL ROOMS (NEW FIELD)
              TextFormField(
                controller: totalRooms,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Total Rooms"),
              ),

              const SizedBox(height: 15),

              /// ROOM TYPE
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

              const SizedBox(height: 20),

              /// FEATURES
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

              const SizedBox(height: 25),

              /// SUBMIT
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mangoOrange,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Room"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}