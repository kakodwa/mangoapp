import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class UpdatesTicker extends StatelessWidget {
  const UpdatesTicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          const Icon(
            Icons.campaign,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Marquee(
              text:
                  '🔥 New products available • 🚚 Free delivery in Mangochi • 🎉 Special discounts this week •',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              scrollAxis: Axis.horizontal,
              blankSpace: 100,
              velocity: 40,
              pauseAfterRound: const Duration(seconds: 1),
            ),
          ),
        ],
      ),
    );
  }
}


class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  final List<String> updates = [
    "🚚 Delivery now available",
    "🔥 New products added",
    "🎉 Weekend discounts",
    "💰 Secure escrow payments",
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % updates.length;
        });
      }
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                updates[currentIndex],
                key: ValueKey(currentIndex),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}