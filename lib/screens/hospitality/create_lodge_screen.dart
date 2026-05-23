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

  final picker = ImagePicker();

  List<XFile> images = [];
  List<Uint8List> webImages = [];

  bool isLoading = false;
  bool isGettingLocation = false;

  double? latitude;
  double? longitude;

  List<int> selectedAmenities = [];

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      if (kIsWeb) {
        webImages = await Future.wait(picked.map((e) => e.readAsBytes()));
      }

      setState(() => images = picked);
    }
  }

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
        for (final id in selectedAmenities) "amenities": id.toString(),
      });

      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          formData.files.add(
            MapEntry(
              "images",
              kIsWeb
                  ? MultipartFile.fromBytes(webImages[i], filename: images[i].name)
                  : await MultipartFile.fromFile(images[i].path),
            ),
          );
        }
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
        title: Text("Create Lodge"),
        backgroundColor: AppColors.mangoOrange,
      ),

      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [

          /// ================= BASIC =================
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

          ElevatedButton.icon(
            onPressed: getLocation,
            icon: Icon(Icons.my_location),
            label: Text("Get GPS Location"),
          ),

          if (latitude != null) Text("Lat: $latitude"),
          if (longitude != null) Text("Lng: $longitude"),

          const SizedBox(height: AppSpacing.lg),

          Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold)),

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
                      v
                          ? selectedAmenities.add(a.id)
                          : selectedAmenities.remove(a.id);
                    });
                  },
                );
              }).toList(),
            ),
            loading: () => CircularProgressIndicator(),
            error: (_, __) => Text("Failed to load amenities"),
          ),

          const SizedBox(height: AppSpacing.lg),

          Wrap(
            spacing: 10,
            children: [
              ...images.asMap().entries.map((e) {
                final i = e.key;

                return Stack(
                  children: [
                    kIsWeb
                        ? Image.memory(webImages[i], width: 90, height: 90)
                        : Image.file(File(images[i].path),
                            width: 90, height: 90),

                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => images.removeAt(i)),
                        child: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : submitLodge,
              child: isLoading
                  ? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)
                  : Text("Create Lodge"),
            ),
          ),
        ],
      ),
    );
  }
}