import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api/api_client.dart';
import '../models/property_model.dart';
import 'api_provider.dart';

/// ======================
/// PROPERTIES LIST
/// ======================
final propertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  return apiClient.getList(
    'properties/',
    fromJson: (json) => Property.fromJson(json),
  );
});


final relatedPropertiesProvider =
    FutureProvider.family<List<Property>, int>((ref, propertyId) async {

  final apiClient = ref.watch(apiClientProvider);

  return apiClient.getList(
    'properties/$propertyId/related/',
    fromJson: (json) => Property.fromJson(json),
  );
});
/// ======================
/// FILTER BY CITY
/// ======================
final propertiesByCityProvider =
    FutureProvider.autoDispose.family<List<Property>, String>(
  (ref, city) async {
    final apiClient = ref.watch(apiClientProvider);

    return apiClient.getList(
      'properties/',
      queryParameters: {'city': city},
      fromJson: (json) => Property.fromJson(json),
    );
  },
);

/// ======================
/// PROPERTY DETAILS
/// ======================
final propertyDetailsProvider =
    FutureProvider.autoDispose.family<Property, int>(
  (ref, propertyId) async {
    final apiClient = ref.watch(apiClientProvider);

    return apiClient.get(
      'properties/$propertyId/',
      fromJson: (json) => Property.fromJson(json),
    );
  },
);

/// ======================
/// FULL DETAILS (UNLOCKED)
/// ======================
final propertyFullDetailsProvider =
    FutureProvider.autoDispose.family<Property, int>(
  (ref, propertyId) async {
    final apiClient = ref.watch(apiClientProvider);

    return apiClient.get(
      'properties/$propertyId/full_details/',
      fromJson: (json) => Property.fromJson(json),
    );
  },
);

/// ======================
/// UNLOCKED PROPERTIES
/// ======================
final userUnlockedPropertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  return apiClient.getList(
    'properties/unlocked/',
    fromJson: (json) => Property.fromJson(json),
  );
});

/// ======================
/// MY PROPERTIES (OWNER)
/// ======================
final myPropertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  return apiClient.getList(
    'properties/my_properties/',
    fromJson: (json) => Property.fromJson(json),
  );
});

/// ======================
/// FILTERS
/// ======================
final propertyTypeFilterProvider = StateProvider<String?>((ref) => null);
final propertyStatusFilterProvider = StateProvider<String?>((ref) => null);

/// ======================
/// FILTERED LIST
/// ======================
final filteredPropertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final properties = await ref.watch(propertiesProvider.future);
  final typeFilter = ref.watch(propertyTypeFilterProvider);
  final statusFilter = ref.watch(propertyStatusFilterProvider);

  return properties.where((property) {
    final typeMatch =
        typeFilter == null || property.propertyType == typeFilter;
    final statusMatch =
        statusFilter == null || property.status == statusFilter;
    return typeMatch && statusMatch;
  }).toList();
});

/// ======================
/// PROPERTY UNLOCK
/// ======================
class PropertyUnlockNotifier
    extends StateNotifier<AsyncValue<void>> {
  final ApiClient _apiClient;

  PropertyUnlockNotifier(this._apiClient)
      : super(const AsyncValue.data(null));

  Future<void> unlockProperty({
    required int propertyId,
    required String paymentMethod,
    String? fullName,
    String? phoneNumber,
    String? cardName,
    String? cardNumber,
    String? expiry,
    String? cvv,
  }) async {
    state = const AsyncValue.loading();

    try {
      final data = {
        'payment_method': paymentMethod,

        if (paymentMethod == 'airtel_money' ||
            paymentMethod == 'tnm_mpamba') ...{
          'full_name': fullName,
          'phone_number': phoneNumber,
        },

        if (paymentMethod == 'visa_card') ...{
          'card_name': cardName,
          'card_number': cardNumber,
          'expiry': expiry,
          'cvv': cvv,
        },
      };

      await _apiClient.post(
        'properties/$propertyId/unlock/',
        data: data,
        fromJson: (json) => json,
      );

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final propertyUnlockProvider =
    StateNotifierProvider<PropertyUnlockNotifier,
        AsyncValue<void>>((ref) {
  return PropertyUnlockNotifier(ref.watch(apiClientProvider));
});

/// ======================
/// PROPERTY ACTIONS
/// ======================
final propertyActionsProvider =
    Provider<PropertyActions>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyActions(apiClient);
});

class PropertyActions {
  final ApiClient _apiClient;

  PropertyActions(this._apiClient);

  /// ======================
  /// CREATE PROPERTY
  /// ======================
  Future<void> createProperty(
    Property property,
    List<XFile> images,
  ) async {
    final fields = {
      'title': property.title,
      'description': property.description,
      'property_type': property.propertyType,
      'status': property.status,
      'latitude': property.latitude.toString(),
      'longitude': property.longitude.toString(),
      'address': property.address,
      'city': property.city,
      'district': property.district,
      'price': property.price.toString(),
      'size_sqm': property.sizeSqm.toString(),
      'is_publicly_visible':
          property.isPubliclyVisible.toString(),
    };

    if (property.bedrooms != null) {
      fields['bedrooms'] = property.bedrooms.toString();
    }

    if (property.bathrooms != null) {
      fields['bathrooms'] = property.bathrooms.toString();
    }

    await _apiClient.uploadMultipart(
      endpoint: 'properties/',
      fields: fields,
      files: images,
      fileFieldName: 'images',
    );
  }

  Future<void> deleteProperty(int propertyId) async {
  await _apiClient.delete('properties/$propertyId/');
}

  /// ======================
  /// UPDATE PROPERTY
  /// ======================
  Future<void> updateProperty({
    required int propertyId,
    required Property property,
    List<XFile>? images,
  }) async {
    final fields = {
      'title': property.title,
      'description': property.description,
      'property_type': property.propertyType,
      'status': property.status,
      'latitude': property.latitude.toString(),
      'longitude': property.longitude.toString(),
      'address': property.address,
      'city': property.city,
      'district': property.district,
      'price': property.price.toString(),
      'size_sqm': property.sizeSqm.toString(),
      'is_publicly_visible':
          property.isPubliclyVisible.toString(),
    };

    if (property.bedrooms != null) {
      fields['bedrooms'] = property.bedrooms.toString();
    }

    if (property.bathrooms != null) {
      fields['bathrooms'] = property.bathrooms.toString();
    }

    await _apiClient.uploadMultipart(
      endpoint: 'properties/$propertyId/',
      fields: fields,
      files: images ?? [],
      fileFieldName: 'images',
      method: 'PATCH',
    );
  }
}