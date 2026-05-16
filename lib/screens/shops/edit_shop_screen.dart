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
import '../../models/shop_model.dart';

import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  final Shop shop;

  const EditShopScreen({super.key, required this.shop});

  @override
  ConsumerState<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends ConsumerState<EditShopScreen> {
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

  final ImagePicker _picker = ImagePicker();

  final List<String> districts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.shop.name);
    descriptionController = TextEditingController(text: widget.shop.description);
    addressController = TextEditingController(text: widget.shop.address);
    cityController = TextEditingController(text: widget.shop.city);
    phoneController = TextEditingController(text: widget.shop.phoneNumber);
    emailController = TextEditingController(text: widget.shop.email);

    selectedDistrict = widget.shop.district;
    category = widget.shop.category;

    latitude = widget.shop.latitude;
    longitude = widget.shop.longitude;
  }

  // ================= GPS (same as create) =================
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
      final result =
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
      final result =
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

  Widget buildImage(File? file, Uint8List? bytes) {
    if (kIsWeb && bytes != null) {
      return Image.memory(bytes, height: 120, width: 120, fit: BoxFit.cover);
    }
    if (!kIsWeb && file != null) {
      return Image.file(file, height: 120, width: 120, fit: BoxFit.cover);
    }
    return const SizedBox();
  }

  // ================= UPDATE =================
  Future<void> updateShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      FormData formData = FormData.fromMap({
        "name": nameController.text,
        "description": descriptionController.text,
        "category": category,
        "address": addressController.text,
        "city": cityController.text,
        "district": selectedDistrict ?? widget.shop.district,
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

      await ref.read(shopActionsProvider).api.patchMultipart(
            "shops/${widget.shop.id}/",
            formData,
          );

      ref.invalidate(userShopsProvider);

      if (mounted) {
        AppToast.success(context,"Shop updated successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context,"Error: ${e.toString()}");
    } finally {
      setState(() => loading = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Edit Shop'),
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

              input(phoneController, "Phone"),
              input(emailController, "Email"),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: getLocation,
                child: const Text("Update Location"),
              ),

              Text("Lat: $latitude, Lng: $longitude"),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickLogo,
                child: const Text("Change Logo"),
              ),
              buildImage(logoFile, logoWeb),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickBanner,
                child: const Text("Change Banner"),
              ),
              buildImage(bannerFile, bannerWeb),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : updateShop,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Shop"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}