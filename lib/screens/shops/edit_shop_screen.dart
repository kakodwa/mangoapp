import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../providers/shops_provider.dart';
import '../../models/shop_model.dart';

import '../../utils/app_toast.dart';
import '../../widgets/image_crop_picker.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  final Shop shop;

  const EditShopScreen({
    super.key,
    required this.shop,
  });

  @override
  ConsumerState<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends ConsumerState<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // ======================
  // CONTROLLERS
  // ======================
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  String? selectedDistrict;
  String category = "Electronics";

  bool loading = false;
  bool gettingLocation = false;

  double? latitude;
  double? longitude;

  // ======================
  // IMAGES (NEW SYSTEM)
  // ======================
  List<XFile> logoImages = [];
  List<XFile> bannerImages = [];

  // ======================
  // DATA
  // ======================
  final List<String> districts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba",
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

  // ======================
  // LOCATION
  // ======================
  Future<void> getLocation() async {
    setState(() => gettingLocation = true);

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        AppToast.error(context, 'Enable location services');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = double.parse(pos.latitude.toStringAsFixed(6));
        longitude = double.parse(pos.longitude.toStringAsFixed(6));
      });

      if (mounted) {
        AppToast.success(context, 'Location updated');
      }
    } catch (_) {
      AppToast.error(context, 'Failed to get location');
    } finally {
      if (mounted) setState(() => gettingLocation = false);
    }
  }

  // ======================
  // UPDATE SHOP
  // ======================
  Future<void> updateShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final formData = FormData.fromMap({
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

      // ======================
      // LOGO (SQUARE)
      // ======================
      for (final img in logoImages) {
        formData.files.add(
          MapEntry(
            "logo",
            await MultipartFile.fromFile(img.path),
          ),
        );
      }

      // ======================
      // BANNER (RECTANGLE)
      // ======================
      for (final img in bannerImages) {
        formData.files.add(
          MapEntry(
            "banner",
            await MultipartFile.fromFile(img.path),
          ),
        );
      }

      await ref.read(shopActionsProvider).api.patchMultipart(
            "shops/${widget.shop.id}/",
            formData,
          );

      ref.invalidate(userShopsProvider);

      if (mounted) {
        AppToast.success(context, "Shop updated successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: "Edit Shop"),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            AppTextField(
              label: 'Shop Name',
              controller: nameController,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Description',
              controller: descriptionController,
              type: TextFieldType.multiline,
              maxLines: 4,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField(
              value: category,
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Address',
              controller: addressController,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Town/Area',
              controller: cityController,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField(
              value: selectedDistrict,
              items: districts
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedDistrict = v),
              decoration: const InputDecoration(labelText: "District"),
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
  label: 'Phone (WhatsApp)',
  hint: '+265993344416',
  controller: phoneController,
  type: TextFieldType.phone,
  isRequired: true,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    // ✅ International WhatsApp format
    final regex = RegExp(r'^\+[1-9]\d{7,14}$');

    if (!regex.hasMatch(phone)) {
      return 'Use format like +265993344416';
    }

    return null;
  },
),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Email',
              controller: emailController,
              type: TextFieldType.email,
              isRequired: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            ElevatedButton.icon(
              onPressed: gettingLocation ? null : getLocation,
              icon: gettingLocation
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.location_on),
              label: Text(
                gettingLocation ? "Getting Location..." : "Update Location",
              ),
            ),

            Text("Lat: ${latitude ?? 0}"),
            Text("Lng: ${longitude ?? 0}"),

            const SizedBox(height: AppSpacing.lg),

            // ======================
            // LOGO (SQUARE)
            // ======================
            Text("Shop Logo (Square)", style: TextStyle(fontWeight: FontWeight.bold)),

            ImageCropPicker(
              maxImages: 1,
              cropType: CropShapeType.square,
              initialImages: logoImages,
              onChanged: (list) => setState(() => logoImages = list),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ======================
            // BANNER (RECTANGLE)
            // ======================
            Text("Shop Banner (Rectangle)", style: TextStyle(fontWeight: FontWeight.bold)),

            ImageCropPicker(
              maxImages: 1,
              cropType: CropShapeType.rectangle,
              initialImages: bannerImages,
              onChanged: (list) => setState(() => bannerImages = list),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : updateShop,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Shop"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}