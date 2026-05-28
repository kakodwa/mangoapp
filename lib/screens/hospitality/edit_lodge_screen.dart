import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/lodge_model.dart';
import '../../models/amenity_model.dart';

import '../../providers/api_provider.dart';
import '../../providers/amenities_provider.dart';
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../widgets/main_app_bar.dart';

class EditLodgeScreen extends ConsumerStatefulWidget {
  final Lodge lodge;

  const EditLodgeScreen({
    super.key,
    required this.lodge,
  });

  @override
  ConsumerState<EditLodgeScreen> createState() => _EditLodgeScreenState();
}

class _EditLodgeScreenState extends ConsumerState<EditLodgeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController cityController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  List<XFile> newImages = [];
  List<String> existingImages = [];

  bool isLoading = false;
  bool isGettingLocation = false;

  double? latitude;
  double? longitude;

  String selectedType = "hotel";
  String selectedDistrict = "Lilongwe";

  List<int> selectedAmenities = [];

  final types = [
    'hotel',
    'lodge',
    'guest_house',
    'apartment',
    'villa',
    'resort',
  ];

  final malawiDistricts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba",
  ];

  @override
  void initState() {
    super.initState();

    final lodge = widget.lodge;

    nameController = TextEditingController(text: lodge.name ?? "");
    descriptionController = TextEditingController(text: lodge.description ?? "");
    cityController = TextEditingController(text: lodge.city ?? "");
    addressController = TextEditingController(text: lodge.address ?? "");
    phoneController = TextEditingController(text: lodge.phoneNumber ?? "");
    emailController = TextEditingController(text: lodge.email ?? "");

    selectedType = lodge.lodgeType ?? "hotel";
    selectedDistrict = lodge.district ?? "Lilongwe";

    latitude = lodge.latitude;
    longitude = lodge.longitude;

    existingImages = List<String>.from(lodge.images ?? []);

    // ⚠️ IMPORTANT: DO NOT depend on lodge.amenities object
    // We initialize empty like Create screen
    selectedAmenities = [];
  }

  // ================= GPS =================
  Future<void> getLocation() async {
    setState(() => isGettingLocation = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        AppToast.error(context, "Enable GPS");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppToast.error(context, "Permission denied");
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });

      AppToast.success(context, "Location updated");
    } catch (e) {
      AppToast.error(context, "Failed to get location");
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  // ================= IMAGES =================
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        newImages.addAll(picked);
      });
    }
  }

  void removeExisting(int index) {
    setState(() => existingImages.removeAt(index));
  }

  void removeNew(int index) {
    setState(() => newImages.removeAt(index));
  }

  // ================= LOAD AMENITIES FROM API =================
  Future<void> loadAmenities() async {
    try {
      final api = ref.read(apiClientProvider);

      final res = await api.get(
        "lodges/${widget.lodge.id}/",
        fromJson: (json) => json,
      );

      final data = res["amenities"] ?? [];

      setState(() {
        selectedAmenities = List<int>.from(data);
      });
    } catch (_) {
      // keep empty if fails
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadAmenities();
  }

  // ================= UPDATE =================
  Future<void> updateLodge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final api = ref.read(apiClientProvider);

      final formData = FormData();

      // TEXT FIELDS
      formData.fields.addAll([
        MapEntry("name", nameController.text),
        MapEntry("description", descriptionController.text),
        MapEntry("lodge_type", selectedType),
        MapEntry("city", cityController.text),
        MapEntry("district", selectedDistrict),
        MapEntry("address", addressController.text),
        MapEntry("phone_number", phoneController.text),
        MapEntry("email", emailController.text),
        MapEntry("latitude", latitude?.toStringAsFixed(6) ?? ""),
        MapEntry("longitude", longitude?.toStringAsFixed(6) ?? ""),
      ]);

      // AMENITIES (SAME AS CREATE SCREEN)
      for (final id in selectedAmenities) {
        formData.fields.add(MapEntry("amenities", id.toString()));
      }

      // NEW IMAGES ONLY
      for (final img in newImages) {
        formData.files.add(
          MapEntry(
            "images",
            await MultipartFile.fromFile(
              img.path,
              filename: img.name,
            ),
          ),
        );
      }

      final response = await api.patchMultipart(
        "lodges/${widget.lodge.id}/",
        formData,
      );

      debugPrint("FULL UPDATE RESPONSE: $response");

      if (mounted) {
        AppToast.success(context, "Lodge updated successfully");
        Navigator.pop(context, true);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final amenitiesAsync = ref.watch(amenitiesProvider);

    return Scaffold(
      appBar: const MainAppBar(title: "Edit Lodge"),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            AppTextField(label: "Name", controller: nameController),
            const SizedBox(height: 12),

            AppTextField(
              label: "Description",
              controller: descriptionController,
              type: TextFieldType.multiline,
              maxLines: 4,
            ),

            const SizedBox(height: 12),

            AppTextField(label: "City", controller: cityController),
            const SizedBox(height: 12),

            AppTextField(label: "Address", controller: addressController),
            const SizedBox(height: 12),

            AppTextField(label: "Phone", controller: phoneController),
            const SizedBox(height: 12),

            AppTextField(label: "Email", controller: emailController),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedType,
              items: types
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedType = v.toString()),
              decoration: const InputDecoration(labelText: "Type"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: selectedDistrict,
              items: malawiDistricts
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedDistrict = v.toString()),
              decoration: const InputDecoration(labelText: "District"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: getLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Update Location"),
            ),

            const SizedBox(height: 20),

            // ================= AMENITIES =================
            amenitiesAsync.when(
              data: (amenities) => Wrap(
                spacing: 8,
                children: amenities.map((Amenity a) {
                  final selected = selectedAmenities.contains(a.id);

                  return FilterChip(
                    label: Text(a.name),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          selectedAmenities.add(a.id);
                        } else {
                          selectedAmenities.remove(a.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text("Failed to load amenities"),
            ),

            const SizedBox(height: 20),

            const Text("Images",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                // EXISTING IMAGES
                ...existingImages.asMap().entries.map((e) {
                  return Stack(
                    children: [
                      Image.network(
                        e.value,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => removeExisting(e.key),
                        ),
                      )
                    ],
                  );
                }),

                // NEW IMAGES
                ...newImages.asMap().entries.map((e) {
                  return Stack(
                    children: [
                      Image.file(
                        File(e.value.path),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => removeNew(e.key),
                        ),
                      )
                    ],
                  );
                }),

                GestureDetector(
                  onTap: pickImages,
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateLodge,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Lodge"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}