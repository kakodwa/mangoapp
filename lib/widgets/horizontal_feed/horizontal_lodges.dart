import 'package:flutter/material.dart';

import '../../models/lodge_model.dart';
import '../hospitality/lodge_card.dart';

class HorizontalLodges extends StatefulWidget {
  final List<Lodge> lodges;
  final bool showHeader;

  const HorizontalLodges({
    super.key,
    required this.lodges,
    this.showHeader = true,
  });

  @override
  State<HorizontalLodges> createState() => _HorizontalLodgesState();
}

class _HorizontalLodgesState extends State<HorizontalLodges> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 320, // Scrolls one card width
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 320, // Scrolls one card width
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lodges.isEmpty) {
      return const SizedBox();
    }

    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recommended Lodges",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isDesktop)
                    Row(
                      children: [
                        IconButton(
                          splashRadius: 24,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 28,
                            color: Colors.orange,
                          ),
                          onPressed: _scrollLeft,
                          tooltip: 'Scroll Left',
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          splashRadius: 24,
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 28,
                            color: Colors.orange,
                          ),
                          onPressed: _scrollRight,
                          tooltip: 'Scroll Right',
                        ),
                      ],
                    ),
                ],
              ),
            ),

          SizedBox(
            height: 290,
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.lodges.length,
                  itemBuilder: (_, index) {
                    return SizedBox(
                      width: 320,
                      child: LodgeCard(
                        lodge: widget.lodges[index],
                      ),
                    );
                  },
                ),

                // Floating Extra-Bold Orange Arrows (when section header is hidden)
                if (isDesktop && !widget.showHeader) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 24,
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.orange,
                          size: 36,
                        ),
                        onPressed: _scrollLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 24,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.orange,
                          size: 36,
                        ),
                        onPressed: _scrollRight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}