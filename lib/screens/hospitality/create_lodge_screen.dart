import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/amenities_provider.dart';
import '../../models/amenity_model.dart';
import '../../theme/app_colors.dart';

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
    'resort',
  ];

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

  /// ✅ FIXED: amenities must be INT PK list
  List<int> selectedAmenities = [];

  // ================= IMAGES =================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      if (kIsWeb) {
        webImages.clear();
        for (var img in picked) {
          webImages.add(await img.readAsBytes());
        }
      }

      setState(() => images.addAll(picked));
    }
  }

  // ================= GPS (FIXED PRECISION) =================
  Future<void> getLocation() async {
    try {
      setState(() => isGettingLocation = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = double.parse(position.latitude.toStringAsFixed(6));
        longitude = double.parse(position.longitude.toStringAsFixed(6));
      });
    } catch (e) {
      debugPrint("GPS error: $e");
    }

    setState(() => isGettingLocation = false);
  }

  // ================= SUBMIT (FIXED SERIALIZER FORMAT) =================
  Future<void> submitLodge() async {
    if (!_formKey.currentState!.validate()) return;

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

      // ✅ TEXT FIELDS
      formData.fields.addAll([
        MapEntry("name", nameController.text),
        MapEntry("description", descriptionController.text),
        MapEntry("lodge_type", selectedType),
        MapEntry("city", cityController.text),
        MapEntry("district", selectedDistrict),
        MapEntry("address", addressController.text),
        MapEntry("phone_number", phoneController.text),
        MapEntry("email", emailController.text),

        // FIXED: GPS precision
        MapEntry("latitude", latitude?.toStringAsFixed(6) ?? ""),
        MapEntry("longitude", longitude?.toStringAsFixed(6) ?? ""),

        // FIXED: send as comma-separated PKs (Django expects pk list)
        for (final amenityId in selectedAmenities)
        MapEntry("amenities", amenityId.toString()),

      ]);

      // ================= IMAGES =================
      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          if (kIsWeb) {
            formData.files.add(
              MapEntry(
                "images",
                MultipartFile.fromBytes(
                  webImages[i],
                  filename: images[i].name,
                ),
              ),
            );
          } else {
            formData.files.add(
              MapEntry(
                "images",
                await MultipartFile.fromFile(
                  images[i].path,
                  filename: images[i].name,
                ),
              ),
            );
          }
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final amenitiesAsync = ref.watch(amenitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Lodge"),
        backgroundColor: AppColors.mangoOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Lodge Name"),
              ),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description"),
              ),

              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address *"),
              ),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone *"),
              ),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField(
                value: selectedType,
                items: types
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v.toString()),
                decoration: const InputDecoration(labelText: "Type"),
              ),

              DropdownButtonFormField(
                value: selectedDistrict,
                items: malawiDistricts
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedDistrict = v.toString()),
                decoration: const InputDecoration(labelText: "District"),
              ),

              const SizedBox(height: 20),

              const Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold)),

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
                error: (e, _) => const Text("Failed to load amenities"),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Get GPS"),
              ),

              if (latitude != null) Text("Lat: $latitude"),
              if (longitude != null) Text("Lng: $longitude"),

              const SizedBox(height: 20),

              Wrap(
                spacing: 10,
                children: [
                  ...images.map((img) => Stack(
                        children: [
                          kIsWeb
                              ? Image.memory(webImages[images.indexOf(img)], width: 90, height: 90)
                              : Image.network(img.path, width: 90, height: 90),

                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => images.remove(img)),
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          )
                        ],
                      )),

                  GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
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
      ),
    );
  }
}