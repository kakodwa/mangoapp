import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart'; // 👈 CRITICAL: Added for cross-platform MIME mapping

import '../core/api/api_client.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/product_variant_model.dart';
import 'api_provider.dart';

/// ======================
/// PRODUCTS
/// ======================

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'products/',
    fromJson: (json) => Product.fromJson(json),
  );
});

final productsByShopProvider =
    FutureProvider.autoDispose.family<List<Product>, int>((ref, shopId) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'products/',
    queryParameters: {'shop': shopId},
    fromJson: (json) => Product.fromJson(json),
  );
});

final productDetailsProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, productId) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.get(
    'products/$productId/',
    fromJson: (json) => Product.fromJson(json),
  );
});

final searchProductsProvider =
    FutureProvider.autoDispose.family<List<Product>, String>((ref, query) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'products/',
    queryParameters: {'search': query},
    fromJson: (json) => Product.fromJson(json),
  );
});


/// ======================
/// RELATED PRODUCTS
/// ======================

final relatedProductsProvider =
    FutureProvider.family<List<Product>, int>((ref, productId) async {
  final apiClient = ref.watch(apiClientProvider);

  final res = await apiClient.getList(
    'products/$productId/related/',
    fromJson: (json) {
      print("🔥 RELATED ITEM JSON: $json");
      return Product.fromJson(json);
    },
  );

  print("🔥 RELATED LENGTH: ${res.length}");
  return res;
});

/// ======================
/// PRODUCT ACTIONS
/// ======================

final productActionsProvider = Provider<ProductActions>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductActions(apiClient);
});

class ProductActions {
  final ApiClient apiClient;

  ProductActions(this.apiClient);

  /// ✅ FIXED: works perfectly on both WEB and MOBILE with Django Validation
  Future<Product> createProduct(
    Product product, 
    XFile image, 
    List<LocalProductVariant> variants,
  ) async {
    MultipartFile file;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      String ext = image.name.split('.').last.toLowerCase();
      String mimeSubType = (ext == 'png') ? 'png' : 'jpeg';

      final filename = image.name.isEmpty
          ? "upload.${mimeSubType == 'png' ? 'png' : 'jpg'}"
          : image.name;

      file = MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: MediaType('image', mimeSubType),
      );
    } else {
      file = await MultipartFile.fromFile(image.path);
    }

    final String variantsJsonString = jsonEncode(
      variants.map((v) => v.toJson()).toList(),
    );

    final formData = FormData.fromMap({
      "name": product.name,
      "description": product.description,
      "price": product.price,
      "stock": product.stock,
      "shop": product.shopId,
      "category": product.category,
      "sub_category": product.subCategory, 
      "brand": product.brand,               
      "delivery_duration": product.deliveryDuration, // 👈 Added
      "image": file,
      "variants": variantsJsonString,
    });

    final response = await apiClient.postMultipart(
      'products/',
      formData,
    );

    return Product.fromJson(response);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await apiClient.patch(
      'products/$id/',
      data: data,
      fromJson: (json) => Product.fromJson(json),
    );

    return response;
  }

  /// ✅ FIXED: Multi-image gallery upload web compatibility patch
  Future<void> uploadProductImages(
    int productId,
    List<XFile> images,
  ) async {
    final formData = FormData();

    print("🔥 Uploading ${images.length} images");
    print("Files: ${formData.files.length}");

    for (final f in formData.files) {
      print("Field: ${f.key}");
      print("Filename: '${f.value.filename}'");
    }

    for (final image in images) {
      final bytes = await image.readAsBytes();

      String ext = image.name.split('.').last.toLowerCase();
      String mimeSubType = (ext == 'png') ? 'png' : 'jpeg';

      formData.files.add(
        MapEntry(
          "images",
          MultipartFile.fromBytes(
            bytes,
            filename: image.name.isEmpty
                ? "gallery_${DateTime.now().millisecondsSinceEpoch}.jpg"
                : image.name,
            contentType: MediaType('image', mimeSubType), // 👈 CRITICAL: Web support boundary for sub-gallery
          ),
        ),
      );
    }

    final response = await apiClient.postMultipart(
      "products/$productId/add_images/",
      formData,
    );

    print("🔥 Upload response: $response");
  }
}

/// ======================
/// FAVORITES
/// ======================

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, Set<int>>(
  (ref) => FavoriteNotifier(ref),
);

class FavoriteNotifier extends StateNotifier<Set<int>> {
  final Ref ref;

  FavoriteNotifier(this.ref) : super({});

  bool isFavorite(int productId) {
    return state.contains(productId);
  }

  Future<bool> toggle(int productId) async {
    final api = ref.read(apiClientProvider);
    final wasFavorite = state.contains(productId);

    // optimistic update
    state = wasFavorite
        ? (state.where((id) => id != productId).toSet())
        : {...state, productId};

    try {
      await api.post(
        'products/$productId/toggle_favorite/',
        data: {},
        fromJson: (json) => json,
      );

      // return NEW state result
      return !wasFavorite;
    } catch (e) {
      // rollback
      state = wasFavorite
          ? {...state, productId}
          : (state.where((id) => id != productId).toSet());

      // return original state
      return wasFavorite;
    }
  }

  void setFavorites(List<int> productIds) {
    state = productIds.toSet();
  }

  void clear() {
    state = {};
  }
}

final bannersProvider = FutureProvider.autoDispose<List<BannerModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  return apiClient.getList(
    'banners/',
    fromJson: (json) => BannerModel.fromJson(json),
  );
});

/// ======================
/// CART SYSTEM (FIXED & COMPILING)
/// ======================

final cartProvider = StateProvider<List<CartItem>>((ref) => []);

class CartItem {
  final Product product;
  final LocalProductVariant? variant; 
  int quantity;

  CartItem({
    required this.product,
    this.variant,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final addToCartProvider = Provider((ref) {
  return (Product product, int qty, [LocalProductVariant? variant]) {
    final cart = ref.read(cartProvider);
    
    final index = cart.indexWhere((e) {
      final matchProduct = e.product.id == product.id;
      if (e.variant == null && variant == null) return matchProduct;
      if (e.variant != null && variant != null) {
        return matchProduct && mapEquals(e.variant!.attributes, variant.attributes);
      }
      return false;
    });

    if (index != -1) {
      final updated = [...cart];
      updated[index].quantity += qty;
      ref.read(cartProvider.notifier).state = updated;
    } else {
      ref.read(cartProvider.notifier).state = [
        ...cart,
        CartItem(product: product, quantity: qty, variant: variant),
      ];
    }
  };
});

final removeFromCartProvider = Provider((ref) {
  return (int productId, Map<String, dynamic>? variantAttributes) {
    final cart = ref.read(cartProvider);
    
    ref.read(cartProvider.notifier).state = cart.where((e) {
      final targetProduct = e.product.id == productId;
      if (e.variant == null && variantAttributes == null) return !targetProduct;
      if (e.variant != null && variantAttributes != null) {
        return !(targetProduct && mapEquals(e.variant!.attributes, variantAttributes));
      }
      return true;
    }).toList();
  };
});

final clearCartProvider = Provider((ref) {
  return () {
    ref.read(cartProvider.notifier).state = [];
  };
});