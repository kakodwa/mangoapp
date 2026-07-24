// lib/screens/products/add_product_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'product_constants.dart';
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../providers/products_provider.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import 'category_cascade_selector.dart';
import '../../widgets/image_crop_picker.dart';
import '../../widgets/web_footer.dart';
import '../main_tabs_screen.dart';

class CategoryAttributeInput extends StatefulWidget {
  final String label;
  final Function(List<String>) onChanged;

  const CategoryAttributeInput({
    super.key,
    required this.label,
    required this.onChanged,
  });

  @override
  State<CategoryAttributeInput> createState() => _CategoryAttributeInputState();
}

class _CategoryAttributeInputState extends State<CategoryAttributeInput> {
  final List<String> _tags = [];
  final TextEditingController _controller = TextEditingController();

  void _addTag(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _controller.clear();
      });
      widget.onChanged(_tags);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "${widget.label} Options (Type value & press Enter)",
            hintText: "e.g., Red, Blue, or N/A",
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _addTag("N/A"),
                  child: const Text("N/A", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _addTag(_controller.text),
                ),
              ],
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: _addTag,
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _tags
                .map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() => _tags.remove(tag));
                        widget.onChanged(_tags);
                      },
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Key to force resetting child widgets like CategoryCascadeSelector
  Key _categorySelectorKey = UniqueKey();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final shopNameController = TextEditingController(text: 'shop');

  List<LocalProductVariant> variants = [];

  bool isActive = true;
  bool isLoading = false;

  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedBrand;
  String selectedDelivery = '1 - 2 Business Days';

  List<XFile> images = [];

  // 🧹 Helper method to completely reset all form inputs and state
  void _resetForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    stockController.clear();

    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      selectedBrand = null;
      selectedDelivery = '1 - 2 Business Days';
      variants = [];
      images = [];
      isActive = true;
      _categorySelectorKey = UniqueKey(); // Re-creates CategoryCascadeSelector clean state
    });
  }

  List<Map<String, String>> generateCombinations(Map<String, List<String>> attributes) {
    List<Map<String, String>> combinations = [{}];

    attributes.forEach((key, values) {
      if (values.isEmpty) return;
      List<Map<String, String>> temp = [];
      for (var combination in combinations) {
        for (var value in values) {
          final newCombination = Map<String, String>.from(combination);
          newCombination[key] = value;
          temp.add(newCombination);
        }
      }
      combinations = temp;
    });

    return combinations;
  }

  void _showGenerateVariantsDialog(List<String> fields) {
    final Map<String, List<String>> selectedAttributeTags = {};
    final defaultStockController = TextEditingController(text: stockController.text.isNotEmpty ? stockController.text : '10');
    final defaultWholesalePriceController = TextEditingController(text: '0.0');

    for (var field in fields) {
      selectedAttributeTags[field] = [];
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AlertDialog(
              title: Text("Batch Generate ${selectedCategory ?? ''} Variants"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: defaultStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Default Stock per Variant *"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: defaultWholesalePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Default Wholesale Price (MWK) *"),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider()),
                    ...fields.map((field) {
                      return CategoryAttributeInput(
                        label: field,
                        onChanged: (tags) => selectedAttributeTags[field] = tags,
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    final combinations = generateCombinations(selectedAttributeTags);
                    if (combinations.isEmpty || combinations.first.isEmpty) {
                      AppToast.error(context, "Please add tags for at least one attribute.");
                      return;
                    }

                    final int defaultStock = int.tryParse(defaultStockController.text) ?? 0;
                    final double defaultPrice = double.tryParse(defaultWholesalePriceController.text) ?? 0.0;

                    setState(() {
                      for (var combo in combinations) {
                        variants.add(
                          LocalProductVariant(
                            sku: null,
                            stock: defaultStock,
                            wholesalePrice: defaultPrice,
                            weightG: 0,
                            attributes: combo,
                          ),
                        );
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Generate All Combinations"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editVariant(int index) {
    final variant = variants[index];
    final stockCtrl = TextEditingController(text: variant.stock.toString());
    final priceCtrl = TextEditingController(text: variant.wholesalePrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Option: ${variant.formattedAttributes}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock Quantity *"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Wholesale Price (MWK)"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  variants[index] = LocalProductVariant(
                    sku: variant.sku,
                    stock: int.tryParse(stockCtrl.text) ?? variant.stock,
                    wholesalePrice: double.tryParse(priceCtrl.text) ?? variant.wholesalePrice,
                    weightG: variant.weightG,
                    attributes: variant.attributes,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      AppToast.error(context, 'Please select category');
      return;
    }

    if (images.isEmpty) {
      AppToast.error(context, 'Please upload at least one image for this product.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final product = Product(
        id: 0,
        shopId: 1,
        shopName: shopNameController.text.trim(),
        name: nameController.text,
        slug: nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
        description: descriptionController.text,
        image: null,
        category: selectedCategory!,
        subCategory: selectedSubCategory ?? '',
        brand: selectedBrand ?? '',
        deliveryDuration: selectedDelivery,
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

      final created = await ref.read(productActionsProvider).createProduct(product, images.first, variants);
      await ref.read(productActionsProvider).uploadProductImages(created.id, images);

      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(context, "Product created successfully");
        _resetForm(); // 🧼 Clear out state and form fields
        MainTabsScreen.of(context)?.navigateToAddProduct();
      }
    } catch (e) {
      if (mounted) AppToast.error(context, "Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final contentPadding = isDesktop
        ? EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: AppSpacing.lg)
        : const EdgeInsets.all(AppSpacing.md);

    final fields = ProductConstants.categoryFields[selectedCategory] ?? ProductConstants.categoryFields['Other']!;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  label: 'Description',
                                  hint: 'Enter product description',
                                  controller: descriptionController,
                                  type: TextFieldType.multiline,
                                  maxLines: 4,
                                  isRequired: true,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
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
                                        label: 'Price (MWK)',
                                        hint: '0.00',
                                        controller: priceController,
                                        type: TextFieldType.number,
                                        isRequired: true,
                                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid price' : null,
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
                                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Invalid stock' : null,
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

                      CategoryCascadeSelector(
                        key: _categorySelectorKey, // Reset key forces redrawing category dropdowns
                        onChanged: (cat, subCat, brand) {
                          setState(() {
                            selectedCategory = cat;
                            selectedSubCategory = subCat;
                            selectedBrand = brand;
                            variants.clear();
                          });
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      DropdownButtonFormField<String>(
                        value: selectedDelivery,
                        decoration: InputDecoration(
                          labelText: 'Estimated Delivery Time *',
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ProductConstants.deliveryOptions.map((opt) {
                          return DropdownMenuItem(value: opt, child: Text(opt));
                        }).toList(),
                        onChanged: (value) => setState(() => selectedDelivery = value!),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const Text("Product Images (Max 4 - Required *)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      ImageCropPicker(
                        key: ValueKey(images.length), // Rebuilds picker when reset
                        maxImages: 4,
                        cropType: CropShapeType.square,
                        initialImages: images,
                        onChanged: (v) => setState(() => images = v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Product Variants (${variants.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              if (variants.isNotEmpty)
                                TextButton(
                                  onPressed: () => setState(() => variants.clear()),
                                  child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
                                ),
                              TextButton.icon(
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text("Generate Matrix"),
                                onPressed: selectedCategory == null || selectedCategory!.isEmpty
                                    ? null
                                    : () => _showGenerateVariantsDialog(fields),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (selectedCategory == null || selectedCategory!.isEmpty)
                        const Text("Choose a product category above to manage variations.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                      else if (variants.isEmpty)
                        const Text("No variations generated yet. Click 'Generate Matrix' to auto-create size/color combinations.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                      else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Tap any card or edit icon below to customize stock or price for specific sizes/colors.",
                                  style: TextStyle(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List.generate(variants.length, (index) {
                            final variant = variants[index];
                            return SizedBox(
                              width: isDesktop ? (screenWidth * 0.7 / 2) - 12 : double.infinity,
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: ListTile(
                                  onTap: () => _editVariant(index),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  title: Text(variant.formattedAttributes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text("Stock: ${variant.stock} | Wholesale: MWK ${variant.wholesalePrice}", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: "Edit stock or price",
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                        onPressed: () => _editVariant(index),
                                      ),
                                      IconButton(
                                        tooltip: "Remove option",
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () => setState(() => variants.removeAt(index)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.md),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: SwitchListTile(
                          value: isActive,
                          title: const Text("Product Active"),
                          subtitle: const Text("Visible to customers"),
                          onChanged: (v) => setState(() => isActive = v),
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
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text("Create Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) const WebFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}