import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your existing project imports
import '../../models/review_model.dart';
import '../../providers/reviews_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_toast.dart';

// Your explicit Design System imports
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/app_colors.dart';

class ReviewSectionWidget extends ConsumerWidget {
  final String targetType; // 'product', 'event', 'property', 'lodge', 'shop'
  final int targetId;
  final bool isOwner;

  const ReviewSectionWidget({
    Key? key,
    required this.targetType,
    required this.targetId,
    required this.isOwner,
  }) : super(key: key);

  String get _targetKey => "${targetType}_$targetId";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isAuthenticated;
    final reviewsAsync = ref.watch(reviewsProvider(_targetKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Removed const Divider() from here to clean up the UI line
        const SizedBox(height: AppSpacing.sm),
        
        // Header Row Layout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Customer Reviews", style: AppTypography.headlineMedium),
            if (isLoggedIn && !isOwner)
              TextButton.icon(
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text("Write Review"),
                style: TextButton.styleFrom(foregroundColor: AppColors.mangoOrange),
                onPressed: () => _showReviewDialog(context, ref),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Async Data Stream Consumer Frame
        reviewsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Text(
            "Could not load reviews.",
            style: AppTypography.bodySmall.copyWith(color: Colors.grey),
          ),
          data: (reviewList) {
            if (reviewList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  "No reviews posted yet.",
                  style: AppTypography.bodyMedium.copyWith(color: Colors.grey),
                ),
              );
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewList.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final rev = reviewList[index];
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rev.userName, style: AppTypography.titleMedium),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < rev.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 16,
                            )),
                          ),
                        ],
                      ),
                      if (rev.title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          rev.title, 
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        rev.comment, 
                        style: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Self-contained sheet modal dynamic input handler
  void _showReviewDialog(BuildContext context, WidgetRef ref) {
    int selectedRating = 5;
    final titleController = TextEditingController();
    final commentController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Write a Review", style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              
              // Interactive Star Rating Selectors Flow Layout
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final currentStar = index + 1;
                  return IconButton(
                    icon: Icon(
                      currentStar <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () => setModalState(() => selectedRating = currentStar),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Headline (Optional)", 
                  hintText: "Summarize your review",
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Comments", 
                  hintText: "Tell us about your experience...",
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mangoOrange),
                  onPressed: submitting ? null : () async {
                    if (commentController.text.trim().isEmpty) {
                      AppToast.info(context, "Please write a comment.");
                      return;
                    }
                    setModalState(() => submitting = true);
                    
                    final success = await ref.read(reviewsProvider(_targetKey).notifier).postReview(
                      rating: selectedRating,
                      title: titleController.text.trim(),
                      comment: commentController.text.trim(),
                    );
                    
                    if (success) {
                      // ✅ Free up system hardware memory tracks cleanly
                      titleController.dispose();
                      commentController.dispose();
                      
                      Navigator.pop(context);
                      AppToast.info(context, "Review submitted successfully!");
                    } else {
                      setModalState(() => submitting = false);
                      AppToast.info(context, "Failed to post review.");
                    }
                  },
                  child: submitting 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ) 
                      : const Text("Submit Review", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}