import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_text_field.dart';

import '../../providers/shops_provider.dart';
import '../../models/shop_model.dart';

import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  final Shop shop;

  const EditShopScreen({
    super.key,
    required this.shop,
  });

  @override
  ConsumerState<EditShopScreen> createState() =>
      _EditShopScreenState();
}

class _EditShopScreenState
    extends ConsumerState<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  String? selectedDistrict;
  String category = "Electronics";

  bool loading = false;

  double? latitude;
  double? longitude;

  File? logoFile;
  File? bannerFile;

  Uint8List? logoWeb;
  Uint8List? bannerWeb;

  final ImagePicker picker = ImagePicker();

  final List<String> districts = [
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

  final List<String> categories = [
    "Electronics",
    "Fashion",
    "Groceries",
    "Home",
    "Beauty",
  ];

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.shop.name);

    descriptionController = TextEditingController(
      text: widget.shop.description,
    );

    addressController =
        TextEditingController(text: widget.shop.address);

    cityController =
        TextEditingController(text: widget.shop.city);

    phoneController = TextEditingController(
      text: widget.shop.phoneNumber,
    );

    emailController =
        TextEditingController(text: widget.shop.email);

    selectedDistrict = widget.shop.district;
    category = widget.shop.category;

    latitude = widget.shop.latitude;
    longitude = widget.shop.longitude;
  }

  // ======================
  // LOCATION
  // ======================

  Future<void> getLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      AppToast.error(
        context,
        'Enable location services',
      );
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position pos =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude =
          double.parse(pos.latitude.toStringAsFixed(6));

      longitude =
          double.parse(pos.longitude.toStringAsFixed(6));
    });

    if (mounted) {
      AppToast.success(
        context,
        'Location updated',
      );
    }
  }

  // ======================
  // PICK LOGO
  // ======================

  Future<void> pickLogo() async {
    if (kIsWeb) {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        logoWeb = result.files.first.bytes;

        setState(() {});
      }
    } else {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        logoFile = File(file.path);

        setState(() {});
      }
    }
  }

  // ======================
  // PICK BANNER
  // ======================

  Future<void> pickBanner() async {
    if (kIsWeb) {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        bannerWeb = result.files.first.bytes;

        setState(() {});
      }
    } else {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        bannerFile = File(file.path);

        setState(() {});
      }
    }
  }

  // ======================
  // IMAGE PREVIEW
  // ======================

  Widget buildImage(
    File? file,
    Uint8List? bytes,
  ) {
    if (kIsWeb && bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          bytes,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    if (!kIsWeb && file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    return const SizedBox();
  }

  // ======================
  // UPDATE SHOP
  // ======================

  Future<void> updateShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      FormData formData = FormData.fromMap({
        "name": nameController.text,
        "description":
            descriptionController.text,
        "category": category,
        "address": addressController.text,
        "city": cityController.text,
        "district":
            selectedDistrict ??
                widget.shop.district,
        "phone_number":
            phoneController.text,
        "email": emailController.text,
        "latitude": latitude ?? 0,
        "longitude": longitude ?? 0,
      });

      // LOGO
      if (kIsWeb && logoWeb != null) {
        formData.files.add(
          MapEntry(
            "logo",
            MultipartFile.fromBytes(
              logoWeb!,
              filename: "logo.jpg",
            ),
          ),
        );
      } else if (logoFile != null) {
        formData.files.add(
          MapEntry(
            "logo",
            await MultipartFile.fromFile(
              logoFile!.path,
            ),
          ),
        );
      }

      // BANNER
      if (kIsWeb && bannerWeb != null) {
        formData.files.add(
          MapEntry(
            "banner",
            MultipartFile.fromBytes(
              bannerWeb!,
              filename: "banner.jpg",
            ),
          ),
        );
      } else if (bannerFile != null) {
        formData.files.add(
          MapEntry(
            "banner",
            await MultipartFile.fromFile(
              bannerFile!.path,
            ),
          ),
        );
      }

      await ref
          .read(shopActionsProvider)
          .api
          .patchMultipart(
            "shops/${widget.shop.id}/",
            formData,
          );

      ref.invalidate(userShopsProvider);

      if (mounted) {
        AppToast.success(
          context,
          "Shop updated successfully",
        );

        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(
        context,
        "Error: ${e.toString()}",
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

      appBar: const MainAppBar(
        title: 'Edit Shop',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // ======================
              // SHOP NAME
              // ======================

              AppTextField(
                label: 'Shop Name',
                hint: 'Enter shop name',
                controller: nameController,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Shop name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // DESCRIPTION
              // ======================

              AppTextField(
                label: 'Description',
                hint: 'Enter shop description',
                controller:
                    descriptionController,
                type: TextFieldType.multiline,
                maxLines: 4,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Description required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // CATEGORY
              // ======================

              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // ADDRESS
              // ======================

              AppTextField(
                label: 'Address',
                hint: 'Enter address',
                controller:
                    addressController,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Address required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // CITY
              // ======================

              AppTextField(
                label: 'City',
                hint: 'Enter city',
                controller: cityController,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'City required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // DISTRICT
              // ======================

              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: InputDecoration(
                  labelText: 'District',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                items: districts.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Select district';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // PHONE
              // ======================

              AppTextField(
                label: 'Phone Number',
                hint: 'Enter phone number',
                controller:
                    phoneController,
                type: TextFieldType.phone,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Phone required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // EMAIL
              // ======================

              AppTextField(
                label: 'Email',
                hint: 'Enter email address',
                controller:
                    emailController,
                type: TextFieldType.email,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Email required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // ======================
              // LOCATION
              // ======================

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop Location',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: getLocation,
                          icon: Icon(
                            Icons.location_on,
                          ),
                          label: Text(
                            'Update Location',
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        'Latitude: ${latitude ?? 0}',
                      ),

                      const SizedBox(height: AppSpacing.xxs),

                      Text(
                        'Longitude: ${longitude ?? 0}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ======================
              // LOGO
              // ======================

              Text(
                "Shop Logo",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              GestureDetector(
                onTap: pickLogo,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                    ),
                  ),
                  child: logoFile != null ||
                          logoWeb != null
                      ? buildImage(
                          logoFile,
                          logoWeb,
                        )
                      : Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: const [
                            Icon(
                              Icons.image_outlined,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text('Tap to change logo'),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ======================
              // BANNER
              // ======================

              Text(
                "Shop Banner",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              GestureDetector(
                onTap: pickBanner,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                    ),
                  ),
                  child: bannerFile != null ||
                          bannerWeb != null
                      ? buildImage(
                          bannerFile,
                          bannerWeb,
                        )
                      : Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: const [
                            Icon(
                              Icons
                                  .photo_library_outlined,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to change banner',
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // ======================
              // BUTTON
              // ======================

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      loading ? null : updateShop,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.surface,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Update Shop",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}