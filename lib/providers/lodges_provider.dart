// lib/providers/lodges_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/lodge_model.dart';
import 'package:mangochi_marketplace/providers/api_provider.dart';
import 'package:mangochi_marketplace/providers/auth_provider.dart' hide apiClientProvider;

/// Public list of lodges (accessible without login)
final lodgesProvider = FutureProvider.autoDispose<List<Lodge>>((ref) async {
  final api = ref.watch(apiClientProvider);

  return api.getList(
    'lodges/',
    fromJson: (json) => Lodge.fromJson(json),
  );
});

/// Protected list of lodges belonging to the logged-in user
final myLodgesProvider = FutureProvider.autoDispose<List<Lodge>>((ref) async {
  final authState = ref.watch(authProvider);

  // 🛡️ GUARD: Return an empty list if the user is not authenticated
  if (!authState.isAuthenticated) {
    return [];
  }

  final api = ref.watch(apiClientProvider);

  return api.getList(
    'lodges/my_lodges/',
    fromJson: (json) => Lodge.fromJson(json),
  );
});