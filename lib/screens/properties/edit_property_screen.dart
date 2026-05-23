import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/property_model.dart';
import '../../providers/properties_provider.dart';
import '../../theme/app_colors.dart';

import '../../theme/design_system/app_text_field.dart';
import '../../widgets/main_app_bar.dart';

import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';

class PropertyFormScreen extends ConsumerStatefulWidget {
  final Property? property;

  const PropertyFormScreen({super.key, this.property});

  @override
  ConsumerState<PropertyFormScreen> createState() =>
      _PropertyFormScreenState();
}

class _PropertyFormScreenState extends ConsumerState<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  // ================= CONTROLLERS =================
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

  // ================= DROPDOWNS =================
  String listingPurpose = 'sale';
  String propertyType = 'house';
  String status = 'available';

  List<XFile> images = [];

  bool isPublic = true;
  bool loading = false;

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

  // ================= IMAGE PICKER =================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 6
            ? picked.sublist(0, 6)
            : picked;
      });
    }
  }

  // ================= GPS =================
  void generateGPS() {
    setState(() {
      latitude.text = "-15.7861";
      longitude.text = "35.0058";
    });

    AppToast.success(context, "GPS coordinates generated");
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

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
        createdAt:
            widget.property?.createdAt ?? DateTime.now(),
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
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ================= APP FIELD =================
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

  // ================= IMAGE PREVIEW =================
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
              color: Theme.of(context).colorScheme.outline.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.surface,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.outline.shade100,

      appBar: MainAppBar(
        title: isEdit
            ? "Edit Property"
            : "Add Property",
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [

            // ================= BASIC INFO =================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Basic Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  buildField(title, "Property Title"),

                  buildField(
                    description,
                    "Description",
                    type: TextFieldType.multiline,
                    maxLines: 4,
                  ),

                  DropdownButtonFormField<String>(
                    value: propertyType,
                    decoration: InputDecoration(
                      labelText: "Property Type",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "house",
                        child: Text("House"),
                      ),
                      DropdownMenuItem(
                        value: "apartment",
                        child: Text("Apartment"),
                      ),
                      DropdownMenuItem(
                        value: "land",
                        child: Text("Land"),
                      ),
                      DropdownMenuItem(
                        value: "commercial",
                        child: Text("Commercial"),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        propertyType = v!;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: listingPurpose,
                    decoration: InputDecoration(
                      labelText: "Listing Purpose",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "sale",
                        child: Text("For Sale"),
                      ),
                      DropdownMenuItem(
                        value: "rent",
                        child: Text("For Rent"),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        listingPurpose = v!;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: "Status",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "available",
                        child: Text("Available"),
                      ),
                      DropdownMenuItem(
                        value: "sold",
                        child: Text("Sold"),
                      ),
                      DropdownMenuItem(
                        value: "rented",
                        child: Text("Rented"),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        status = v!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= LOCATION =================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  buildField(address, "Address"),

                  buildField(city, "City"),

                  DropdownButtonFormField<String>(
                    value: district.text.isEmpty
                        ? null
                        : district.text,
                    decoration: InputDecoration(
                      labelText: "District",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    items: malawiDistricts
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(d),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        district.text = v!;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: buildField(
                          latitude,
                          "Latitude",
                          type: TextFieldType.number,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: buildField(
                          longitude,
                          "Longitude",
                          type: TextFieldType.number,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: generateGPS,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.mangoOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text("Generate GPS"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= DETAILS =================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Property Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: buildField(
                          bedrooms,
                          "Bedrooms",
                          type: TextFieldType.number,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: buildField(
                          bathrooms,
                          "Bathrooms",
                          type: TextFieldType.number,
                        ),
                      ),
                    ],
                  ),

                  buildField(
                    sizeSqm,
                    "Size (sqm)",
                    type: TextFieldType.number,
                  ),

                  buildField(
                    price,
                    "Price",
                    type: TextFieldType.number,
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Public Listing"),
                    value: isPublic,
                    onChanged: (v) {
                      setState(() {
                        isPublic = v;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= IMAGES =================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Property Images",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text("Add Images"),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [

                      // Existing Images
                      if (widget.property?.images != null)
                        ...widget.property!.images.map(
                          (img) => ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12),
                            child: Image.network(
                              img.image,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // New Images
                      ...images.map(buildImagePreview),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mangoOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.surface,
                      )
                    : Text(
                        isEdit
                            ? "Update Property"
                            : "Create Property",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}