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

<<<<<<< HEAD
import '../../theme/design_system/app_text_field.dart';
import '../../widgets/main_app_bar.dart';

import '../../utils/app_toast.dart';
=======
import '../../utils/app_toast.dart';
import '../../widgets/main_app_bar.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

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
<<<<<<< HEAD
  final titleController = TextEditingController();
=======
  final titleController = TextEditingController(); // ✅ RESTORED
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
=======

>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  bool isLoading = false;

  String propertyType = 'house';
  String listingPurpose = 'sale';
  String propertyStatus = 'available';

  final ImagePicker picker = ImagePicker();
<<<<<<< HEAD

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  List<XFile> images = [];

  // =========================
  // MALAWI DISTRICTS
  // =========================
  final List<String> malawiDistricts = [
<<<<<<< HEAD
    'Blantyre',
    'Lilongwe',
    'Mzuzu',
    'Zomba',
    'Mangochi',
    'Salima',
    'Kasungu',
    'Mchinji',
    'Dedza',
    'Nkhotakota',
    'Nkhatabay',
    'Karonga',
    'Chikwawa',
    'Nsanje',
    'Balaka',
    'Neno',
    'Phalombe',
    'Mulanje',
    'Thyolo',
    'Chiradzulu',
    'Ntcheu',
    'Rumphi',
    'Likoma'
=======
    'Blantyre','Lilongwe','Mzuzu','Zomba','Mangochi','Salima',
    'Kasungu','Mchinji','Dedza','Nkhotakota','Nkhatabay','Karonga',
    'Chikwawa','Nsanje','Balaka','Neno','Phalombe','Mulanje',
    'Thyolo','Chiradzulu','Ntcheu','Rumphi','Likoma'
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  ];

  // =========================
  // PICK IMAGES
  // =========================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
<<<<<<< HEAD

    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 6
            ? picked.sublist(0, 6)
            : picked;
=======
    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 4 ? picked.sublist(0, 4) : picked;
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      });
    }
  }

  // =========================
  // GPS
  // =========================
  Future<void> getGPS() async {
    try {
<<<<<<< HEAD
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        AppToast.error(
          context,
          "Location services disabled",
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.deniedForever) {
        AppToast.error(
          context,
          "Permission denied permanently",
        );
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
<<<<<<< HEAD
        latitudeController.text =
            position.latitude.toString();

        longitudeController.text =
            position.longitude.toString();
      });

      AppToast.success(
        context,
        "GPS captured successfully",
      );
=======
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });

      AppToast.success(context, "GPS captured successfully");
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    } catch (e) {
      AppToast.error(context, e.toString());
    }
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

<<<<<<< HEAD
    if (images.isEmpty) {
      AppToast.error(
        context,
        "Please select at least one image",
      );
      return;
    }

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    setState(() => isLoading = true);

    try {
      final property = Property(
        id: 0,
<<<<<<< HEAD
        title: titleController.text,
=======
        title: titleController.text, // ✅ FIXED
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        slug: '',
        description: descriptionController.text,
        propertyType: propertyType,
        listingPurpose: listingPurpose,
        status: propertyStatus,
<<<<<<< HEAD
        latitude:
            double.tryParse(latitudeController.text) ?? 0,
        longitude:
            double.tryParse(longitudeController.text) ?? 0,
        address: addressController.text,
        city: cityController.text,
        district: districtController.text,
        bedrooms:
            int.tryParse(bedroomsController.text),
        bathrooms:
            int.tryParse(bathroomsController.text),
        sizeSqm:
            double.tryParse(sizeController.text) ?? 0,
        price:
            double.tryParse(priceController.text) ?? 0,
=======
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
        address: addressController.text,
        city: cityController.text,
        district: districtController.text,
        bedrooms: int.tryParse(bedroomsController.text),
        bathrooms: int.tryParse(bathroomsController.text),
        sizeSqm: double.tryParse(sizeController.text) ?? 0,
        price: double.tryParse(priceController.text) ?? 0,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD
        AppToast.success(
          context,
          'Property posted successfully',
        );

=======
        AppToast.success(context, 'Property posted successfully');
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
<<<<<<< HEAD
      if (mounted) {
        setState(() => isLoading = false);
      }
=======
      if (mounted) setState(() => isLoading = false);
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    }
  }

  // =========================
<<<<<<< HEAD
  // APP TEXT FIELD
