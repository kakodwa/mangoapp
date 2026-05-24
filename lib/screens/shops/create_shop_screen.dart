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

import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';

class CreateShopScreen extends ConsumerStatefulWidget {
  const CreateShopScreen({super.key});

  @override
  ConsumerState<CreateShopScreen> createState() =>
      _CreateShopScreenState();
}

class _CreateShopScreenState
    extends ConsumerState<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // ======================
  // CONTROLLERS
  // ======================

  final nameController = TextEditingController();
  final descriptionController =
      TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String category = "Electronics";
  String? selectedDistrict;

  bool loading = false;
  bool gettingLocation = false;

  // ======================
  // LOCATION
  // ======================

  double? latitude;
  double? longitude;

  // ======================
  // IMAGES
  // ======================

  File? logoFile;
  File? bannerFile;

  Uint8List? logoWeb;
  Uint8List? bannerWeb;

  final ImagePicker picker = ImagePicker();

  // ======================
  // DISTRICTS
  // ======================

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

  // ======================
  // GET LOCATION
  // ======================

 Future<void> getLocation() async {

  setState(() {
    gettingLocation = true;
  });

  try {

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
          double.parse(
              pos.latitude.toStringAsFixed(6));

      longitude =
          double.parse(
              pos.longitude.toStringAsFixed(6));
    });

    if (mounted) {

      AppToast.success(
        context,
        'Location captured successfully',
      );
    }

  } catch (e) {

    AppToast.error(
      context,
      'Failed to get location',
    );

  } finally {

    if (mounted) {

      setState(() {
        gettingLocation = false;
      });
    }
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

  Widget buildImagePreview({
    File? file,
    Uint8List? bytes,
  }) {
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
  // SUBMIT
  // ======================

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (latitude == null || longitude == null) {
      AppToast.error(
        context,
        'Please capture shop location',
      );
      return;
    }

    setState(() => loading = true);

    try {
      FormData formData = FormData.fromMap({
        "name": nameController.text,
        "description":
            descriptionController.text,
        "category": category,
        "address": addressController.text,
        "city": cityController.text,
        "district": selectedDistrict,
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
          .postMultipart(
            "shops/",
            formData,
          );

      ref.invalidate(shopsProvider);

      if (mounted) {
        AppToast.success(
          context,
          "Shop created successfully",
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

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(
        title: 'Create Shop',
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
                        'Shop GPS Location',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        'Please capture GPS at the entrance of your shop.',
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(

  onPressed:
      gettingLocation
          ? null
          : getLocation,

  icon: gettingLocation
      ? SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context)
                .colorScheme
                .surface,
          ),
        )
      : const Icon(
          Icons.my_location,
        ),

  label: Text(
    gettingLocation
        ? 'Getting GPS Location...'
        : 'Get Shop Location',
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
                      ? buildImagePreview(
                          file: logoFile,
                          bytes: logoWeb,
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
                            Text(
                              'Tap to upload logo',
                            ),
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
                      ? buildImagePreview(
                          file: bannerFile,
                          bytes: bannerWeb,
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
                              'Tap to upload banner',
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
                      loading ? null : submit,
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
                          "Create Shop",
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