import '../errors/api_exception.dart';

extension ErrorMessage on Object {
  String get message {
    if (this is ApiException) {
      return (this as ApiException).message;
    }
    return "Something went wrong";
  }
}