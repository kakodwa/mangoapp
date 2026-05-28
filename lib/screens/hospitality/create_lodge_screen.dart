import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/api_provider.dart';
import '../../providers/amenities_provider.dart';
import '../../models/amenity_model.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../widgets/image_crop_picker.dart';

class CreateLodgeScreen extends ConsumerStatefulWidget {
  const CreateLodgeScreen({super.key});

  @override
  ConsumerState<CreateLodgeScreen> createState() =>
      _CreateLodgeScreenState();
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
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  // ================= SUBMIT (FIXED CRASH HERE) =================
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
        Navigator.pop(context);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Lodge"),
        backgroundColor: AppColors.mangoOrange,
      ),

      // ✅ FIX: FORM WRAPPER (THIS WAS MISSING BEFORE)
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
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

            DropdownButtonFormField(
              value: selectedType,
              items: types
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedType = v.toString()),
              decoration: const InputDecoration(labelText: "Type"),
            ),

            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField(
              value: selectedDistrict,
              items: malawiDistricts
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => selectedDistrict = v.toString()),
              decoration: const InputDecoration(labelText: "District"),
            ),

            const SizedBox(height: AppSpacing.lg),

            ElevatedButton.icon(
              onPressed: getLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Get GPS Location"),
            ),

            if (latitude != null) Text("Lat: $latitude"),
            if (longitude != null) Text("Lng: $longitude"),

            const SizedBox(height: AppSpacing.lg),

            const Text(
              "Amenities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

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

            const SizedBox(height: AppSpacing.lg),

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
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Create Lodge"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}