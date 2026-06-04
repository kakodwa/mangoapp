import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../../widgets/image_crop_picker.dart';
import '../../widgets/main_app_bar.dart';

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

  List<XFile> images = [];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product.name,
    );

    descriptionController =
        TextEditingController(
      text: widget.product.description,
    );

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );

    selectedCategory =
        widget.product.category;

    isActive = widget.product.isActive;
  }

  // ======================
  // SUBMIT
  // ======================

  Future<void> submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (selectedCategory == null) {
      AppToast.error(
        context,
        'Please select category',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final updatedData = {
        "name": nameController.text,
        "description":
            descriptionController.text,
        "category": selectedCategory,
        "price": double.parse(
          priceController.text,
        ),
        "stock": int.parse(
          stockController.text,
        ),
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
      if (updatedProduct.id > 0 &&
          images.isNotEmpty) {
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(title: const Text('Edit Product'),),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
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
                      value
                          .trim()
                          .isEmpty) {
                    return 'Product name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ======================
              // DESCRIPTION
              // ======================

              AppTextField(
                label: 'Description',
                hint:
                    'Enter product description',
                controller:
                    descriptionController,
                type:
                    TextFieldType.multiline,
                maxLines: 4,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Description is required';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ======================
              // PRICE + STOCK
              // ======================

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price',
                      hint: '0.00',
                      controller:
                          priceController,
                      type:
                          TextFieldType
                              .number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Price required';
                        }

                        if (double.tryParse(
                                value) ==
                            null) {
                          return 'Invalid price';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Expanded(
                    child: AppTextField(
                      label: 'Stock',
                      hint: '0',
                      controller:
                          stockController,
                      type:
                          TextFieldType
                              .number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Stock required';
                        }

                        if (int.tryParse(
                                value) ==
                            null) {
                          return 'Invalid stock';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ======================
              // CATEGORY
              // ======================

              DropdownButtonFormField<
                  String>(
                value: selectedCategory,

                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor:
                      Theme.of(context)
                          .colorScheme
                          .surface,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                items:
                    categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedCategory =
                        value;
                  });
                },

                validator: (value) {
                  if (value == null) {
                    return 'Please select category';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ======================
              // IMAGES
              // ======================

              Text(
                "New Product Images (Optional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              ImageCropPicker(
                maxImages: 4,

                cropType:
                    CropShapeType.square,

                initialImages: images,

                onChanged: (value) {
                  setState(() {
                    images = value;
                  });
                },
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ======================
              // ACTIVE SWITCH
              // ======================

              Card(
                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
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
                  onPressed:
                      isLoading
                          ? null
                          : submit,

                  style:
                      ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  child: isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            color:
                                Theme.of(
                                      context,
                                    )
                                    .colorScheme
                                    .surface,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Update Product",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w600,
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