import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';

import '../../models/product_model.dart';
import '../../providers/products_provider.dart';

import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
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

    nameController = TextEditingController(text: widget.product.name);
    descriptionController =
        TextEditingController(text: widget.product.description);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    stockController =
        TextEditingController(text: widget.product.stock.toString());

    selectedCategory = widget.product.category;
    isActive = widget.product.isActive;
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images = picked.length > 4 ? picked.sublist(0, 4) : picked;
      });
    }
  }

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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ],
          ),
        ),
      ),
    );
  }
}