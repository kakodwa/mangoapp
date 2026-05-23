import 'package:flutter/material.dart';

import 'create_lodge_screen.dart';
import 'my_lodges_screen.dart';
import '../../theme/design_system/app_spacing.dart';

class LodgeOwnerDashboard extends StatelessWidget {
  const LodgeOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lodge Dashboard'),
      ),

      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(AppSpacing.md),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,

        children: [

          _DashboardCard(
            title: 'Bookings',
            icon: Icons.book_online,
            onTap: () {
              // TODO: navigate bookings screen
            },
          ),

          _DashboardCard(
            title: 'Rooms',
            icon: Icons.hotel,
            onTap: () {
              // TODO: rooms screen
            },
          ),

          _DashboardCard(
            title: 'Revenue',
            icon: Icons.attach_money,
            onTap: () {
              // TODO: revenue screen
            },
          ),

          _DashboardCard(
            title: 'Guests',
            icon: Icons.people,
            onTap: () {
              // TODO: guests screen
            },
          ),

          // ✅ CREATE LODGE
          _DashboardCard(
            title: 'Create Lodge',
            icon: Icons.add_business,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateLodgeScreen(),
                ),
              );
            },
          ),

          // ✅ MY LODGES
          _DashboardCard(
            title: 'My Lodges',
            icon: Icons.apartment,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyLodgesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _DashboardCard({
    required this.title,
    required this.icon,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(14),

      child: Card(
        elevation: 2,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 48,
              color: color ?? Colors.black87,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              title,

              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}