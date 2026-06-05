import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/payment_model.dart';
import '../errors/api_exception.dart';

class ApiClient {


  static String get baseUrl {
    if (kIsWeb) return 'https://mangobackend-yayy.onrender.com/api/';
    return 'https://mangobackend-yayy.onrender.com/api/';
  }


  static const String host =
    'https://mangobackend-yayy.onrender.com/api/';
  
  
  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  final logger = Logger();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    // Add JWT interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            if (await _refreshToken()) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }


Future<List<Map<String, dynamic>>> fetchBanners() async {
  try {
    final response = await _dio.get('banners/');

    logger.i("BANNERS RESPONSE: ${response.data}");

    final data = response.data;

    final results = (data is Map && data['results'] != null)
        ? data['results']
        : data;

    if (results is! List) {
      throw ApiException("Invalid banners format");
    }

    return List<Map<String, dynamic>>.from(results);
  } on DioException catch (e) {
    logger.e('❌ GET banners failed');

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    // 🔥 BACKEND ERROR
    final response = e.response;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data;

      throw ApiException(
        data['message'] ??
        data['error'] ??
        data['detail'] ??
        "Failed to load banners",
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('GET banners failed: $e');
    throw ApiException("Something went wrong");
  }
}


Future<Map<String, dynamic>> submitWithdrawalRequest({
  required double amount,
  required String payoutMethod, // 'mobile_money' or 'bank_transfer'
  required String accountHolderName,
  required String accountNumber, // Phone or Bank Acct string
  String? bankName,
  String? bankUuid,
  String? bankBranch,
}) async {
  return await post(
    'wallet/request_withdrawal/',
    data: {
      "amount": amount,
      "payout_method": payoutMethod,
      "account_holder_name": accountHolderName,
      "account_number": accountNumber,
      if (bankName != null) "bank_name": bankName,
      if (bankUuid != null) "bank_uuid": bankUuid,
      if (bankBranch != null) "bank_branch": bankBranch,
    },
    fromJson: (json) => json,
  );
}


Future<Map<String, dynamic>> searchUnified({
  required String query,
  required String type, // 'all', 'event', 'lodge', 'product', 'property', 'shop'
  String? district,
  String? city,
  String? category,
  String? listingPurpose,
  int page = 1,
}) async {
  final Map<String, dynamic> params = {
    'q': query,
    'type': type,
    'page': page,
  };

  if (district != null && district.isNotEmpty) params['district'] = district;
  if (city != null && city.isNotEmpty) params['city'] = city;
  if (category != null && category.isNotEmpty) params['category'] = category;
  if (listingPurpose != null && listingPurpose.isNotEmpty) params['listing_purpose'] = listingPurpose;

  // We utilize your custom get method while handling standard dictionary format
  return await get(
    'feed/search/',
    queryParameters: params,
    fromJson: (json) => json,
  );
}


Future<Map<String, dynamic>> getAppVersion() async {
  try {
    final response = await _dio.get('products/app_version/');

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw ApiException("Invalid app version response");
  } on DioException catch (e) {
    logger.e('❌ GET app version failed');

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    // 🔥 BACKEND ERROR
    final response = e.response;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data;

      throw ApiException(
        data['message'] ??
        data['error'] ??
        data['detail'] ??
        "Failed to fetch app version",
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('GET app version failed: $e');
    throw ApiException("Something went wrong");
  }
}


Future<Map<String, dynamic>> checkPaymentStatus(
  String paymentReference,
) async {

  final response = await get(
    'payments/check_payment_status/?reference=$paymentReference',
    fromJson: (json) => json,
  );

  return response;
}

  Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        'token/refresh/',
        data: {'refresh': refreshToken},
      );

      await _secureStorage.write(
        key: 'access_token',
        value: response.data['access'],
      );
      return true;
    } catch (e) {
      logger.e('Token refresh failed: $e');
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

Future<T> get<T>(
  String path, {
  Map<String, dynamic>? queryParameters,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return fromJson(data);
    }

    throw ApiException(
      "Invalid response format",
    );
  } on DioException catch (e) {
    logger.e('❌ GET $path failed');

    // 🌐 Network issues
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    // 🔥 Backend response errors
    if (e.response != null) {
      final data = e.response?.data;

      String message = "Request failed";

      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      }

      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }

    // fallback
    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('GET $path failed: $e');

    // fallback for unexpected errors
    throw ApiException("Something went wrong");
  }
}

