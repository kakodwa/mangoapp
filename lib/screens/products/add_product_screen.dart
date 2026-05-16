import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';

import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final shopNameController = TextEditingController();

  bool isActive = true;
  bool isLoading = false;

  final List<String> categories = [
    "Electronics",
    "Fashion",
    "Groceries",
    "Home",
    "Beauty",
  ];

  String? selectedCategory;

  final ImagePicker picker = ImagePicker();
  List<XFile> images = [];

  // ======================
  // PICK MULTIPLE IMAGES
  // ======================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 4 ? picked.sublist(0, 4) : picked;
      });
    }
  }

  // ======================
  // SUBMIT
  // ======================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      AppToast.error(context,'Please select a category');
      return;
    }

    if (images.isEmpty) {
      AppToast.error(context,'Please select images');
      return;
    }

    setState(() => isLoading = true);

    try {
      final product = Product(
        id: 0,
        shopId: 1,
        shopName: shopNameController.text,
        name: nameController.text,
        slug: nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
        description: descriptionController.text,
        image: null,
        category: selectedCategory!,
        price: double.parse(priceController.text),
        originalPrice: null,
        discountPercentage: 0,
        stock: int.parse(stockController.text),
        sku: "",
        isActive: isActive,
        rating: 0.0,
        totalReviews: 0,
        createdAt: DateTime.now(),
      );

      // ======================
      // STEP 1: CREATE PRODUCT
      // ======================
      final created = await ref
          .read(productActionsProvider)
          .createProduct(product, images.first);

      // ======================
      // STEP 2: UPLOAD ALL IMAGES
      // ======================
      print("IMAGES BEFORE UPLOAD:");
      for (var i = 0; i < images.length; i++) {
        print("Image $i: ${images[i].name}");
      }
      final uploadList = List<XFile>.from(images);
      await ref.read(productActionsProvider).uploadProductImages(created.id, uploadList);

      // refresh products
      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(context,"Product created successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context,"Error:  ${e.toString()}");
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ======================
  // INPUT FIELD
  // ======================
  Widget inputField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Add Product'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              inputField(nameController, "Product Name"),
              inputField(descriptionController, "Description", maxLines: 3),
              inputField(priceController, "Price", type: TextInputType.number),
              inputField(stockController, "Stock", type: TextInputType.number),
              inputField(shopNameController, "Shop Name"),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Category is required" : null,
              ),

              const SizedBox(height: 15),

              const Text(
                "Product Images (max 4)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // ======================
              // IMAGE PREVIEW GRID
              // ======================
              Wrap(
                spacing: 10,
                children: [
                  ...images.map((img) => Stack(
                        children: [
                          FutureBuilder<Uint8List>(
                            future: img.readAsBytes(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              return Image.memory(
                                snapshot.data!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  images.remove(img);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      )),

                  if (images.length < 4)
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text("Active"),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Product"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}