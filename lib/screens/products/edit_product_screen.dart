import 'dart:typed_data';
<<<<<<< HEAD

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

<<<<<<< HEAD
import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_text_field.dart';
=======
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';

import '../../utils/app_toast.dart';
<<<<<<< HEAD
=======
import '../../utils/api_response_handler.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

<<<<<<< HEAD
  const EditProductScreen({
    super.key,
    required this.product,
  });
=======
  const EditProductScreen({super.key, required this.product});
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

  @override
  ConsumerState<EditProductScreen> createState() =>
      _EditProductScreenState();
}

<<<<<<< HEAD
class _EditProductScreenState
    extends ConsumerState<EditProductScreen> {
=======
class _EditProductScreenState extends ConsumerState<EditProductScreen> {
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  List<XFile> images = [];

  @override
  void initState() {
    super.initState();

<<<<<<< HEAD
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
=======
    nameController = TextEditingController(text: widget.product.name);
    descriptionController =
        TextEditingController(text: widget.product.description);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    stockController =
        TextEditingController(text: widget.product.stock.toString());
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

    selectedCategory = widget.product.category;
    isActive = widget.product.isActive;
  }

<<<<<<< HEAD
  // ======================
  // PICK IMAGES
  // ======================

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
  // ======================
  // SUBMIT
  // ======================

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
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

=======
      // 1. UPDATE PRODUCT (PATCH)
      final updatedProduct = await ref
          .read(productActionsProvider)
          .updateProduct(widget.product.id, updatedData);

      // 2. UPLOAD IMAGES ONLY IF NEW ONES SELECTED
      final productId = updatedProduct.id;

      if (productId > 0 && images.isNotEmpty) {
        await ref
            .read(productActionsProvider)
            .uploadProductImages(productId, images);
      }

      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(context,"Product updated successfully");
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

<<<<<<< HEAD
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
                  color: Colors.grey.shade200,
                ),
                child: const CircularProgressIndicator(),
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
=======
  Widget input(TextEditingController c, String label,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.grey.shade100,

      appBar: const MainAppBar(
        title: 'Edit Product',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 24),

              // ======================
              // IMAGES
              // ======================

              const Text(
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
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .add_photo_alternate_outlined,
                          color: Colors.grey.shade600,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

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
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
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
=======
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              input(nameController, "Product Name"),
              input(descriptionController, "Description",
                  type: TextInputType.multiline),
              input(priceController, "Price",
                  type: TextInputType.number),
              input(stockController, "Stock",
                  type: TextInputType.number),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategory = v),
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: pickImages,
                child: const Text("Change Images"),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: images
                    .map(
                      (img) => FutureBuilder<Uint8List>(
                        future: img.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(),
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
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text("Active"),
                value: isActive,
                onChanged: (v) => setState(() => isActive = v),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Product"),
                ),
              ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            ],
          ),
        ),
      ),
    );
  }
}