Future<List<T>> getList<T>(
  String path, {
  Map<String, dynamic>? queryParameters,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
    );

    logger.i("RAW RESPONSE: ${response.data}");

    final data = response.data;

    final results = (data is Map && data['results'] != null)
        ? data['results']
        : data;

    if (results is! List) {
      throw ApiException("Invalid list response format");
    }

    return results.map<T>((e) {
      final item = Map<String, dynamic>.from(e);
      return fromJson(item);
    }).toList();
  } on DioException catch (e) {
    logger.e('❌ GET LIST $path failed');

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    // 🔥 BACKEND ERROR
    final response = e.response;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data;

      throw ApiException(
        data['message'] ??
        data['error'] ??
        data['detail'] ??
        "Failed to load data",
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e, stack) {
    logger.e('GET LIST $path failed: $e');
    logger.e(stack.toString());

    throw ApiException("Something went wrong");
  }
}


Future<dynamic> uploadMultipart({
  required String endpoint,
  required Map<String, String> fields,
  required List<XFile> files,
  required String fileFieldName,
  String method = 'POST',
}) async {
  try {
    final formData = FormData();

    // 📦 add fields
    fields.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    // 📎 add files
    for (final file in files) {
      Uint8List bytes = await file.readAsBytes();

      formData.files.add(
        MapEntry(
          fileFieldName,
          MultipartFile.fromBytes(
            bytes,
            filename: file.name,
          ),
        ),
      );
    }

    final response = await _dio.request(
      endpoint,
      data: formData,
      options: Options(
        method: method,
        contentType: 'multipart/form-data',
      ),
    );

    logger.i("✅ MULTIPART $endpoint SUCCESS");
    logger.i(response.data);

    return response.data;
  } on DioException catch (e) {
    logger.e("❌ MULTIPART $endpoint FAILED");

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    final response = e.response;

    // 🔥 SERVER ERROR
    if (response != null) {
      final data = response.data;

      String message = "Upload failed";

      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      } else if (data is String) {
        message = data;
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e("UPLOAD ERROR: $e");
    throw ApiException("Something went wrong");
  }
}

Future<T> post<T>(
  String path, {
  required Map<String, dynamic> data,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await _dio.post(path, data: data);

    logger.i("✅ POST $path RESPONSE:");
    logger.i(response.data);

    if (response.data is Map<String, dynamic>) {
      return fromJson(response.data);
    }

    throw ApiException("Invalid response format");
  } on DioException catch (e) {
    logger.e('❌ POST $path failed');

    final response = e.response;

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    // 🔥 SERVER RESPONDED WITH ERROR
    if (response != null) {
      final data = response.data;

      String message = "Request failed";

      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      } else if (data is String) {
        message = data;
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    // fallback
    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('UNKNOWN ERROR: $e');
    throw ApiException("Something went wrong");
  }
}


Future<T> put<T>(
  String path, {
  required Map<String, dynamic> data,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await _dio.put(path, data: data);

    logger.i("✅ PUT $path RESPONSE:");
    logger.i(response.data);

    if (response.data is Map<String, dynamic>) {
      return fromJson(response.data);
    }

    throw ApiException("Invalid response format");
  } on DioException catch (e) {
    logger.e('❌ PUT $path failed');

    // 🌐 NETWORK ISSUES
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    final response = e.response;

    // 🔥 BACKEND ERROR
    if (response != null) {
      final data = response.data;

      String message = "Request failed";

      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      } else if (data is String) {
        message = data;
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('PUT $path failed: $e');
    throw ApiException("Something went wrong");
  }
}


Future<void> delete(String path) async {
  try {
    final response = await _dio.delete(path);

    logger.i("✅ DELETE $path RESPONSE:");
    logger.i(response.data);
  } on DioException catch (e) {
    logger.e('❌ DELETE $path failed');

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    final response = e.response;

    // 🔥 BACKEND ERROR
    if (response != null) {
      final data = response.data;

      String message = "Request failed";

      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      } else if (data is String) {
        message = data;
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('DELETE $path failed: $e');
    throw ApiException("Something went wrong");
  }
}


Future<List<PaymentModel>> getMyPayments() async {
  try {
    return await getList(
      'payments/my_payments/',
      fromJson: (json) => PaymentModel.fromJson(json),
    );
  } on ApiException {
    rethrow; // keep clean error flow
  } catch (e) {
    throw ApiException("Something went wrong");
  }
}

  Future<Response> patchMultipart(
  String endpoint,
  FormData formData,
) async {
  try {
    final response = await _dio.patch(
      endpoint,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    return response;
  } catch (e) {
    logger.e('PATCH MULTIPART $endpoint failed: $e');
    rethrow;
  }
}

Future<T> patch<T>(
  String path, {
  required Map<String, dynamic> data,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await _dio.patch(path, data: data);

    logger.i("✅ PATCH $path RESPONSE:");
    logger.i(response.data);

    if (response.data is Map<String, dynamic>) {
      return fromJson(response.data);
    }

    throw ApiException("Invalid response format");
  } on DioException catch (e) {
    logger.e('❌ PATCH $path failed');

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    final response = e.response;

    // 🔥 BACKEND ERROR
    if (response != null) {
      final data = response.data;

      String message = "Request failed";

      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      } else if (data is String) {
        message = data;
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e('PATCH $path failed: $e');
    throw ApiException("Something went wrong");
  }
}
  // Authentication methods
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    required String phoneNumber,
    String? district,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      final response = await _dio.post(
        'users/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'user_type': userType,
          'phone_number': phoneNumber,
          'district': district,
          'gender': gender,
          'date_of_birth': dateOfBirth,
        },
      );
      return response.data;
    } catch (e) {
      logger.e('Registration failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'token/',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      logger.e('Login failed: $e');
      rethrow;
    }
  }


Future<void> createEvent(Map<String, dynamic> data) async {
  await post(
    "events/",
    data: data,
    fromJson: (json) => json,
  );
}

Future<Map<String, dynamic>> postMultipart(
  String endpoint,
  FormData formData,
) async {
  try {
    final response = await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    logger.i("✅ POST MULTIPART SUCCESS: $endpoint");
    logger.i(response.data);

    if (response.data is Map<String, dynamic>) {
      return response.data;
    }

    throw ApiException("Invalid response format: ${response.data}");
  } on DioException catch (e) {
    logger.e("❌ POST MULTIPART FAILED: $endpoint");
    logger.e(e.response?.data ?? e.message);

    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      throw ApiException(
        data['message'] ?? data['error'] ?? "Upload failed",
        statusCode: e.response?.statusCode,
      );
    }

    throw ApiException("Server error");
  }
}


Future<Map<String, dynamic>> initiatePropertyPayment({
  required int propertyId,
  required double amount,
  required String paymentMethod,

  String? fullName,
  String? phoneNumber,

  String? cardName,
  String? cardNumber,
  String? expiry,
  String? cvv,
}) async {
  try {
    final response = await _dio.post(
      '/payments/initiate_payment/',
      data: {
        "property_id": propertyId,
        "amount": amount,
        "payment_method": paymentMethod,

        "full_name": fullName,
        "phone_number": phoneNumber,

        "card_name": cardName,
        "card_number": cardNumber,
        "expiry": expiry,
        "cvv": cvv,
      },
    );

    logger.i("💳 PAYMENT INIT RESPONSE: ${response.data}");

    return response.data;
  } on DioException catch (e) {
    logger.e("❌ PAYMENT INIT FAILED");

    // 🌐 NETWORK ERROR
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException("No internet connection");
    }

    final response = e.response;

    // 🔥 BACKEND ERROR
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data;

      throw ApiException(
        data['message'] ??
        data['error'] ??
        data['detail'] ??
        "Payment failed",
        statusCode: response.statusCode,
      );
    }

    throw ApiException("Server not reachable");
  } catch (e) {
    logger.e("PAYMENT INIT UNKNOWN ERROR: $e");
    throw ApiException("Something went wrong");
  }
}


  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }
}
