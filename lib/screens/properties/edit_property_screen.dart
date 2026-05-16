import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/property_model.dart';
import '../../providers/properties_provider.dart';
import '../../theme/app_colors.dart';

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

  // ================= NEW FIELD =================
  String listingPurpose = 'sale';

  String propertyType = 'house';
  String status = 'available';

  List<XFile> images = [];
  bool isPublic = true;
  bool loading = false;

  final List<String> malawiDistricts = [
    'Blantyre','Lilongwe','Mzuzu','Zomba','Mangochi','Salima',
    'Kasungu','Mchinji','Dedza','Nkhotakota','Nkhatabay','Karonga',
    'Chikwawa','Nsanje','Balaka','Neno','Phalombe','Mulanje',
    'Thyolo','Chiradzulu','Ntcheu','Rumphi','Likoma'
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

    // ✅ NEW FIELD
    listingPurpose = 'sale';
  }

  // ================= IMAGE PICKER =================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 4 ? picked.sublist(0, 4) : picked;
      });
    }
  }

  // ================= GPS =================
  void generateGPS() {
    setState(() {
      latitude.text = "-15.7861";
      longitude.text = "35.0058";
    });
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

        // ✅ NEW FIELD
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

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= FIELD =================
  Widget _field(TextEditingController c, String label, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: max,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Property" : "Add Property"),
        backgroundColor: AppColors.mangoOrange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ================= BASIC =================
            const Text("Basic Information",
                style: TextStyle(fontWeight: FontWeight.bold)),

            _field(title, "Title"),
            _field(description, "Description", max: 3),

            DropdownButtonFormField(
              value: propertyType,
              items: const [
                DropdownMenuItem(value: "house", child: Text("House")),
                DropdownMenuItem(value: "apartment", child: Text("Apartment")),
                DropdownMenuItem(value: "land", child: Text("Land")),
                DropdownMenuItem(value: "commercial", child: Text("Commercial")),
              ],
              onChanged: (v) => setState(() => propertyType = v!),
              decoration: const InputDecoration(labelText: "Type"),
            ),

            DropdownButtonFormField(
              value: listingPurpose,
              items: const [
                DropdownMenuItem(value: "sale", child: Text("For Sale")),
                DropdownMenuItem(value: "rent", child: Text("For Rent")),
              ],
              onChanged: (v) => setState(() => listingPurpose = v!),
              decoration: const InputDecoration(labelText: "Listing Purpose"),
            ),

            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(value: "available", child: Text("Available")),
                DropdownMenuItem(value: "sold", child: Text("Sold")),
                DropdownMenuItem(value: "rented", child: Text("Rented")),
              ],
              onChanged: (v) => setState(() => status = v!),
              decoration: const InputDecoration(labelText: "Status"),
            ),

            const SizedBox(height: 20),

            // ================= LOCATION =================
            const Text("Location",
                style: TextStyle(fontWeight: FontWeight.bold)),

            _field(address, "Address"),
            _field(city, "City"),

            DropdownButtonFormField(
              value: district.text.isEmpty ? null : district.text,
              items: malawiDistricts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => district.text = v!),
              decoration: const InputDecoration(labelText: "District"),
            ),

            Row(
              children: [
                Expanded(child: _field(latitude, "Latitude")),
                const SizedBox(width: 10),
                Expanded(child: _field(longitude, "Longitude")),
              ],
            ),

            ElevatedButton.icon(
              onPressed: generateGPS,
              icon: const Icon(Icons.my_location),
              label: const Text("Generate GPS"),
            ),

            const SizedBox(height: 20),

            // ================= DETAILS =================
            const Text("Property Details",
                style: TextStyle(fontWeight: FontWeight.bold)),

            Row(
              children: [
                Expanded(child: _field(bedrooms, "Bedrooms")),
                const SizedBox(width: 10),
                Expanded(child: _field(bathrooms, "Bathrooms")),
              ],
            ),

            _field(sizeSqm, "Size (sqm)"),
            _field(price, "Price"),

            const SizedBox(height: 20),

            // ================= IMAGES =================
            const Text("Images",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                // existing images
                if (widget.property?.images != null)
                  ...widget.property!.images.map(
                    (img) => Image.network(
                      img.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),

                // new images
                ...images.map(
                  (img) => Image.network(
                    img.path,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: pickImages,
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mangoOrange,
              ),
              child: Text(isEdit ? "Update Property" : "Create Property"),
            )
          ],
        ),
      ),
    );
  }
}