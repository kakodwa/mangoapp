import 'package:flutter/material.dart';


import '../../services/analytics_service.dart';
import '../main_tabs_screen.dart';

class GlobalSearchInputBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Widget? suffixIcon;
  final double maxWidth;
  final String analyticsEventName;
  final int searchTabIndex;

  static final AnalyticsService _analytics = AnalyticsService();

  const GlobalSearchInputBar({
    super.key,
    this.hintText = 'Search products, shops, lodges, properties...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suffixIcon,
    this.maxWidth = 1200,
    this.analyticsEventName = 'home_search_submit',
    this.searchTabIndex = 7,
  });

  /// Factory helper to conveniently render directly inside a [CustomScrollView]
  static Widget sliver({
    Key? key,
    String hintText = 'Search products, shops, lodges, properties...',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onClear,
    Widget? suffixIcon,
    double maxWidth = 1200,
    String analyticsEventName = 'home_search_submit',
    int searchTabIndex = 7,
  }) {
    return SliverToBoxAdapter(
      key: key,
      child: GlobalSearchInputBar(
        hintText: hintText,
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onClear: onClear,
        suffixIcon: suffixIcon,
        maxWidth: maxWidth,
        analyticsEventName: analyticsEventName,
        searchTabIndex: searchTabIndex,
      ),
    );
  }

  void _handleSubmitted(BuildContext context, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      _analytics.logEvent(analyticsEventName);

      // Execute custom callback if provided
      if (onSubmitted != null) {
        onSubmitted!(trimmedQuery);
      } else {
        // Fallback default navigation behavior
        MainTabsScreen.of(context)?.setSelectedIndex(
        searchTabIndex,
        searchQuery: trimmedQuery,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (query) => _handleSubmitted(context, query),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: suffixIcon ??
                (controller != null && controller!.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          controller!.clear();
                          if (onClear != null) onClear!();
                        },
                      )
                    : null),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}