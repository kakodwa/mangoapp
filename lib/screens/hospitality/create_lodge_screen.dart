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
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/main_app_bar.dart';

import '../../widgets/image_crop_picker.dart'; // ✅ NEW IMPORT

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

  final types = ['hotel', 'lodge', 'guest_house', 'apartment', 'villa', 'resort'];

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

  // ================= GPS =================
  Future<void> getLocation() async {
    setState(() => isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppToast.error(context, 'Enable location services');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppToast.error(context, 'Location permission denied');
          return;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = double.parse(pos.latitude.toStringAsFixed(6));
        longitude = double.parse(pos.longitude.toStringAsFixed(6));
      });

      AppToast.success(context, 'Location captured successfully');
    } catch (e) {
      AppToast.error(context, 'Failed to get location');
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  // ================= SUBMIT =================
  Future<void> submitLodge() async {
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

      // images (cropped already)
      for (final img in images) {
        formData.files.add(
          MapEntry(
            "images",
            kIsWeb
                ? await MultipartFile.fromFile(img.path)
                : await MultipartFile.fromFile(img.path),
          ),
        );
      }

      await api.postMultipart("lodges/", formData);

      if (mounted) {
        AppToast.success(context, "Lodge created successfully");
        Navigator.pop(context);
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
      appBar: const MainAppBar(title: "Create Lodge"),

      body: ListView(
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
            onChanged: (v) => setState(() => selectedDistrict = v.toString()),
            decoration: const InputDecoration(labelText: "District"),
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGettingLocation ? null : getLocation,
              icon: isGettingLocation
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                isGettingLocation
                    ? 'Getting GPS...'
                    : 'Get GPS Location',
              ),
            ),
          ),

          if (latitude != null) Text("Lat: $latitude"),
          if (longitude != null) Text("Lng: $longitude"),

          const SizedBox(height: AppSpacing.lg),

          Text(
            "Amenities",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          amenitiesAsync.when(
            data: (amenities) => Wrap(
              spacing: 8,
              children: amenities.map((Amenity a) {
                final selected = images.any((e) => e.name == a.id.toString());

                return FilterChip(
                  label: Text(a.name),
                  selected: selected,
                  onSelected: (_) {},
                );
              }).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text("Failed to load amenities"),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ================= CROPPED IMAGE PICKER =================
          ImageCropPicker(
            maxImages: 6,
            cropType: CropShapeType.rectangle, // ✅ IMPORTANT FOR LODGES
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
    );
  }
}