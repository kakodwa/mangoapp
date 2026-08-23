// lib/screens/search/global_search_input_bar.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
    this.maxWidth = 1000,
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
    double maxWidth = 1000,
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
  final FocusNode _focusNode = FocusNode();
  static final AnalyticsService _analytics = AnalyticsService();
  
  // Voice Search setup
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void didUpdateWidget(GlobalSearchInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _effectiveController = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
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

  Future<void> _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (val) => setState(() => _isListening = false),
        onStatus: (val) {
          if (val == 'done') setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _effectiveController.text = val.recognizedWords;
              _effectiveController.selection = TextSelection.fromPosition(
                TextPosition(offset: _effectiveController.text.length),
              );
            });
            if (val.finalResult) {
              setState(() => _isListening = false);
              _handleSubmitted(context, val.recognizedWords);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isFocused ? AppColors.mangoOrange : AppColors.mangoOrange.withOpacity(0.8),
            width: _isFocused ? 2.5 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mangoOrange.withOpacity(_isFocused ? 0.25 : 0.12),
              blurRadius: _isFocused ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // Working Leading Search Icon
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 6.0),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused ? AppColors.mangoOrange : Colors.grey.shade400,
                size: 22,
              ),
            ),

            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _effectiveController,
                onChanged: (val) {
                  setState(() {});
                  if (widget.onChanged != null) widget.onChanged!(val);
                },
                onSubmitted: (query) => _handleSubmitted(context, query),
                style: const TextStyle(fontSize: 15, color: AppColors.darkText),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

            // Functional Voice Search Button
            if (_effectiveController.text.isEmpty)
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isListening ? AppColors.mangoOrange : Colors.grey.shade500,
                  size: 22,
                ),
                onPressed: _listenVoice,
                tooltip: 'Voice Search',
              ),

            // Functional Clear Button
            if (_effectiveController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.cancel_rounded, color: Colors.grey, size: 20),
                onPressed: () {
                  _effectiveController.clear();
                  setState(() {});
                  if (widget.onClear != null) widget.onClear!();
                },
              ),

            if (widget.suffixIcon != null) widget.suffixIcon!,

            const SizedBox(width: 4),

            // Interactive Search Button
            InkWell(
              onTap: () {
                _handleSubmitted(context, _effectiveController.text);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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