import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
<<<<<<< HEAD

import '../../widgets/main_app_bar.dart';


import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends ConsumerState<AddProductScreen> {
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD
  // PICK IMAGES
=======
  // PICK MULTIPLE IMAGES
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  // ======================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
<<<<<<< HEAD
        images = picked.length > 4
            ? picked.sublist(0, 4)
            : picked;
=======
        images = picked.length > 4 ? picked.sublist(0, 4) : picked;
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      });
    }
  }

  // ======================
  // SUBMIT
  // ======================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
<<<<<<< HEAD
      AppToast.error(context, 'Please select category');
=======
      AppToast.error(context,'Please select a category');
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      return;
    }

    if (images.isEmpty) {
<<<<<<< HEAD
      AppToast.error(context, 'Please add product images');
=======
      AppToast.error(context,'Please select images');
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      return;
    }

    setState(() => isLoading = true);

    try {
      final product = Product(
        id: 0,
        shopId: 1,
        shopName: shopNameController.text,
        name: nameController.text,
<<<<<<< HEAD
        slug: nameController.text
            .trim()
            .toLowerCase()
            .replaceAll(' ', '-'),
=======
        slug: nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
      // CREATE PRODUCT
=======
      // ======================
      // STEP 1: CREATE PRODUCT
      // ======================
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      final created = await ref
          .read(productActionsProvider)
          .createProduct(product, images.first);

<<<<<<< HEAD
      // UPLOAD MULTIPLE IMAGES
      await ref
          .read(productActionsProvider)
          .uploadProductImages(created.id, images);

      // REFRESH
      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(
          context,
          "Product created successfully",
        );

=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
<<<<<<< HEAD
        AppToast.error(
          context,
          "Error: ${e.toString()}",
        );
=======
        AppToast.error(context,"Error:  ${e.toString()}");
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ======================
<<<<<<< HEAD
  // IMAGE CARD
  // ======================
  Widget imageCard(XFile img) {
    return Stack(
      children: [
        FutureBuilder<Uint8List>(
          future: img.readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade200,
                ),
                child: const CircularProgressIndicator(),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                snapshot.data!,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            );
          },
        ),

        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                images.remove(img);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: const MainAppBar(
        title: 'Add Product',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ======================
              // PRODUCT INFO
              // ======================

              AppTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: nameController,
                type: TextFieldType.text,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Description',
                hint: 'Enter product description',
                controller: descriptionController,
                type: TextFieldType.multiline,
                maxLines: 4,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price',
                      hint: '0.00',
                      controller: priceController,
                      type: TextFieldType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Price required';
                        }

                        if (double.tryParse(value) == null) {
                          return 'Invalid price';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AppTextField(
                      label: 'Stock',
                      hint: '0',
                      controller: stockController,
                      type: TextFieldType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Stock required';
                        }

                        if (int.tryParse(value) == null) {
                          return 'Invalid stock';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Shop Name',
                hint: 'Enter shop name',
                controller: shopNameController,
                type: TextFieldType.text,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Shop name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ======================
              // CATEGORY
              // ======================

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
<<<<<<< HEAD
                validator: (value) {
                  if (value == null) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ======================
              // IMAGES
              // ======================

              const Text(
                "Product Images (Max 4)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...images.map(imageCard),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

                  if (images.length < 4)
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
<<<<<<< HEAD
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.grey.shade600,
                          size: 30,
                        ),
=======
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

<<<<<<< HEAD
              // ======================
              // ACTIVE SWITCH
              // ======================

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  value: isActive,
                  title: const Text(
                    "Product Active",
                  ),
                  subtitle: const Text(
                    "Visible to customers",
                  ),
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ======================
              // BUTTON
              // ======================

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Create Product",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            ],
          ),
        ),
      ),
    );
  }
}