// lib/screens/hospitality/my_lodges_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart' as auth;
import '../../providers/api_provider.dart';

import '../../models/lodge_model.dart';
import '../../widgets/hospitality/lodge_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/web_footer.dart';

import '../main_tabs_screen.dart';
import '../../theme/app_colors.dart';
import '../../utils/price_helper.dart';

class MyLodgesScreen extends ConsumerStatefulWidget {
  const MyLodgesScreen({super.key});

  @override
  ConsumerState<MyLodgesScreen> createState() => _MyLodgesScreenState();
}

class _MyLodgesScreenState extends ConsumerState<MyLodgesScreen> {
  bool isLoading = true;
  List<Lodge> lodges = [];

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 INIT STATE CALLED");
    fetchMyLodges();
  }

  Future<void> fetchMyLodges() async {
    try {
      debugPrint("📡 FETCH MY LODGES STARTED");

      setState(() => isLoading = true);

      final api = ref.read(apiClientProvider);

      debugPrint("🌐 CALLING API: lodges/my_lodges/");

      final response = await api.getList<Lodge>(
        "lodges/my_lodges/",
        fromJson: (json) {
          debugPrint("📦 PARSING LODGE JSON: $json");
          return Lodge.fromJson(json);
        },
      );

      debugPrint("✅ API RETURNED: ${response.length} lodges");

      setState(() {
        lodges = response;
      });
    } catch (e, stack) {
      debugPrint("❌ ERROR loading lodges: $e");
      debugPrint("📌 STACK TRACE: $stack");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load lodges")),
      );
    } finally {
      debugPrint("🏁 FETCH COMPLETE");
      setState(() => isLoading = false);
    }
  }

  /// Calculates how many grid columns to display based on layout width
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4; // Wide desktop
    if (width > 800) return 3;  // Medium desktop / tablet landscape
    if (width > 600) return 2;  // Small tablet / large phone landscape
    return 1;                   // Standard mobile viewport
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD RUNNING - lodges: ${lodges.length}");

    final authState = ref.watch(auth.authProvider);
    final user = authState.user;
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = _getCrossAxisCount(screenWidth);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mangoOrange),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchMyLodges,
      color: AppColors.mangoOrange,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: lodges.isEmpty
                ? SliverFillRemaining(
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
                                  Icons.night_shelter_outlined,
                                  size: 26,
                                  color: AppColors.mangoOrange,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                "No Lodges Registered",
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                "There are no lodges registered under your profile yet. Once created, your registered lodges will appear here.",
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
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: crossAxisCount == 1 ? 1.2 : 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lodge = lodges[index];

                        final isOwner = user?.id != null &&
                            lodge.ownerId != null &&
                            user!.id == lodge.ownerId;

                        return LodgeCard(
                          lodge: lodge,
                          isOwner: isOwner,
                        );
                      },
                      childCount: lodges.length,
                    ),
                  ),
          ),
          
          // Web/Desktop Footer
          const SliverToBoxAdapter(
            child: WebFooter(),
          ),
        ],
      ),
    );
  }
}