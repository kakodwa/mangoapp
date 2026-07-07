// lib/screens/hospitality/create_lodge_screen.dart

import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../widgets/web_footer.dart';
import '../../providers/api_provider.dart';
import '../../providers/amenities_provider.dart';
import '../../models/amenity_model.dart';
import '../main_tabs_screen.dart'; // Core structural coordinator layout

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/image_crop_picker.dart';

class CreateLodgeScreen extends ConsumerStatefulWidget {
  const CreateLodgeScreen({super.key});

  @override
  ConsumerState<CreateLodgeScreen> createState() => _CreateLodgeScreenState();
}

class _CreateLodgeScreenState extends ConsumerState<CreateLodgeScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String selectedType = "hotel";
  String selectedDistrict = "Lilongwe";

  final types = [
    'hotel',
    'lodge',
    'guest_house',
    'apartment',
    'villa',
    'resort'
  ];

  final malawiDistricts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba",
  ];

  bool isLoading = false;
  bool isGettingLocation = false;

  double? latitude;
  double? longitude;

  List<XFile> images = [];
  List<int> selectedAmenities = [];

  // ================= GPS =================
  Future<void> getLocation() async {
    setState(() => isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = double.parse(pos.latitude.toStringAsFixed(6));
        longitude = double.parse(pos.longitude.toStringAsFixed(6));
      });
    } catch (e) {
      debugPrint("Failed to capture location coordinates: $e");
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  // ================= SUBMIT =================
  Future<void> submitLodge() async {
    debugPrint("🚀 SUBMIT TRIGGERED");

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (phoneController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone and Address are required")),
      );
      return;
    }

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

      // AMENITIES
      for (final id in selectedAmenities) {
        formData.fields.add(MapEntry("amenities", id.toString()));
      }

      // IMAGES
      for (final img in images) {
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

      await api.postMultipart("lodges/", formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lodge created successfully")),
        );
        
        // Return focus index cleanly to the master dashboard panel screen inside the parent tabs view
        MainTabsScreen.of(context)?.setSelectedIndex(30);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final amenitiesAsync = ref.watch(amenitiesProvider);
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
                        label: "Lodge Name",
                        controller: nameController,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Description",
                        controller: descriptionController,
                        type: TextFieldType.multiline,
                        maxLines: 3,
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
                        label: "Phone",
                        controller: phoneController,
                        isRequired: true,
                        type: TextFieldType.phone,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Email",
                        controller: emailController,
                        type: TextFieldType.email,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: types
                            .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                            .toList(),
                        onChanged: (v) => setState(() => selectedType = v!),
                        decoration: InputDecoration(
                          labelText: "Property Category Type",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      DropdownButtonFormField<String>(
                        value: selectedDistrict,
                        items: malawiDistricts
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedDistrict = v!),
                        decoration: InputDecoration(
                          labelText: "Malawi Location District",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      ElevatedButton.icon(
                        onPressed: isGettingLocation ? null : getLocation,
                        icon: isGettingLocation 
                            ? const SizedBox(
                                width: 16, 
                                height: 16, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                              )
                            : const Icon(Icons.my_location),
                        label: Text(isGettingLocation ? "Pinpointing Location..." : "Fetch Current GPS Coordinates"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mangoOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (latitude != null && longitude != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.gpp_good, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Coordinates set: [$latitude, $longitude]",
                                style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),

                      const Text(
                        "Available On-Site Amenities",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Fixed Async Consumer block matching correct type parameters
                      amenitiesAsync.when(
                        data: (amenities) {
                          if (amenities.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('No parameters registered.', style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: amenities.map<Widget>((Amenity a) {
                              final selected = selectedAmenities.contains(a.id);
                              return FilterChip(
                                label: Text(a.name),
                                selected: selected,
                                selectedColor: AppColors.mangoOrange.withOpacity(0.2),
                                checkmarkColor: AppColors.mangoOrange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),
                        ),
                        error: (err, __) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.signal_wifi_connected_no_internet_4, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Failed to load utilities choices. Pull down/reload view later. ($err)",
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      ImageCropPicker(
                        maxImages: 6,
                        cropType: CropShapeType.rectangle,
                        initialImages: images,
                        onChanged: (imgs) {
                          setState(() => images = imgs);
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitLodge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leafGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Publish Listing Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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