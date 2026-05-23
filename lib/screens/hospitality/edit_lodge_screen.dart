import 'dart:io';
import 'dart:typed_data';

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

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';

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

class _EditLodgeScreenState
    extends ConsumerState<EditLodgeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController cityController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  final picker = ImagePicker();

  List<XFile> newImages = [];
  List<Uint8List> webImages = [];

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
    "Balaka",
    "Blantyre",
    "Chikwawa",
    "Chiradzulu",
    "Chitipa",
    "Dedza",
    "Dowa",
    "Karonga",
    "Kasungu",
    "Likoma",
    "Lilongwe",
    "Machinga",
    "Mangochi",
    "Mchinji",
    "Mulanje",
    "Mwanza",
    "Mzimba",
    "Neno",
    "Nkhata Bay",
    "Nkhotakota",
    "Nsanje",
    "Ntcheu",
    "Ntchisi",
    "Phalombe",
    "Rumphi",
    "Salima",
    "Thyolo",
    "Zomba",
  ];

  @override
  void initState() {
    super.initState();

    final lodge = widget.lodge;

    nameController =
        TextEditingController(text: lodge.name);

    descriptionController =
        TextEditingController(text: lodge.description);

    cityController =
        TextEditingController(text: lodge.city);

    addressController =
        TextEditingController(text: lodge.address);

    phoneController =
        TextEditingController(text: lodge.phoneNumber);

    emailController =
        TextEditingController(text: lodge.email);

    selectedType = lodge.lodgeType;
    selectedDistrict = lodge.district;

    latitude = lodge.latitude;
    longitude = lodge.longitude;

    existingImages = List<String>.from(lodge.images);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      if (kIsWeb) {
        webImages = await Future.wait(
          picked.map((e) => e.readAsBytes()),
        );
      }

      setState(() {
        newImages.addAll(picked);
      });
    }
  }

  Future<void> getLocation() async {
    setState(() => isGettingLocation = true);

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      final pos =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = double.parse(
          pos.latitude.toStringAsFixed(6),
        );

        longitude = double.parse(
          pos.longitude.toStringAsFixed(6),
        );
      });
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

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
        "latitude":
            latitude?.toStringAsFixed(6) ?? "",
        "longitude":
            longitude?.toStringAsFixed(6) ?? "",
      });

      /// NEW IMAGES
      if (newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          formData.files.add(
            MapEntry(
              "images",
              kIsWeb
                  ? MultipartFile.fromBytes(
                      webImages[i],
                      filename: newImages[i].name,
                    )
                  : await MultipartFile.fromFile(
                      newImages[i].path,
                    ),
            ),
          );
        }
      }

      await api.patchMultipart(
        "lodges/${widget.lodge.id}/",
        formData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Lodge updated successfully"),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildImagePreview() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        /// EXISTING IMAGES
        ...existingImages.asMap().entries.map((e) {
          final index = e.key;
          final image = e.value;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      existingImages.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        /// NEW IMAGES
        ...newImages.asMap().entries.map((e) {
          final i = e.key;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(
                        webImages[i],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(newImages[i].path),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
              ),

              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      newImages.removeAt(i);

                      if (kIsWeb) {
                        webImages.removeAt(i);
                      }
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        /// ADD BUTTON
        GestureDetector(
          onTap: pickImages,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_a_photo),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final amenitiesAsync =
        ref.watch(amenitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Lodge"),
        backgroundColor: AppColors.mangoOrange,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            /// BASIC INFO
            AppTextField(
              label: "Lodge Name",
              controller: nameController,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Description",
              controller: descriptionController,
              type: TextFieldType.multiline,
              maxLines: 4,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "City",
              controller: cityController,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Address",
              controller: addressController,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Phone Number",
              controller: phoneController,
              type: TextFieldType.phone,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: "Email",
              controller: emailController,
              type: TextFieldType.email,
            ),

            const SizedBox(height: AppSpacing.lg),

            /// TYPE
            DropdownButtonFormField(
              value: selectedType,
              decoration: InputDecoration(
                labelText: "Lodge Type",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              items: types.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  selectedType = v.toString();
                });
              },
            ),

            const SizedBox(height: AppSpacing.md),

            /// DISTRICT
            DropdownButtonFormField(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: "District",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              items: malawiDistricts.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  selectedDistrict = v.toString();
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            /// LOCATION
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    isGettingLocation
                        ? null
                        : getLocation,
                icon: const Icon(Icons.my_location),
                label: Text(
                  isGettingLocation
                      ? "Getting location..."
                      : "Update GPS Location",
                ),
              ),
            ),

            if (latitude != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text("Latitude: $latitude"),
            ],

            if (longitude != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text("Longitude: $longitude"),
            ],

            const SizedBox(height: AppSpacing.xl),

            /// AMENITIES
            const Text(
              "Amenities",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            amenitiesAsync.when(
              data: (amenities) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                              : selectedAmenities
                                  .remove(a.id);
                        });
                      },
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const CircularProgressIndicator(),
              error: (_, __) =>
                  const Text("Failed to load amenities"),
            ),

            const SizedBox(height: AppSpacing.xl),

            /// IMAGES
            const Text(
              "Lodge Images",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            buildImagePreview(),

            const SizedBox(height: AppSpacing.xl),

            /// UPDATE BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : updateLodge,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.mangoOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.surface,
                      )
                    : const Text(
                        "Update Lodge",
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