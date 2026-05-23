import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/lodge_model.dart';
import 'api_provider.dart';

final lodgesProvider =
    FutureProvider.autoDispose<List<Lodge>>((ref) async {
  final api = ref.watch(apiClientProvider);

  return api.getList(
    'lodges/',
    fromJson: (json) => Lodge.fromJson(json),
  );
});