// lib/screens/hospitality/edit_lodge_screen.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/lodge_model.dart';
import '../../models/amenity_model.dart';
import '../../widgets/web_footer.dart';
import '../../providers/api_provider.dart';
import '../../providers/amenities_provider.dart';
import '../main_tabs_screen.dart'; // Core structural coordinator layout
import '../../utils/app_toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_typography.dart';

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

      // AMENITIES
      for (final id in selectedAmenities) {
        formData.fields.add(MapEntry("amenities", id.toString()));
      }

      // EXISTING IMAGES PRESERVATION SYNCHRONIZATION
      for (final url in existingImages) {
        formData.fields.add(MapEntry("existing_images", url));
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
        
        // Return focus index cleanly to the master dashboard panel screen inside the parent tabs view
        MainTabsScreen.of(context)?.setSelectedIndex(30);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final amenitiesAsync = ref.watch(amenitiesProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    // Standalone Scaffold structures and explicit top AppBar elements are removed 
    // to match the uniform embedding layout configuration bounds of the parent wrapper.
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
                      AppTextField(label: "Lodge Name", controller: nameController, isRequired: true),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: "Description",
                        controller: descriptionController,
                        type: TextFieldType.multiline,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(label: "City", controller: cityController),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(label: "Address", controller: addressController, isRequired: true),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(label: "Phone", controller: phoneController, isRequired: true, type: TextFieldType.phone),
                      const SizedBox(height: AppSpacing.md),

                      AppTextField(label: "Email", controller: emailController, type: TextFieldType.email),
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
                        label: Text(isGettingLocation ? "Pinpointing Location..." : "Update GPS Coordinates"),
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
                                "Coordinates verified: [$latitude, $longitude]",
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

                      // Refactored layout casting wrapper fix
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
                                  "Failed to load utilities choices. ($err)",
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      const Text("Gallery Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: AppSpacing.sm),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // EXISTING IMAGES PROCESSED FROM NETWORK CDN
                          ...existingImages.asMap().entries.map((e) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    e.value,
                                    width: 95,
                                    height: 95,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                      onPressed: () => removeExisting(e.key),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),

                          // NEW LOCAL IMAGES FOR STAGED MULTIPART MULTIPHASE UPLOADS
                          ...newImages.asMap().entries.map((e) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(e.value.path),
                                    width: 95,
                                    height: 95,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                      onPressed: () => removeNew(e.key),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),

                          GestureDetector(
                            onTap: pickImages,
                            child: Container(
                              width: 95,
                              height: 95,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: Icon(Icons.add_photo_alternate, color: Colors.grey.shade600, size: 28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : updateLodge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leafGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Save Modifications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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