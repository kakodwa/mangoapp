import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/property_model.dart';
import '../../providers/properties_provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../utils/app_toast.dart';
import '../../widgets/main_app_bar.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() =>
      _AddPropertyScreenState();
}

class _AddPropertyScreenState
    extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // =========================
  // CONTROLLERS
  // =========================
  final titleController = TextEditingController(); // ✅ RESTORED
  final descriptionController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final sizeController = TextEditingController();
  final priceController = TextEditingController();


  bool isLoading = false;

  String propertyType = 'house';
  String listingPurpose = 'sale';
  String propertyStatus = 'available';

  final ImagePicker picker = ImagePicker();
  List<XFile> images = [];

  // =========================
  // MALAWI DISTRICTS
  // =========================
  final List<String> malawiDistricts = [
    'Blantyre','Lilongwe','Mzuzu','Zomba','Mangochi','Salima',
    'Kasungu','Mchinji','Dedza','Nkhotakota','Nkhatabay','Karonga',
    'Chikwawa','Nsanje','Balaka','Neno','Phalombe','Mulanje',
    'Thyolo','Chiradzulu','Ntcheu','Rumphi','Likoma'
  ];

  // =========================
  // PICK IMAGES
  // =========================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 4 ? picked.sublist(0, 4) : picked;
      });
    }
  }

  // =========================
  // GPS
  // =========================
  Future<void> getGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppToast.error(context, "Location services disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        AppToast.error(context, "Permission denied permanently");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });

      AppToast.success(context, "GPS captured successfully");
    } catch (e) {
      AppToast.error(context, e.toString());
    }
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final property = Property(
        id: 0,
        title: titleController.text, // ✅ FIXED
        slug: '',
        description: descriptionController.text,
        propertyType: propertyType,
        listingPurpose: listingPurpose,
        status: propertyStatus,
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
        address: addressController.text,
        city: cityController.text,
        district: districtController.text,
        bedrooms: int.tryParse(bedroomsController.text),
        bathrooms: int.tryParse(bathroomsController.text),
        sizeSqm: double.tryParse(sizeController.text) ?? 0,
        price: double.tryParse(priceController.text) ?? 0,
        currency: 'MWK',
        isPubliclyVisible: true,
        unlockFee: 0,
        viewCount: 0,
        images: const [],
        ownerId: 0,
        ownerName: '',
        isUnlocked: false,
        createdAt: DateTime.now(),
      );

      await ref
          .read(propertyActionsProvider)
          .createProperty(property, images);

      ref.invalidate(propertiesProvider);

      if (mounted) {
        AppToast.success(context, 'Property posted successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =========================
  // INPUT FIELD
  // =========================
  Widget inputField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const MainAppBar(title: 'Post Property'),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            const AppInfoBox(
              icon: Icons.info_outline,
              message:
                  'Upload images. GPS will be used for navigation after property unlock.',
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // BASIC INFO (TITLE FIXED HERE)
            // =========================
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  inputField(titleController, 'Property Title'), // ✅ RESTORED
                  inputField(descriptionController, 'Description', maxLines: 4),

                  DropdownButtonFormField<String>(
                    value: propertyType,
                    items: const [
                      DropdownMenuItem(value: 'house', child: Text('House')),
                      DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                      DropdownMenuItem(value: 'land', child: Text('Land')),
                      DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                    ],
                    onChanged: (v) => setState(() => propertyType = v!),
                    decoration: const InputDecoration(labelText: 'Property Type'),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
  value: listingPurpose,
  items: const [
    DropdownMenuItem(value: 'sale', child: Text('For Sale')),
    DropdownMenuItem(value: 'rent', child: Text('For Rent')),
  ],
  onChanged: (v) => setState(() => listingPurpose = v!),
  decoration: const InputDecoration(labelText: 'Listing Purpose'),
),
                    const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: propertyStatus,
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'sold', child: Text('Sold')),
                      DropdownMenuItem(value: 'rented', child: Text('Rented')),
                    ],
                    onChanged: (v) => setState(() => propertyStatus = v!),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // LOCATION
            // =========================
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "📍 GPS used for navigation after unlock",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  inputField(addressController, 'Address'),
                  inputField(cityController, 'City'),

                  DropdownButtonFormField<String>(
                    value: districtController.text.isEmpty
                        ? null
                        : districtController.text,
                    items: malawiDistricts
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => districtController.text = v!),
                    decoration: const InputDecoration(labelText: 'District'),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  ElevatedButton.icon(
                    onPressed: getGPS,
                    icon: const Icon(Icons.my_location),
                    label: const Text("Get GPS Location"),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(child: inputField(latitudeController, 'Latitude')),
                      const SizedBox(width: 10),
                      Expanded(child: inputField(longitudeController, 'Longitude')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // DETAILS
            // =========================
            AppCard(
              child: Column(
                children: [
                  inputField(bedroomsController, 'Bedrooms', required: false),
                  inputField(bathroomsController, 'Bathrooms', required: false),
                  inputField(sizeController, 'Size (sqm)'),
                  inputField(priceController, 'Price'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // IMAGES
            // =========================
            AppCard(
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    children: [
                      ...images.map((img) => Image.network(img.path, width: 80)),
                      if (images.length < 4)
                        IconButton(
                          icon: const Icon(Icons.add_a_photo),
                          onPressed: pickImages,
                        )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              text: isLoading ? "Saving..." : "Post Property",
              loading: isLoading,
              onPressed: isLoading ? null : submit,
            ),
          ],
        ),
      ),
    );
  }
}