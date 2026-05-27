import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/lodge_model.dart';
import '../../models/amenity_model.dart';

import '../../providers/api_provider.dart';
import '../../providers/amenities_provider.dart';
import '../../utils/app_toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../widgets/main_app_bar.dart';

import '../../widgets/image_crop_picker.dart'; // ✅ NEW

class EditLodgeScreen extends ConsumerStatefulWidget {
  final Lodge lodge;

  const EditLodgeScreen({
    super.key,
    required this.lodge,
  });

  @override
  ConsumerState<EditLodgeScreen> createState() =>
      _EditLodgeScreenState();
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

    nameController = TextEditingController(text: lodge.name);
    descriptionController = TextEditingController(text: lodge.description);
    cityController = TextEditingController(text: lodge.city);
    addressController = TextEditingController(text: lodge.address);
    phoneController = TextEditingController(text: lodge.phoneNumber);
    emailController = TextEditingController(text: lodge.email);

    selectedType = lodge.lodgeType;
    selectedDistrict = lodge.district;

    latitude = lodge.latitude;
    longitude = lodge.longitude;

    existingImages = List<String>.from(lodge.images);
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
        latitude = double.parse(pos.latitude.toStringAsFixed(6));
        longitude = double.parse(pos.longitude.toStringAsFixed(6));
      });

      AppToast.success(context, "Location updated");
    } catch (e) {
      AppToast.error(context, "Failed to get location");
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  // ================= IMAGE PICKER (CROPPER) =================
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
    setState(() {
      existingImages.removeAt(index);
    });
  }

  void removeNew(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  // ================= UPDATE =================
  Future<void> updateLodge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final api = ref.read(apiClientProvider);

      final formData = FormData.fromMap({
        "name": nameController.text,
        "description": descriptionController.text,
        "lodge_type": selectedType,
        "city": cityController.text,
        "district": selectedDistrict,
        "address": addressController.text,
        "phone_number": phoneController.text,
        "email": emailController.text,
        "latitude": latitude?.toStringAsFixed(6) ?? "",
        "longitude": longitude?.toStringAsFixed(6) ?? "",
      });

      // NEW IMAGES ONLY
      for (final img in newImages) {
        formData.files.add(
          MapEntry(
            "images",
            await MultipartFile.fromFile(img.path),
          ),
        );
      }

      await api.patchMultipart(
        "lodges/${widget.lodge.id}/",
        formData,
      );

      if (mounted) {
        AppToast.success(context, "Lodge updated");
        Navigator.pop(context, true);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    }

    setState(() => isLoading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final amenitiesAsync = ref.watch(amenitiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: "Edit Lodge"),

      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
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
            onChanged: (v) =>
                setState(() => selectedDistrict = v.toString()),
            decoration: const InputDecoration(labelText: "District"),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: isGettingLocation ? null : getLocation,
            icon: isGettingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              isGettingLocation ? "Getting GPS..." : "Update Location",
            ),
          ),

          const SizedBox(height: 20),

          // ================= AMENITIES =================
          amenitiesAsync.when(
            data: (amenities) => Wrap(
              spacing: 8,
              children: amenities.map((Amenity a) {
                final selected =
                    selectedAmenities.contains(a.id);

                return FilterChip(
                  label: Text(a.name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v
                          ? selectedAmenities.add(a.id)
                          : selectedAmenities.remove(a.id);
                    });
                  },
                );
              }).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text("Failed to load"),
          ),

          const SizedBox(height: 20),

          // ================= IMAGES =================
          Text(
            "Images",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [

              // EXISTING
              ...existingImages.asMap().entries.map((e) {
                final i = e.key;
                final img = e.value;

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        img,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => removeExisting(i),
                      ),
                    )
                  ],
                );
              }),

              // NEW
              ...newImages.asMap().entries.map((e) {
                final i = e.key;

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(newImages[i].path),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => removeNew(i),
                      ),
                    )
                  ],
                );
              }),

              // ADD BUTTON
              GestureDetector(
                onTap: pickImages,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
    );
  }
}