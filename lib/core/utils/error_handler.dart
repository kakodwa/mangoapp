import '../errors/api_exception.dart';

class ErrorHandler {
  static String message(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return "Something went wrong";
  }
}