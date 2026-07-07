// 1. Dart & Flutter Core Packages
import 'dart:convert'; 
import 'package:flutter/material.dart';

// 2. Third-Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// 3. Project Imports
// Providers
import '../../providers/products_provider.dart';

// Models
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';

// Screens & Layouts
import '../main_tabs_screen.dart';

// Widgets
import '../../widgets/image_crop_picker.dart';
import '../../widgets/web_footer.dart';

// Utils
import '../../utils/app_toast.dart';

// Design System & Theme
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  // ======================
  // VARIANT CONTROLLERS & STATE
  // ======================
  List<LocalProductVariant> variants = [];

  final variantSkuController = TextEditingController();
  final variantWholesalePriceController = TextEditingController();
  final variantWeightController = TextEditingController();
  final variantStockController = TextEditingController();

  final Map<String, TextEditingController> dynamicAttributeControllers = {};

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

  final Map<String, List<String>> categoryFields = {
    'Fashion': ['Color', 'Size', 'Material'],
    'Electronics': ['Color', 'Storage', 'RAM'],
    'Groceries': ['Weight', 'Pack Size'],
    'Vehicles': ['Color', 'Transmission', 'Engine'],
    'Agriculture': ['Weight', 'Variety'],
    'Books & Education': ['Format', 'Language'],
    'Food & Beverages': ['Weight', 'Flavor'],
  };

  List<XFile> images = [];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);
    descriptionController = TextEditingController(text: widget.product.description);
    priceController = TextEditingController(text: widget.product.price.toString());
    stockController = TextEditingController(text: widget.product.stock.toString());
    selectedCategory = widget.product.category;
    isActive = widget.product.isActive;

    if (widget.product.variants != null) {
      variants = List<LocalProductVariant>.from(widget.product.variants!);
    }
  }

  void _showAddVariantDialog(List<String> fields) {
    variantSkuController.clear();
    variantWholesalePriceController.clear();
    variantWeightController.clear();
    variantStockController.clear();

    for (var controller in dynamicAttributeControllers.values) {
      controller.dispose();
    }
    dynamicAttributeControllers.clear();

    for (var field in fields) {
      dynamicAttributeControllers[field] = TextEditingController();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AlertDialog(
              title: Text("Add ${selectedCategory ?? ''} Variant"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: variantSkuController,
                      decoration: const InputDecoration(
                        labelText: "SKU (Optional)",
                        hintText: "e.g. VAR-XYZ-01",
                      ),
                    ),
                    TextField(
                      controller: variantStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Stock Quantity *"),
                    ),
                    TextField(
                      controller: variantWholesalePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Wholesale Price (\$)"),
                    ),
                    TextField(
                      controller: variantWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Weight (Grams)"),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    Text(
                      "Category attributes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...fields.map((fieldName) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: dynamicAttributeControllers[fieldName],
                          decoration: InputDecoration(
                            labelText: fieldName,
                            hintText: "Enter $fieldName",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final Map<String, dynamic> collectedAttributes = {};
                    dynamicAttributeControllers.forEach((key, controller) {
                      if (controller.text.trim().isNotEmpty) {
                        collectedAttributes[key] = controller.text.trim();
                      }
                    });

                    if (variantStockController.text.trim().isEmpty) {
                      AppToast.error(context, "Stock quantity is required for variants.");
                      return;
                    }

                    if (collectedAttributes.isEmpty) {
                      AppToast.error(context, "Please complete at least one category specification.");
                      return;
                    }

                    setState(() {
                      variants.add(
                        LocalProductVariant(
                          sku: variantSkuController.text.trim(),
                          stock: int.tryParse(variantStockController.text) ?? 0,
                          wholesalePrice: double.tryParse(variantWholesalePriceController.text) ?? 0.0,
                          weightG: int.tryParse(variantWeightController.text) ?? 0,
                          attributes: collectedAttributes,
                        ),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Add Variant"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      AppToast.error(context, 'Please select category');
      return;
    }

    setState(() => isLoading = true);

    try {
      final String variantsJsonString = jsonEncode(
        variants.map((v) => v.toJson()).toList(),
      );

      final updatedData = {
        "name": nameController.text,
        "description": descriptionController.text,
        "category": selectedCategory,
        "price": double.parse(priceController.text),
        "stock": int.parse(stockController.text),
        "is_active": isActive,
        "variants": variantsJsonString,
      };

      final updatedProduct = await ref
          .read(productActionsProvider)
          .updateProduct(
            widget.product.id,
            updatedData,
          );

      if (updatedProduct.id > 0 && images.isNotEmpty) {
        await ref
            .read(productActionsProvider)
            .uploadProductImages(
              updatedProduct.id,
              images,
            );
      }

      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(context, "Product updated successfully");
        MainTabsScreen.of(context)?.setSelectedIndex(18);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, "Error: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    variantSkuController.dispose();
    variantWholesalePriceController.dispose();
    variantWeightController.dispose();
    variantStockController.dispose();
    for (var controller in dynamicAttributeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final contentPadding = isDesktop 
        ? EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: AppSpacing.lg)
        : const EdgeInsets.all(AppSpacing.md);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multi-column row on Web/Desktop, single column on Mobile
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: isDesktop ? 3 : 0,
                        child: Column(
                          children: [
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
                          ],
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        flex: isDesktop ? 2 : 0,
                        child: Column(
                          children: [
                            if (!isDesktop) const SizedBox(height: AppSpacing.md),
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
                                      if (value == null || value.trim().isEmpty) {
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
                                      if (value == null || value.trim().isEmpty) {
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                        variants.clear();
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
                  const Text(
                    "New Product Images (Optional)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  ImageCropPicker(
                    maxImages: 4,
                    cropType: CropShapeType.square,
                    initialImages: images,
                    onChanged: (value) {
                      setState(() {
                        images = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Product Variants",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add Variant"),
                        onPressed: selectedCategory == null || !categoryFields.containsKey(selectedCategory)
                            ? null
                            : () => _showAddVariantDialog(categoryFields[selectedCategory]!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (selectedCategory == null)
                    const Text(
                      "Choose a product category above to manage variations.",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    )
                  else if (!categoryFields.containsKey(selectedCategory))
                    const Text(
                      "Item configurations are not mapped for this category.",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    )
                  else if (variants.isEmpty)
                    const Text(
                      "No configuration items configured yet (Optional).",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    )
                  else
                    // Wraps variant cards beautifully on web/tablet grids
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(variants.length, (index) {
                        final variant = variants[index];
                        final attrsText = variant.attributes.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', ');
                        return SizedBox(
                          width: isDesktop ? (screenWidth * 0.7 / 2) - 12 : double.infinity,
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Text("Stock: ${variant.stock} | SKU: ${variant.sku ?? 'Auto'}"),
                              subtitle: Text("Specs: $attrsText\nWholesale: \$${variant.wholesalePrice}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => setState(() => variants.removeAt(index)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SwitchListTile(
                      value: isActive,
                      title: const Text("Product Active"),
                      subtitle: const Text("Visible to customers"),
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.surface,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Update Product",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (isDesktop) const WebFooter(),
          ],
        ),
      ),
    );
  }
}