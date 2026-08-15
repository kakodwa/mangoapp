// lib/screens/search/global_search_input_bar.dart

import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../main_tabs_screen.dart';

class GlobalSearchInputBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Widget? suffixIcon;
  final double maxWidth;
  final String analyticsEventName;
  final int searchTabIndex;

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

  @override
  State<GlobalSearchInputBar> createState() => _GlobalSearchInputBarState();
}

class _GlobalSearchInputBarState extends State<GlobalSearchInputBar> {
  late TextEditingController _effectiveController;
  static final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(GlobalSearchInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _effectiveController = widget.controller ?? TextEditingController();
    }
  }

  void _handleSubmitted(BuildContext context, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      _analytics.logEvent(widget.analyticsEventName);

      if (widget.onSubmitted != null) {
        widget.onSubmitted!(trimmedQuery);
      } else {
        MainTabsScreen.of(context)?.setSelectedIndex(
          widget.searchTabIndex,
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
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.mangoOrange,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mangoOrange.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 18, right: 6, top: 6, bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _effectiveController,
                onChanged: (val) {
                  setState(() {}); // Re-render for clear button visibility
                  if (widget.onChanged != null) widget.onChanged!(val);
                },
                onSubmitted: (query) => _handleSubmitted(context, query),
                style: TextStyle(fontSize: 15, color: AppColors.darkText),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

            if (widget.suffixIcon != null)
              widget.suffixIcon!
            else if (_effectiveController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _effectiveController.clear();
                  setState(() {});
                  if (widget.onClear != null) widget.onClear!();
                },
              ),

            const SizedBox(width: 4),

            InkWell(
              onTap: () {
                _handleSubmitted(context, _effectiveController.text);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.mangoLight, AppColors.mangoOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}