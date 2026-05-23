import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Unified Search Bar Widget - Used across all screens
/// Provides consistent styling for search functionality
class UnifiedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final Color? bgColor;
  final Color? shadowColor;

  const UnifiedSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.bgColor,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (shadowColor ?? Colors.black).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search, size: 22),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onClear ??
                        () {
                          controller.clear();
                          onChanged('');
                        },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}

/// Unified Filter Chip Widget - Consistent styling across all screens
/// Handles both selected and unselected states
class UnifiedFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const UnifiedFilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor:
            selectedColor ?? AppColors.mangoOrange.withOpacity(0.15),
        backgroundColor: unselectedColor ?? Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? (selectedTextColor ?? AppColors.mangoOrange)
              : (unselectedTextColor ?? Colors.black87),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: selected
            ? BorderSide(
                color: selectedTextColor ?? AppColors.mangoOrange,
                width: 0.5,
              )
            : BorderSide(
                color: Colors.grey[300]!,
                width: 0.5,
              ),
      ),
    );
  }
}

/// Horizontal scrollable filter chips list
class UnifiedChipList extends StatelessWidget {
  final List<String> items;
  final String selected;
  final Function(String) onSelect;
  final double? height;
  final EdgeInsets? padding;
  final Color? selectedColor;
  final Color? textColor;

  const UnifiedChipList({
    Key? key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.height,
    this.padding,
    this.selectedColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return UnifiedFilterChip(
            label: item,
            selected: selected == item,
            onTap: () => onSelect(item),
            selectedColor: selectedColor,
            selectedTextColor: textColor,
          );
        },
      ),
    );
  }
}

/// Unified section title for filter groups
class UnifiedFilterSectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const UnifiedFilterSectionTitle({
    Key? key,
    required this.title,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// Unified Clear Filters Button
class UnifiedClearButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool show;

  const UnifiedClearButton({
    Key? key,
    required this.onPressed,
    required this.show,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.clear, size: 18),
        label: const Text("Clear filters"),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mangoOrange,
        ),
      ),
    );
  }
}

/// Unified District Dropdown - consistent across screens
class UnifiedDistrictDropdown extends StatelessWidget {
  final List<String> districts;
  final String selected;
  final Function(String) onChanged;
  final EdgeInsets? padding;

  const UnifiedDistrictDropdown({
    Key? key,
    required this.districts,
    required this.selected,
    required this.onChanged,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selected,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            items: districts.map((district) {
              return DropdownMenuItem(
                value: district,
                child: Text(
                  district,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
      ),
    );
  }
}

/// Collapsible filter panel - used in Shops screen
class UnifiedCollapsibleFilterPanel extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;
  final Color? toggleColor;

  const UnifiedCollapsibleFilterPanel({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.toggleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: child,
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Filter toggle button - used in search bar row
class UnifiedFilterToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;
  final Color? color;

  const UnifiedFilterToggle({
    Key? key,
    required this.isExpanded,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          isExpanded ? Icons.filter_alt : Icons.filter_alt_outlined,
          color: color ?? AppColors.mangoOrange,
          size: 24,
        ),
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
