import 'package:flutter/material.dart';
import '../screens/about/about_screen.dart';
import '../screens/help/help_screen.dart';
import '../theme/app_colors.dart';
<<<<<<< HEAD
import '../theme/design_system/app_spacing.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
=======
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: const Color(0xFFF6F7FB),
      child: Column(
        children: [

<<<<<<< HEAD
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              60,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
=======
          // =========================
          // HEADER
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mangoOrange,
                  AppColors.mangoLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                  ),
                ),
<<<<<<< HEAD
                const SizedBox(width: AppSpacing.md),
                Column(
=======
                const SizedBox(width: 12),
                const Column(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MangoMart',
<<<<<<< HEAD
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Marketplace App',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: Colors.white70,
                          ),
=======
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Marketplace App',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                    ),
                  ],
                ),
              ],
            ),
          ),

<<<<<<< HEAD
          const SizedBox(height: AppSpacing.lg),
=======
          const SizedBox(height: 16),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

          // =========================
          // MENU ITEMS
          // =========================
          _menuItem(
            context: context,
            icon: Icons.info,
            title: "About App",
            color: AppColors.mangoOrange,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),

          _menuItem(
            context: context,
            icon: Icons.help,
            title: "Help & Support",
            color: AppColors.leafGreen,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpSupportScreen(),
                ),
              );
            },
          ),

          const Spacer(),

<<<<<<< HEAD
          // VERSION FOOTER
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              "Version 1.0.0",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
=======
          // =========================
          // VERSION FOOTER
          // =========================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
              ),
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
