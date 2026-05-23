import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/shop_model.dart';
import 'api_provider.dart';

final shopsProvider = FutureProvider.autoDispose<List<Shop>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'shops/',
    fromJson: (json) => Shop.fromJson(json),
  );
});


final relatedShopsProvider =
    FutureProvider.family<List<Shop>, int>((ref, shopId) async {
  final apiClient = ref.watch(apiClientProvider);

  final res = await apiClient.getList(
    'shops/$shopId/related/',
    fromJson: (json) => Shop.fromJson(json),
  );

  return res;
});


final shopActionsProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  return ShopActions(api);
});

class ShopActions {
  final ApiClient api;

  ShopActions(this.api);

  Future<Shop> createShop(Map<String, dynamic> data) async {
    final response = await api.post(
      'shops/',
      data: data,
      fromJson: (json) => Shop.fromJson(json),
    );

    return response;
  }
}


final shopsByCategoryProvider = FutureProvider.autoDispose
    .family<List<Shop>, String>((ref, category) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'shops/',
    queryParameters: {'category': category},
    fromJson: (json) => Shop.fromJson(json),
  );
});

final shopDetailsProvider = FutureProvider.autoDispose
    .family<Shop, int>((ref, shopId) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.get(
    'shops/$shopId/',
    fromJson: (json) => Shop.fromJson(json),
  );
});

final userShopsProvider = FutureProvider.autoDispose<List<Shop>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'shops/my_shops/',
    fromJson: (json) => Shop.fromJson(json),
  );
});

class ShopsNotifier extends StateNotifier<AsyncValue<List<Shop>>> {
  final ApiClient _apiClient;

  ShopsNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      final shops = await _apiClient.getList(
        'shops/',
        fromJson: (json) => Shop.fromJson(json),
      );
      state = AsyncValue.data(shops);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await _loadShops();
  }
}

<<<<<<< HEAD



=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
final shopsNotifierProvider =
    StateNotifierProvider<ShopsNotifier, AsyncValue<List<Shop>>>((ref) {
  return ShopsNotifier(ref.watch(apiClientProvider));
});

final hasShopProvider = Provider<bool>((ref) {
  final shopsAsync = ref.watch(userShopsProvider);

  return shopsAsync.maybeWhen(
    data: (shops) => shops.isNotEmpty,
    orElse: () => false,
  );
});
