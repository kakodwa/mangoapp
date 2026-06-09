import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import 'api_provider.dart';

// Family provider tracking specific target variations dynamically
final reviewsProvider = StateNotifierProvider.family<ReviewsNotifier, AsyncValue<List<Review>>, String>(
  (ref, targetKey) {
    // Expected key layout: "product_42" or "event_12"
    final splits = targetKey.split('_');
    final type = splits[0];
    final id = int.parse(splits[1]);
    return ReviewsNotifier(ref, type, id);
  },
);

class ReviewsNotifier extends StateNotifier<AsyncValue<List<Review>>> {
  final Ref _ref;
  final String _type;
  final int _id;

  ReviewsNotifier(this._ref, this._type, this._id) : super(const AsyncValue.loading()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    state = const AsyncValue.loading();
    try {
      final client = _ref.read(apiClientProvider);
      final list = await client.fetchReviews(targetType: _type, targetId: _id);
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> postReview({
    required int rating,
    required String title,
    required String comment,
  }) async {
    try {
      final client = _ref.read(apiClientProvider);
      final newReview = await client.submitReview(
        targetType: _type,
        targetId: _id,
        rating: rating,
        title: title,
        comment: comment,
      );
      
      // Instantly push or update the reactive UI list state natively
      state.whenData((currentList) {
        final updatedList = List<Review>.from(currentList);
        final existingIndex = updatedList.indexWhere((r) => r.id == newReview.id);
        
        if (existingIndex != -1) {
          updatedList[existingIndex] = newReview;
        } else {
          updatedList.insert(0, newReview);
        }
        state = AsyncValue.data(updatedList);
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}