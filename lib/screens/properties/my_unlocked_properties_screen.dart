// lib/screens/properties/my_unlocked_properties_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/properties_provider.dart';
import 'property_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/web_footer.dart';

class MyUnlockedPropertiesScreen extends ConsumerStatefulWidget {
  const MyUnlockedPropertiesScreen({super.key});

  @override
  ConsumerState<MyUnlockedPropertiesScreen> createState() => _MyUnlockedPropertiesScreenState();
}

class _MyUnlockedPropertiesScreenState extends ConsumerState<MyUnlockedPropertiesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger pagination when scrolling within 300 pixels of the bottom threshold
    if (currentScroll >= maxScroll - 300) {
      // NOTE: If your provider gets converted to a paginated state notifier in the future, 
      // you can safely call your pagination engine hook here:
      // ref.read(userUnlockedPropertiesProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAsync = ref.watch(userUnlockedPropertiesProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    
    // Dynamically choose grid columns based on physical screen real estate
    final crossAxisCount = screenWidth < 600 ? 1 : 2;
    final double horizontalPadding = isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(userUnlockedPropertiesProvider),
      color: AppColors.mangoOrange,
      child: unlockedAsync.when(
        data: (propertiesList) {
          // ================= CENTERED RECTANGLE EMPTY STATE =================
          if (propertiesList.isEmpty) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.12),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.mangoOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_open_outlined,
                                size: 26,
                                color: AppColors.mangoOrange,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              "No Properties Unlocked",
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              "You haven't unlocked any premium property details yet. Contact support or use credits to reveal exclusive listings.",
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: WebFooter(),
                ),
              ],
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Memory-efficient responsive Grid layout using lazy rendering
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: horizontalPadding,
                ),
                sliver: SliverGrid.builder(
                  itemCount: propertiesList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.92, // Prevents layout crowding within card parameters
                  ),
                  itemBuilder: (context, index) {
                    return PropertyCard(property: propertiesList[index]);
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: WebFooter(),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mangoOrange),
        ),
        error: (exception, __) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 26,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "Failed to Load Listings",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          exception.toString(),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: WebFooter(),
            ),
          ],
        ),
      ),
    );
  }
}