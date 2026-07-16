// lib/screens/properties/my_unlocked_properties_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/properties_provider.dart';
import 'property_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
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
      child: unlockedAsync.when(
        data: (propertiesList) {
          if (propertiesList.isEmpty) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Centered Empty State Layout with context-specific Premium Unlock Icon
                      Icon(
                        Icons.lock_open_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No premium properties unlocked',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Text(
                          "You haven't unlocked any premium properties yet. Contact support or use credits to reveal premium listings.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Web footer stays at the very bottom edge even during empty state
                      const WebFooter(),
                    ],
                  ),
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

              // Layout spacer bridge ensuring nice visual padding before footer bounds appear
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),

              // ================= WEB FOOTER =================
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Failed to load listings: $exception',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  const Spacer(),
                  const WebFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}