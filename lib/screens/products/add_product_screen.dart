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

  String? selectedCategory;

  List<XFile> images = [];

  // ======================
  // SUBMIT
  // ======================

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      AppToast.error(
        context,
        'Please select category',
      );
      return;
    }

    if (images.isEmpty) {
      AppToast.error(
        context,
        'Please add product images',
      );
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
        price: double.parse(
          priceController.text,
        ),
        originalPrice: null,
        discountPercentage: 0,
        stock: int.parse(
          stockController.text,
        ),
        sku: "",
        isActive: isActive,
        rating: 0.0,
        totalReviews: 0,
        createdAt: DateTime.now(),
      );

      // CREATE PRODUCT
      final created = await ref
          .read(productActionsProvider)
          .createProduct(
            product,
            images.first,
          );

      // UPLOAD MULTIPLE IMAGES
      await ref
          .read(productActionsProvider)
          .uploadProductImages(
            created.id,
            images,
          );

      // REFRESH PRODUCTS
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    shopNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ),

      appBar: const MainAppBar(
        title: 'Add Product',
      ),

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
                      value.trim().isEmpty) {
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
                          TextFieldType.number,
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
                          TextFieldType.number,
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
              // SHOP NAME
              // ======================

              AppTextField(
                label: 'Shop Name',
                hint: 'Enter shop name',
                controller:
                    shopNameController,
                type: TextFieldType.text,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Shop name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ======================
              // CATEGORY
              // ======================

              DropdownButtonFormField<String>(
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

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ======================
              // IMAGES
              // ======================

              Text(
                "Product Images (Max 4)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              ImageCropPicker(
                maxImages: 4,

                // PRODUCTS = SQUARE
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
                height: AppSpacing.md,
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
              // SUBMIT BUTTON
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
                          "Create Product",
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