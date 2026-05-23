import 'dart:io';
import 'dart:typed_data';

<<<<<<< HEAD
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
<<<<<<< HEAD

import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_text_field.dart';
=======
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

import '../../providers/shops_provider.dart';

import '../../utils/app_toast.dart';
<<<<<<< HEAD
=======
import '../../utils/api_response_handler.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class CreateShopScreen extends ConsumerStatefulWidget {
  const CreateShopScreen({super.key});

  @override
<<<<<<< HEAD
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
=======
  ConsumerState<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends ConsumerState<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String category = "Electronics";
  String? selectedDistrict;

  bool loading = false;

<<<<<<< HEAD
  // ======================
  // LOCATION
  // ======================

  double? latitude;
  double? longitude;

  // ======================
  // IMAGES
  // ======================

=======
  // GPS
  double? latitude;
  double? longitude;

  // IMAGES
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  File? logoFile;
  File? bannerFile;

  Uint8List? logoWeb;
  Uint8List? bannerWeb;

<<<<<<< HEAD
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
=======
  final ImagePicker _picker = ImagePicker();

  // DISTRICTS
  final List<String> districts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba",
  ];

  // ================= GPS =================
  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
<<<<<<< HEAD
      latitude =
          double.parse(pos.latitude.toStringAsFixed(6));

      longitude =
          double.parse(pos.longitude.toStringAsFixed(6));
    });

    if (mounted) {
      AppToast.success(
        context,
        'Location captured successfully',
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

=======
      latitude = double.parse(pos.latitude.toStringAsFixed(6));
      longitude = double.parse(pos.longitude.toStringAsFixed(6));
    });
  }

  // ================= PICK LOGO =================
  Future<void> pickLogo() async {
    if (kIsWeb) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        logoWeb = result.files.first.bytes;
        setState(() {});
      }
    } else {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        logoFile = File(file.path);
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        setState(() {});
      }
    }
  }

<<<<<<< HEAD
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

=======
  // ================= PICK BANNER =================
  Future<void> pickBanner() async {
    if (kIsWeb) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        bannerWeb = result.files.first.bytes;
        setState(() {});
      }
    } else {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        bannerFile = File(file.path);
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        setState(() {});
      }
    }
  }

<<<<<<< HEAD
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
=======
  // ================= IMAGE PREVIEW WIDGET =================
  Widget buildImagePreview({File? file, Uint8List? bytes}) {
    if (kIsWeb && bytes != null) {
      return Image.memory(bytes,
          height: 120, width: 120, fit: BoxFit.cover);
    }

    if (!kIsWeb && file != null) {
      return Image.file(file,
          height: 120, width: 120, fit: BoxFit.cover);
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    }

    return const SizedBox();
  }

<<<<<<< HEAD
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

=======
  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    setState(() => loading = true);

    try {
      FormData formData = FormData.fromMap({
        "name": nameController.text,
<<<<<<< HEAD
        "description":
            descriptionController.text,
=======
        "description": descriptionController.text,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        "category": category,
        "address": addressController.text,
        "city": cityController.text,
        "district": selectedDistrict,
<<<<<<< HEAD
        "phone_number":
            phoneController.text,
=======
        "phone_number": phoneController.text,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        "email": emailController.text,
        "latitude": latitude ?? 0,
        "longitude": longitude ?? 0,
      });

      // LOGO
      if (kIsWeb && logoWeb != null) {
<<<<<<< HEAD
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
=======
        formData.files.add(MapEntry(
          "logo",
          MultipartFile.fromBytes(logoWeb!, filename: "logo.jpg"),
        ));
      } else if (logoFile != null) {
        formData.files.add(MapEntry(
          "logo",
          await MultipartFile.fromFile(logoFile!.path),
        ));
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      }

      // BANNER
      if (kIsWeb && bannerWeb != null) {
<<<<<<< HEAD
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
=======
        formData.files.add(MapEntry(
          "banner",
          MultipartFile.fromBytes(bannerWeb!, filename: "banner.jpg"),
        ));
      } else if (bannerFile != null) {
        formData.files.add(MapEntry(
          "banner",
          await MultipartFile.fromFile(bannerFile!.path),
        ));
      }

      await ref.read(shopActionsProvider).api.postMultipart(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            "shops/",
            formData,
          );

      ref.invalidate(shopsProvider);

      if (mounted) {
<<<<<<< HEAD
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
=======
        AppToast.success(context,"Shop created successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context,"Error: ${e.toString()}");
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    } finally {
      setState(() => loading = false);
    }
  }

<<<<<<< HEAD
  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: const MainAppBar(
        title: 'Create Shop',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              // ======================
              // CATEGORY
              // ======================

              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              // ======================
              // DISTRICT
              // ======================

              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: InputDecoration(
                  labelText: 'District',
                  filled: true,
                  fillColor: Colors.white,
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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 24),

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
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shop GPS Location',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Please capture GPS at the entrance of your shop.',
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: getLocation,
                          icon: const Icon(
                            Icons.my_location,
                          ),
                          label: const Text(
                            'Get Current Location',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Latitude: ${latitude ?? 0}',
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Longitude: ${longitude ?? 0}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ======================
              // LOGO
              // ======================

              const Text(
                "Shop Logo",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: pickLogo,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade300,
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

              const SizedBox(height: 24),

              // ======================
              // BANNER
              // ======================

              const Text(
                "Shop Banner",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: pickBanner,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade300,
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
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
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
=======
  // ================= INPUT =================
  Widget input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: (v) => v!.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Create Shop'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              input(nameController, "Shop Name"),
              input(descriptionController, "Description"),
              input(addressController, "Address"),
              input(cityController, "City"),

              DropdownButtonFormField<String>(
                value: selectedDistrict,
                items: districts
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedDistrict = v),
                decoration: const InputDecoration(
                  labelText: "District",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              input(phoneController, "Phone"),
              input(emailController, "Email"),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: category,
                items: const [
                  DropdownMenuItem(value: "Electronics", child: Text("Electronics")),
                  DropdownMenuItem(value: "Fashion", child: Text("Fashion")),
                  DropdownMenuItem(value: "Groceries", child: Text("Groceries")),
                  DropdownMenuItem(value: "Home", child: Text("Home")),
                  DropdownMenuItem(value: "Beauty", child: Text("Beauty")),
                ],
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "📍 Please pick GPS at the door of your shop/company",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),

              ElevatedButton.icon(
                onPressed: getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Get Location"),
              ),

              if (latitude != null)
                Text("Lat: $latitude, Lng: $longitude"),

              const SizedBox(height: 20),

              // LOGO
              ElevatedButton.icon(
                onPressed: pickLogo,
                icon: const Icon(Icons.image),
                label: const Text("Upload Logo"),
              ),

              if (logoFile != null || logoWeb != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: buildImagePreview(
                    file: logoFile,
                    bytes: logoWeb,
                  ),
                ),

              const SizedBox(height: 15),

              // BANNER
              ElevatedButton.icon(
                onPressed: pickBanner,
                icon: const Icon(Icons.image),
                label: const Text("Upload Banner"),
              ),

              if (bannerFile != null || bannerWeb != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: buildImagePreview(
                    file: bannerFile,
                    bytes: bannerWeb,
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Shop"),
              ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            ],
          ),
        ),
      ),
    );
  }
}