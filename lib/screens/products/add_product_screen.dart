import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/main_app_bar.dart';


import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends ConsumerState<AddProductScreen> {
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
  // PICK IMAGES
  // ======================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 4
            ? picked.sublist(0, 4)
            : picked;
      });
    }
  }

  // ======================
  // SUBMIT
  // ======================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      AppToast.error(context, 'Please select category');
      return;
    }

    if (images.isEmpty) {
      AppToast.error(context, 'Please add product images');
      return;
    }

    setState(() => isLoading = true);

    try {
      final product = Product(
        id: 0,
        shopId: 1,
        shopName: shopNameController.text,
        name: nameController.text,
        slug: nameController.text
            .trim()
            .toLowerCase()
            .replaceAll(' ', '-'),
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

      // CREATE PRODUCT
      final created = await ref
          .read(productActionsProvider)
          .createProduct(product, images.first);

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

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          "Error: ${e.toString()}",
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ======================
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
                  color: Theme.of(context).colorScheme.outline.shade200,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.outline.shade100,

      appBar: const MainAppBar(
        title: 'Add Product',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
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

              const SizedBox(height: AppSpacing.md),

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

              const SizedBox(height: AppSpacing.md),

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

                  const SizedBox(width: AppSpacing.sm),

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

              const SizedBox(height: AppSpacing.md),

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

              const SizedBox(height: AppSpacing.md),

              // ======================
              // CATEGORY
              // ======================

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
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
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

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

                  if (images.length < 4)
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.shade300,
                          ),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Theme.of(context).colorScheme.outline.shade600,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

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
                            color: Theme.of(context).colorScheme.surface,
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
            ],
          ),
        ),
      ),
    );
  }
}