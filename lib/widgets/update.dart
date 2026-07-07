import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../screens/auth/register_screen.dart'; // Make sure to import your RegisterScreen file path

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
                  '🛍️ Find amazing local products with secure checkout •  🚚 Fast delivery straight to your doorstep •  🚀 Create an account to start listing, shopping, and tracking your orders! •',
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
          const SizedBox(width: 8),
          // Added a Join/Register CTA button directly on the ticker bar
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1, size: 14),
            label: const Text(
              "Join",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}