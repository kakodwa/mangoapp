import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/property_model.dart';
import '../../providers/properties_provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';

import '../../widgets/image_crop_picker.dart';
import '../../widgets/main_app_bar.dart';

import '../../utils/app_toast.dart';

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
  final titleController = TextEditingController();
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
  bool gettingGps = false;

  String propertyType = 'house';
  String listingPurpose = 'sale';
  String propertyStatus = 'available';

  List<XFile> images = [];

  // =========================
  // MALAWI DISTRICTS
  // =========================
  final List<String> malawiDistricts = [
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
  ];

  // =========================
  // GPS
  // =========================
  Future<void> getGPS() async {
    setState(() => gettingGps = true);

    try {
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
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitudeController.text =
            position.latitude.toStringAsFixed(6);

        longitudeController.text =
            position.longitude.toStringAsFixed(6);
      });

      AppToast.success(
        context,
        "GPS captured successfully",
      );
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => gettingGps = false);
      }
    }
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (images.isEmpty) {
      AppToast.error(
        context,
        "Please select at least one image",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final property = Property(
        id: 0,
        title: titleController.text,
        slug: '',
        description: descriptionController.text,
        propertyType: propertyType,
        listingPurpose: listingPurpose,
        status: propertyStatus,
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
        AppToast.success(
          context,
          'Property posted successfully',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // =========================
  // INPUT FIELD HELPER
  // =========================
  Widget inputField(
    TextEditingController controller,
    String label, {
    TextFieldType type = TextFieldType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.md),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: const MainAppBar(
        title: 'Post Property',
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(AppSpacing.md),
          children: [

            const AppInfoBox(
              icon: Icons.info_outline,
              message:
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
                    type:
                        TextFieldType.multiline,
                    maxLines: 4,
                  ),

                  DropdownButtonFormField<String>(
                    value: propertyType,
                    decoration: InputDecoration(
                      labelText:
                          'Property Type',
                      filled: true,
                      fillColor:
                          Theme.of(context)
                              .colorScheme
                              .surface,
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
                        child:
                            Text('Apartment'),
                      ),
                      DropdownMenuItem(
                        value: 'land',
                        child: Text('Land'),
                      ),
                      DropdownMenuItem(
                        value: 'commercial',
                        child:
                            Text('Commercial'),
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
                      fillColor:
                          Theme.of(context)
                              .colorScheme
                              .surface,
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
                        child:
                            Text('For Sale'),
                      ),
                      DropdownMenuItem(
                        value: 'rent',
                        child:
                            Text('For Rent'),
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
                      fillColor:
                          Theme.of(context)
                              .colorScheme
                              .surface,
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
                        child:
                            Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'sold',
                        child: Text('Sold'),
                      ),
                      DropdownMenuItem(
                        value: 'rented',
                        child:
                            Text('Rented'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        propertyStatus = v!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            // =========================
            // LOCATION
            // =========================
            AppCard(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "📍 GPS used for navigation after unlock",
                    style: TextStyle(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .outline,
                    ),
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
                    value:
                        districtController
                                .text
                                .isEmpty
                            ? null
                            : districtController
                                .text,
                    decoration: InputDecoration(
                      labelText: 'District',
                      filled: true,
                      fillColor:
                          Theme.of(context)
                              .colorScheme
                              .surface,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items:
                        malawiDistricts
                            .map(
                              (d) =>
                                  DropdownMenuItem(
                                value: d,
                                child:
                                    Text(d),
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
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          gettingGps
                              ? null
                              : getGPS,
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
                      icon: gettingGps
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color: Theme.of(
                                        context)
                                    .colorScheme
                                    .surface,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .my_location,
                            ),
                      label: Text(
                        gettingGps
                            ? "Getting GPS..."
                            : "Get GPS Location",
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
                              TextFieldType
                                  .number,
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child: inputField(
                          longitudeController,
                          'Longitude',
                          type:
                              TextFieldType
                                  .number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            // =========================
            // DETAILS
            // =========================
            AppCard(
              child: Column(
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
                              TextFieldType
                                  .number,
                          required: false,
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(
                        child: inputField(
                          bathroomsController,
                          'Bathrooms',
                          type:
                              TextFieldType
                                  .number,
                          required: false,
                        ),
                      ),
                    ],
                  ),

                  inputField(
                    sizeController,
                    'Size (sqm)',
                    type:
                        TextFieldType.number,
                  ),

                  inputField(
                    priceController,
                    'Price',
                    type:
                        TextFieldType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            // =========================
            // IMAGES (RECTANGLE CROPPER)
            // =========================
            AppCard(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Property Images',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Upload clear landscape property photos",
                    style: TextStyle(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .outline,
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  ImageCropPicker(
                    maxImages: 6,
                    cropType:
                        CropShapeType
                            .rectangle,
                    initialImages: images,
                    onChanged: (value) {
                      setState(() {
                        images = value;
                      });
                    },
                  ),
                ],
              ),
            ),

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
            ),
          ],
        ),
      ),
    );
  }
}