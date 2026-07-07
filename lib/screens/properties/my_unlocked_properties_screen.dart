// lib/screens/properties/my_unlocked_properties_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/properties_provider.dart';
import 'property_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/web_footer.dart';

class MyUnlockedPropertiesScreen extends ConsumerWidget {
  const MyUnlockedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safely watching the existing provider from your file
    final unlockedAsync = ref.watch(userUnlockedPropertiesProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    
    // Dynamically choose grid columns based on physical screen real estate
    final crossAxisCount = screenWidth < 600 ? 1 : 2;

    // Removed standalone Scaffold component layer and top AppBar rendering widgets.
    // The view layer mounts inside the core MainTabsScreen stack panel framework.
    return RefreshIndicator(
      // Pull down to manually fetch newly cleared unlocks from Django
      onRefresh: () async => ref.refresh(userUnlockedPropertiesProvider),
      child: unlockedAsync.when(
        data: (propertiesList) {
          if (propertiesList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open, size: 64, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'You haven\'t unlocked any premium properties yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  // Adapts dynamic margins to safely center the content grid stacks on desktop views
                  horizontal: isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: propertiesList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.92, // Prevents layout crowding within card parameters
                        ),
                        itemBuilder: (context, index) {
                          final currentProperty = propertiesList[index];
                          return PropertyCard(property: currentProperty);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Layout spacer bridge ensuring nice visual padding before footer bounds appear
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),

              // ================= WEB FOOTER =================
              // Attaches to the root scrolling layout tree smoothly at the absolute viewport end
              const SliverToBoxAdapter(
                child: WebFooter(),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mangoOrange),
        ),
        error: (exception, __) => Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Failed to load listings: $exception'),
            ),
          ),
        ),
      ),
    );
  }
}