import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';

import '../../providers/shops_provider.dart';

import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';

class CreateShopScreen extends ConsumerStatefulWidget {
  const CreateShopScreen({super.key});

  @override
  ConsumerState<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends ConsumerState<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String category = "Electronics";
  String? selectedDistrict;

  bool loading = false;

  // GPS
  double? latitude;
  double? longitude;

  // IMAGES
  File? logoFile;
  File? bannerFile;

  Uint8List? logoWeb;
  Uint8List? bannerWeb;

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
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
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
        setState(() {});
      }
    }
  }

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
        setState(() {});
      }
    }
  }

  // ================= IMAGE PREVIEW WIDGET =================
  Widget buildImagePreview({File? file, Uint8List? bytes}) {
    if (kIsWeb && bytes != null) {
      return Image.memory(bytes,
          height: 120, width: 120, fit: BoxFit.cover);
    }

    if (!kIsWeb && file != null) {
      return Image.file(file,
          height: 120, width: 120, fit: BoxFit.cover);
    }

    return const SizedBox();
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      FormData formData = FormData.fromMap({
        "name": nameController.text,
        "description": descriptionController.text,
        "category": category,
        "address": addressController.text,
        "city": cityController.text,
        "district": selectedDistrict,
        "phone_number": phoneController.text,
        "email": emailController.text,
        "latitude": latitude ?? 0,
        "longitude": longitude ?? 0,
      });

      // LOGO
      if (kIsWeb && logoWeb != null) {
        formData.files.add(MapEntry(
          "logo",
          MultipartFile.fromBytes(logoWeb!, filename: "logo.jpg"),
        ));
      } else if (logoFile != null) {
        formData.files.add(MapEntry(
          "logo",
          await MultipartFile.fromFile(logoFile!.path),
        ));
      }

      // BANNER
      if (kIsWeb && bannerWeb != null) {
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
            "shops/",
            formData,
          );

      ref.invalidate(shopsProvider);

      if (mounted) {
        AppToast.success(context,"Shop created successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context,"Error: ${e.toString()}");
    } finally {
      setState(() => loading = false);
    }
  }

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
            ],
          ),
        ),
      ),
    );
  }
}