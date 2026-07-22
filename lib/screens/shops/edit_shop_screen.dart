import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../providers/shops_provider.dart';
import '../../models/shop_model.dart';
import '../main_tabs_screen.dart'; // Core structural coordinator layout

import '../../utils/app_toast.dart';
import '../../widgets/image_crop_picker.dart';
import '../../widgets/web_footer.dart';

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
    "Phalombe","Rumphi","Salima","Thyolo","Zomba","China","USA","Canada","Tanzania","South Africa","Other",
  ];

  final List<String> categories = [
    "Electronics",
    "Groceries",
    'Fashion',
    'Home & Living',
    'Beauty & Personal Care',
    'Health & Wellness',
    'Agriculture',
    'Vehicles',
    'Construction & Hardware',
    'Books & Education',
    'Sports & Outdoors',
    'Baby & Kids',
    'Food & Beverages',
    'Pets & Animals',
    'Office Supplies',
    'Entertainment',
    'Services',
    'Industrial Equipment',
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

    Future<MultipartFile> _multipartFileFromXFile(XFile file) async {
  if (kIsWeb) {
    return MultipartFile.fromBytes(
      await file.readAsBytes(),
      filename: file.name,
    );
  }

  return MultipartFile.fromFile(
    file.path,
    filename: file.name,
  );
}

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

      for (final img in logoImages) {
  formData.files.add(
    MapEntry(
      "logo",
      await _multipartFileFromXFile(img),
    ),
  );
}

for (final img in bannerImages) {
  formData.files.add(
    MapEntry(
      "banner",
      await _multipartFileFromXFile(img),
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
        MainTabsScreen.of(context)?.setSelectedIndex(18);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    
    final contentPadding = isDesktop 
        ? EdgeInsets.symmetric(horizontal: screenWidth * 0.12, vertical: AppSpacing.lg)
        : const EdgeInsets.all(AppSpacing.md);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Multi-column row on Web/Desktop, stacked column on Mobile
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                    children: [
                      // COLUMN 1: Profile & Communications
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            DropdownButtonFormField<String>(
                              value: category,
                              items: categories
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => category = v!),
                              decoration: InputDecoration(
                                labelText: "Category",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
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
                          ],
                        ),
                      ),
                      
                      if (isDesktop) const SizedBox(width: AppSpacing.xl),
                      
                      // COLUMN 2: Regional Logistics & Mapping
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isDesktop) const SizedBox(height: AppSpacing.md),
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
                            DropdownButtonFormField<String>(
                              value: selectedDistrict,
                              items: districts
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => selectedDistrict = v),
                              decoration: InputDecoration(
                                labelText: "District",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            
                            // Geolocation Container Widget
                            Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.surfaceContainerLow ?? Colors.grey.shade100,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: gettingLocation ? null : getLocation,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(45),
                                      ),
                                      icon: gettingLocation
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.location_on),
                                      label: Text(
                                        gettingLocation ? "Getting Location..." : "Update GPS Coordinates",
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text("Lat: ${latitude ?? 0}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text("Lng: ${longitude ?? 0}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // Media Configuration Layout
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Shop Logo (Square)", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ImageCropPicker(
                              maxImages: 1,
                              cropType: CropShapeType.square,
                              initialImages: logoImages,
                              onChanged: (list) => setState(() => logoImages = list),
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                            const Text(
                              "Shop Banner (Rectangle)", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ImageCropPicker(
                              maxImages: 1,
                              cropType: CropShapeType.rectangle,
                              initialImages: bannerImages,
                              onChanged: (list) => setState(() => bannerImages = list),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Constrained Submit Box
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : updateShop,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Update Shop",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            if (isDesktop) const WebFooter(),
          ],
        ),
      ),
    );
  }
}