import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/property_model.dart';
import '../../providers/properties_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/image_crop_picker.dart';
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';

class PropertyFormScreen extends ConsumerStatefulWidget {
  final Property? property;

  const PropertyFormScreen({super.key, this.property});

  @override
  ConsumerState<PropertyFormScreen> createState() =>
      _PropertyFormScreenState();
}

class _PropertyFormScreenState
    extends ConsumerState<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker picker = ImagePicker();

  // CONTROLLERS
  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController address;
  late TextEditingController city;
  late TextEditingController district;
  late TextEditingController latitude;
  late TextEditingController longitude;
  late TextEditingController bedrooms;
  late TextEditingController bathrooms;
  late TextEditingController sizeSqm;
  late TextEditingController price;

  // DROPDOWNS
  String listingPurpose = 'sale';
  String propertyType = 'house';
  String status = 'available';

  List<XFile> images = [];

  bool isPublic = true;
  bool loading = false;
  bool gettingGps = false;

  final List<String> malawiDistricts = [
    'Blantyre','Lilongwe','Mzuzu','Zomba','Mangochi','Salima','Kasungu',
    'Mchinji','Dedza','Nkhotakota','Nkhatabay','Karonga','Chikwawa',
    'Nsanje','Balaka','Neno','Phalombe','Mulanje','Thyolo','Chiradzulu',
    'Ntcheu','Rumphi','Likoma'
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.property;

    title = TextEditingController(text: p?.title ?? '');
    description = TextEditingController(text: p?.description ?? '');
    address = TextEditingController(text: p?.address ?? '');
    city = TextEditingController(text: p?.city ?? '');
    district = TextEditingController(text: p?.district ?? '');
    latitude = TextEditingController(text: p?.latitude.toString() ?? '');
    longitude = TextEditingController(text: p?.longitude.toString() ?? '');
    bedrooms = TextEditingController(text: p?.bedrooms?.toString() ?? '');
    bathrooms = TextEditingController(text: p?.bathrooms?.toString() ?? '');
    sizeSqm = TextEditingController(text: p?.sizeSqm.toString() ?? '');
    price = TextEditingController(text: p?.price.toString() ?? '');

    propertyType = p?.propertyType ?? 'house';
    status = p?.status ?? 'available';
    isPublic = p?.isPubliclyVisible ?? true;
    listingPurpose = p?.listingPurpose ?? 'sale';
  }

  // ================= GPS =================
  Future<void> getGPS() async {
    setState(() => gettingGps = true);

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        AppToast.error(context, "Location services are disabled");
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        AppToast.error(context, "Location permission permanently denied");
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        latitude.text = position.latitude.toStringAsFixed(6);
        longitude.text = position.longitude.toStringAsFixed(6);
      });

      AppToast.success(context, "GPS captured successfully");
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => gettingGps = false);
    }
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (images.isEmpty && widget.property == null) {
      AppToast.error(context, "Please select at least one image");
      return;
    }

    setState(() => loading = true);

    try {
      final property = Property(
        id: widget.property?.id ?? 0,
        slug: widget.property?.slug ?? '',
        title: title.text,
        description: description.text,
        propertyType: propertyType,
        status: status,
        listingPurpose: listingPurpose,
        latitude: double.tryParse(latitude.text) ?? 0,
        longitude: double.tryParse(longitude.text) ?? 0,
        address: address.text,
        city: city.text,
        district: district.text,
        bedrooms: int.tryParse(bedrooms.text),
        bathrooms: int.tryParse(bathrooms.text),
        sizeSqm: double.tryParse(sizeSqm.text) ?? 0,
        price: double.tryParse(price.text) ?? 0,
        currency: "MWK",
        isPubliclyVisible: isPublic,
        unlockFee: widget.property?.unlockFee ?? 0,
        viewCount: widget.property?.viewCount ?? 0,
        images: widget.property?.images ?? [],
        ownerId: widget.property?.ownerId ?? 0,
        ownerName: widget.property?.ownerName ?? '',
        isUnlocked: widget.property?.isUnlocked ?? false,
        createdAt: widget.property?.createdAt ?? DateTime.now(),
      );

      final actions = ref.read(propertyActionsProvider);

      if (widget.property == null) {
        await actions.createProperty(property, images);
      } else {
        await actions.updateProperty(
          propertyId: property.id,
          property: property,
          images: images,
        );
      }

      if (mounted) {
        AppToast.success(
          context,
          widget.property == null
              ? "Property created successfully"
              : "Property updated successfully",
        );

        Navigator.pop(context);
      }
    } catch (e) {
      AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= FIELD =================
  Widget buildField(
    TextEditingController controller,
    String label, {
    TextFieldType type = TextFieldType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTextField(
        label: label,
        controller: controller,
        type: type,
        maxLines: maxLines,
        isRequired: true,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: MainAppBar(
        title: isEdit ? "Edit Property" : "Add Property",
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            // ================= IMAGES (UPDATED) =================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Property Images",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Upload clear landscape property photos",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  ImageCropPicker(
                    maxImages: 6,
                    cropType: CropShapeType.rectangle, // ✅ IMPORTANT
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

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(isEdit
                        ? "Update Property"
                        : "Create Property"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}