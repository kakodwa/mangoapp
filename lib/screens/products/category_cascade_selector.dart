// lib/widgets/category_cascade_selector.dart

import 'package:flutter/material.dart';
import 'product_constants.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';

class CategoryCascadeSelector extends StatefulWidget {
  final String? initialCategory;
  final String? initialSubCategory;
  final String? initialBrand;
  final Function(String category, String subCategory, String brand) onChanged;

  const CategoryCascadeSelector({
    super.key,
    this.initialCategory,
    this.initialSubCategory,
    this.initialBrand,
    required this.onChanged,
  });

  @override
  State<CategoryCascadeSelector> createState() => _CategoryCascadeSelectorState();
}

class _CategoryCascadeSelectorState extends State<CategoryCascadeSelector> {
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedBrand;

  // Custom "Other" controllers
  final customCategoryController = TextEditingController();
  final customSubCategoryController = TextEditingController();
  final customBrandController = TextEditingController();

  bool isCustomCategory = false;
  bool isCustomSubCategory = false;
  bool isCustomBrand = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      if (ProductConstants.categories.contains(widget.initialCategory)) {
        selectedCategory = widget.initialCategory;
      } else {
        selectedCategory = "Other";
        isCustomCategory = true;
        customCategoryController.text = widget.initialCategory!;
      }
    }

    final activeSubCategoryData = ProductConstants.categorySubCategoryBrands[selectedCategory];
    final availableSubCategories = activeSubCategoryData?.keys.toList() ?? [];

    if (widget.initialSubCategory != null && widget.initialSubCategory!.isNotEmpty) {
      if (availableSubCategories.contains(widget.initialSubCategory)) {
        selectedSubCategory = widget.initialSubCategory;
      } else {
        selectedSubCategory = "Other";
        isCustomSubCategory = true;
        customSubCategoryController.text = widget.initialSubCategory!;
      }
    }

    final availableBrands = (selectedSubCategory != null && activeSubCategoryData != null)
        ? (activeSubCategoryData[selectedSubCategory] ?? [])
        : [];

    if (widget.initialBrand != null && widget.initialBrand!.isNotEmpty) {
      if (availableBrands.contains(widget.initialBrand)) {
        selectedBrand = widget.initialBrand;
      } else {
        selectedBrand = "Other";
        isCustomBrand = true;
        customBrandController.text = widget.initialBrand!;
      }
    }
  }

  void _notifyParent() {
    final finalCategory = isCustomCategory ? customCategoryController.text.trim() : (selectedCategory ?? '');
    final finalSubCategory = isCustomSubCategory ? customSubCategoryController.text.trim() : (selectedSubCategory ?? '');
    final finalBrand = isCustomBrand ? customBrandController.text.trim() : (selectedBrand ?? '');

    widget.onChanged(finalCategory, finalSubCategory, finalBrand);
  }

  @override
  void dispose() {
    customCategoryController.dispose();
    customSubCategoryController.dispose();
    customBrandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSubCategoryData = ProductConstants.categorySubCategoryBrands[selectedCategory];
    List<String> availableSubCategories = activeSubCategoryData?.keys.toList() ?? [];
    if (selectedCategory != null && !availableSubCategories.contains("Other")) {
      availableSubCategories.add("Other");
    }

    List<String> availableBrands = (selectedSubCategory != null && activeSubCategoryData != null)
        ? List<String>.from(activeSubCategoryData[selectedSubCategory] ?? [])
        : [];
    if (selectedSubCategory != null && !availableBrands.contains("Other")) {
      availableBrands.add("Other");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Primary Category Dropdown
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category *',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: ProductConstants.categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
              isCustomCategory = (value == "Other");
              selectedSubCategory = null;
              isCustomSubCategory = false;
              selectedBrand = null;
              isCustomBrand = false;
              customCategoryController.clear();
              customSubCategoryController.clear();
              customBrandController.clear();
            });
            _notifyParent();
          },
          validator: (val) => val == null ? 'Please select a category' : null,
        ),

        // Custom Category Free-Text Field
        if (isCustomCategory) ...[
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Custom Category Name *',
            hint: 'Specify your custom category',
            controller: customCategoryController,
            type: TextFieldType.text,
            isRequired: true,
            onChanged: (_) => _notifyParent(),
          ),
        ],

        // 2. Subcategory Dropdown
        if (selectedCategory != null && (availableSubCategories.isNotEmpty || isCustomCategory)) ...[
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: availableSubCategories.contains(selectedSubCategory) ? selectedSubCategory : null,
            decoration: InputDecoration(
              labelText: 'Subcategory *',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: availableSubCategories.map((sub) {
              return DropdownMenuItem(value: sub, child: Text(sub));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubCategory = value;
                isCustomSubCategory = (value == "Other");
                selectedBrand = null;
                isCustomBrand = false;
                customSubCategoryController.clear();
                customBrandController.clear();
              });
              _notifyParent();
            },
            validator: (val) => val == null ? 'Please select a subcategory' : null,
          ),
        ],

        // Custom Subcategory Free-Text Field
        if (isCustomSubCategory) ...[
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Custom Subcategory Name *',
            hint: 'Specify your custom subcategory',
            controller: customSubCategoryController,
            type: TextFieldType.text,
            isRequired: true,
            onChanged: (_) => _notifyParent(),
          ),
        ],

        // 3. Brand Dropdown
        if (selectedSubCategory != null && (availableBrands.isNotEmpty || isCustomSubCategory)) ...[
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: availableBrands.contains(selectedBrand) ? selectedBrand : null,
            decoration: InputDecoration(
              labelText: 'Brand *',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: availableBrands.map((b) {
              return DropdownMenuItem(value: b, child: Text(b));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBrand = value;
                isCustomBrand = (value == "Other");
                customBrandController.clear();
              });
              _notifyParent();
            },
            validator: (val) => val == null ? 'Please select a brand' : null,
          ),
        ],

        // Custom Brand Free-Text Field
        if (isCustomBrand) ...[
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Custom Brand Name *',
            hint: 'Specify your brand',
            controller: customBrandController,
            type: TextFieldType.text,
            isRequired: true,
            onChanged: (_) => _notifyParent(),
          ),
        ],
      ],
    );
  }
}