=======
  // INPUT FIELD
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  // =========================
  Widget inputField(
    TextEditingController controller,
    String label, {
<<<<<<< HEAD
    TextFieldType type = TextFieldType.text,
=======
    TextInputType type = TextInputType.text,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
<<<<<<< HEAD
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: AppTextField(
        label: label,
        controller: controller,
        type: type,
        maxLines: maxLines,
        isRequired: required,
        validator: (value) {
          if (!required) return null;

          if (value == null ||
              value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        },
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      ),
    );
  }

<<<<<<< HEAD
  // =========================
  // IMAGE PREVIEW
  // =========================
  Widget buildImagePreview(XFile image) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: 90,
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child:
                const CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),
              child: Image.memory(
                snapshot.data!,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    images.remove(image);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
<<<<<<< HEAD

      appBar: const MainAppBar(
        title: 'Post Property',
      ),
=======
      appBar: const MainAppBar(title: 'Post Property'),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

      body: Form(
        key: _formKey,
        child: ListView(
<<<<<<< HEAD
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
=======
          padding: const EdgeInsets.all(AppSpacing.md),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          children: [

            const AppInfoBox(
              icon: Icons.info_outline,
              message:
<<<<<<< HEAD
                  'Upload clear images. GPS will be used for navigation after property unlock.',
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            // =========================
            // BASIC INFO
            // =========================
            AppCard(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  inputField(
                    titleController,
                    'Property Title',
                  ),

                  inputField(
                    descriptionController,
                    'Description',
                    type: TextFieldType.multiline,
                    maxLines: 4,
                  ),

                  DropdownButtonFormField<String>(
                    value: propertyType,
                    decoration: InputDecoration(
                      labelText:
                          'Property Type',
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'house',
                        child: Text('House'),
                      ),
                      DropdownMenuItem(
                        value: 'apartment',
                        child: Text('Apartment'),
                      ),
                      DropdownMenuItem(
                        value: 'land',
                        child: Text('Land'),
                      ),
                      DropdownMenuItem(
                        value: 'commercial',
                        child: Text('Commercial'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        propertyType = v!;
                      });
                    },
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  DropdownButtonFormField<String>(
                    value: listingPurpose,
                    decoration: InputDecoration(
                      labelText:
                          'Listing Purpose',
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sale',
                        child: Text('For Sale'),
                      ),
                      DropdownMenuItem(
                        value: 'rent',
                        child: Text('For Rent'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        listingPurpose = v!;
                      });
                    },
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  DropdownButtonFormField<String>(
                    value: propertyStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'sold',
                        child: Text('Sold'),
                      ),
                      DropdownMenuItem(
                        value: 'rented',
                        child: Text('Rented'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        propertyStatus = v!;
                      });
                    },
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                  ),
                ],
              ),
            ),

<<<<<<< HEAD
            const SizedBox(
              height: AppSpacing.lg,
            ),
=======
            const SizedBox(height: AppSpacing.lg),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

            // =========================
            // LOCATION
            // =========================
            AppCard(
              child: Column(
<<<<<<< HEAD
                crossAxisAlignment:
                    CrossAxisAlignment.start,
=======
                crossAxisAlignment: CrossAxisAlignment.start,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                children: [

                  const Text(
                    'Location',
<<<<<<< HEAD
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
=======
                    style: TextStyle(fontWeight: FontWeight.bold),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "📍 GPS used for navigation after unlock",
<<<<<<< HEAD
                    style:
                        TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  inputField(
                    addressController,
                    'Address',
                  ),

                  inputField(
                    cityController,
                    'City',
                  ),

                  DropdownButtonFormField<String>(
                    value: districtController
                            .text
                            .isEmpty
                        ? null
                        : districtController.text,
                    decoration: InputDecoration(
                      labelText: 'District',
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items: malawiDistricts
                        .map(
                          (d) =>
                              DropdownMenuItem(
                            value: d,
                            child: Text(d),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        districtController
                            .text = v!;
                      });
                    },
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: getGPS,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors
                                .mangoOrange,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      icon:
                          const Icon(Icons.my_location),
                      label: const Text(
                        "Get GPS Location",
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: inputField(
                          latitudeController,
                          'Latitude',
                          type:
                              TextFieldType.number,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: inputField(
                          longitudeController,
                          'Longitude',
                          type:
                              TextFieldType.number,
                        ),
                      ),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                    ],
                  ),
                ],
              ),
            ),

<<<<<<< HEAD
            const SizedBox(
              height: AppSpacing.lg,
            ),
=======
            const SizedBox(height: AppSpacing.lg),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

            // =========================
            // DETAILS
            // =========================
            AppCard(
              child: Column(
<<<<<<< HEAD
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Property Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: inputField(
                          bedroomsController,
                          'Bedrooms',
                          type:
                              TextFieldType.number,
                          required: false,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: inputField(
                          bathroomsController,
                          'Bathrooms',
                          type:
                              TextFieldType.number,
                          required: false,
                        ),
                      ),
                    ],
                  ),

                  inputField(
                    sizeController,
                    'Size (sqm)',
                    type: TextFieldType.number,
                  ),

                  inputField(
                    priceController,
                    'Price',
                    type: TextFieldType.number,
                  ),
=======
                children: [
                  inputField(bedroomsController, 'Bedrooms', required: false),
                  inputField(bathroomsController, 'Bathrooms', required: false),
                  inputField(sizeController, 'Size (sqm)'),
                  inputField(priceController, 'Price'),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                ],
              ),
            ),

<<<<<<< HEAD
            const SizedBox(
              height: AppSpacing.lg,
            ),
=======
            const SizedBox(height: AppSpacing.lg),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

            // =========================
            // IMAGES
            // =========================
            AppCard(
              child: Column(
<<<<<<< HEAD
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [

                      const Text(
                        'Property Images',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(
                          Icons.add_a_photo,
                        ),
                        label:
                            const Text('Add Images'),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...images.map(
                        buildImagePreview,
                      ),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                    ],
                  ),
                ],
              ),
            ),

<<<<<<< HEAD
            const SizedBox(
              height: AppSpacing.xl,
            ),

            AppButton(
              text: isLoading
                  ? "Saving..."
                  : "Post Property",
              loading: isLoading,
              onPressed:
                  isLoading ? null : submit,
            ),

            const SizedBox(
              height: AppSpacing.xl,
=======
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              text: isLoading ? "Saving..." : "Post Property",
              loading: isLoading,
              onPressed: isLoading ? null : submit,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            ),
          ],
        ),
      ),
    );
  }
}