import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_text_field.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';

import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  bool isActive = true;
  bool isLoading = false;

  String? selectedCategory;

  final List<String> categories = [
    "Electronics",
    "Fashion",
    "Groceries",
    "Home",
    "Beauty",
  ];

  final ImagePicker picker = ImagePicker();

  List<XFile> images = [];

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.product.name);

    descriptionController = TextEditingController(
      text: widget.product.description,
    );

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );

    selectedCategory = widget.product.category;
    isActive = widget.product.isActive;
  }

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

    setState(() => isLoading = true);

    try {
      final updatedData = {
        "name": nameController.text,
        "description": descriptionController.text,
        "category": selectedCategory,
        "price": double.parse(priceController.text),
        "stock": int.parse(stockController.text),
        "is_active": isActive,
      };

      // UPDATE PRODUCT
      final updatedProduct = await ref
          .read(productActionsProvider)
          .updateProduct(
            widget.product.id,
            updatedData,
          );

      // UPLOAD NEW IMAGES
      if (updatedProduct.id > 0 && images.isNotEmpty) {
        await ref
            .read(productActionsProvider)
            .uploadProductImages(
              updatedProduct.id,
              images,
            );
      }

      // REFRESH PRODUCTS
      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(
          context,
          "Product updated successfully",
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
                  borderRadius:
                      BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                ),
                child: CircularProgressIndicator(),
              );
            }

            return ClipRRect(
              borderRadius:
                  BorderRadius.circular(14),
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
              padding: EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
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
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

      appBar: const MainAppBar(
        title: 'Edit Product',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // ======================
              // PRODUCT NAME
              // ======================

              AppTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: nameController,
                type: TextFieldType.text,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Product name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // DESCRIPTION
              // ======================

              AppTextField(
                label: 'Description',
                hint: 'Enter product description',
                controller: descriptionController,
                type: TextFieldType.multiline,
                maxLines: 4,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Description is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ======================
              // PRICE + STOCK
              // ======================

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

                        if (double.tryParse(value) ==
                            null) {
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

                        if (int.tryParse(value) ==
                            null) {
                          return 'Invalid stock';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
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
                    borderRadius:
                        BorderRadius.circular(12),
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

              Text(
                "New Product Images (Optional)",
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
                            color:
                                Theme.of(context).colorScheme.outline.withOpacity(0.38),
                          ),
                        ),
                        child: Icon(
                          Icons
                              .add_photo_alternate_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // ======================
              // ACTIVE SWITCH
              // ======================

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  value: isActive,
                  title: Text(
                    "Product Active",
                  ),
                  subtitle: Text(
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
                  onPressed:
                      isLoading ? null : submit,
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
                          child:
                              CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.surface,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Update Product",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
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