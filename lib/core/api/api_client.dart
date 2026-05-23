import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/payment_model.dart';

class ApiClient {


  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/';
    return 'http://127.0.0.1:8000/api/';
  }


  static const String host =
    'http://127.0.0.1:8000/api/';
  
  
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
      logger.e("Expected List but got: ${results.runtimeType}");
      return [];
    }

    return List<Map<String, dynamic>>.from(results);
  } catch (e) {
    logger.e('GET banners failed: $e');
    rethrow;
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

    throw Exception("Expected Map but got ${data.runtimeType}: $data");
  } on DioException catch (e) {

    logger.e('❌ GET $path failed');

    // 🌐 Internet issues
    if (
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout
    ) {
      throw Exception("No internet connection");
    }

    logger.e('DIO ERROR: $e');
    rethrow;
  } catch (e) {
    logger.e('GET $path failed: $e');
    rethrow;
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
      logger.e("Expected List but got: ${results.runtimeType}");
      return [];
    }

    return results.map<T>((e) {
      final item = Map<String, dynamic>.from(e);
      return fromJson(item);
    }).toList();

  } catch (e, stack) {
    logger.e('GET LIST $path failed: $e');
    logger.e(stack.toString());
    rethrow;
  }
}



Future<dynamic> uploadMultipart({
  required String endpoint,
  required Map<String, String> fields,
  required List<XFile> files,
  required String fileFieldName,
  String method = 'POST',
}) async {
  final formData = FormData();

  // fields
  fields.forEach((key, value) {
    formData.fields.add(MapEntry(key, value));
  });

  // files (FIXED for web + mobile)
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

  return response.data;
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

    return fromJson(response.data);
  } on DioException catch (e) {
    logger.e('❌ POST $path failed');

    final response = e.response;

    logger.e('STATUS: ${response?.statusCode}');
    logger.e('DATA: ${response?.data}');

    // 🔥 EXTRACT REAL BACKEND MESSAGE
    String message = "Request failed";

    if (response?.data != null) {
      final data = response!.data;

      if (data is Map<String, dynamic>) {
        message =
            data['message'] ??
            data['error'] ??
            data['detail'] ??
            message;
      } else if (data is String) {
        message = data;
      }
    }

    throw Exception(message);
  } catch (e) {
    logger.e('UNKNOWN ERROR: $e');
    throw Exception('Something went wrong');
  }
}


  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson(response.data);
    } catch (e) {
      logger.e('PUT $path failed: $e');
      rethrow;
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } catch (e) {
      logger.e('DELETE $path failed: $e');
      rethrow;
    }
  }


  Future<List<PaymentModel>> getMyPayments() async {
  return getList(
    'payments/my_payments/',
    fromJson: (json) => PaymentModel.fromJson(json),
  );
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
    return fromJson(response.data);
  } catch (e) {
    logger.e('PATCH $path failed: $e');
    rethrow;
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


  Future<Response> postMultipart(
  String endpoint,
  FormData formData,
) async {
  return await _dio.post(
    endpoint,
    data: formData,
    options: Options(
      contentType: 'multipart/form-data',
    ),
  );
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

    logger.i("PAYMENT INIT RESPONSE: ${response.data}");

    return response.data;
  } on DioException catch (e) {
    logger.e("PAYMENT INIT FAILED");
    logger.e("STATUS: ${e.response?.statusCode}");
    logger.e("DATA: ${e.response?.data}");
    rethrow;
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
