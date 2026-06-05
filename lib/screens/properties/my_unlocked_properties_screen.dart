// lib/screens/properties/my_unlocked_properties_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/properties_provider.dart';
import 'property_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';

class MyUnlockedPropertiesScreen extends ConsumerWidget {
  const MyUnlockedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Safely watching the existing provider from your file
    final unlockedAsync = ref.watch(userUnlockedPropertiesProvider);
    final width = MediaQuery.of(context).size.width;
    
    // Dynamically choose grid columns based on physical screen real estate
    final crossAxisCount = width < 600 ? 1 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlocked Properties'),
        backgroundColor: const Color(0xFFF5F7FA),
      ),
      body: RefreshIndicator(
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

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
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
      ),
    );
  }
}