import 'package:dio/dio.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import '../../core/constants/app_constants.dart';


class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}

class RemoteDataSource {
  late final Dio _dio;

  RemoteDataSource() {
    // BaseOptions configures every request made by this Dio instance.
    // We set the base URL here so every request only needs the endpoint path.
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // Fetches announcements from the /posts endpoint.
  // Returns a List<Announcement> on success.
  // 'Future' means it will eventually return a value, just not right now.
  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      // _dio.get() sends a GET request to baseUrl + postsEndpoint
      // The full URL becomes: https://jsonplaceholder.typicode.com/posts
      final Response response = await _dio.get(
        AppConstants.postsEndpoint,
        queryParameters: {'_limit': 20},
      );

      final List<dynamic> data = response.data as List<dynamic>;

      // Convert each raw map in the list to an Announcement object
      // using the fromJson factory constructor we wrote in the model.
      // This is the map() function on a List — it transforms each item.
      return data
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      // DioException is thrown for any network-related error.
      // We convert it to our own NetworkException with a clear message.
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      // Catch any other unexpected error
      throw NetworkException('Unexpected error: ${e.toString()}');
    }
  }

  // Fetches events from the /todos endpoint.
  // Same pattern as fetchAnnouncements.
  Future<List<Event>> fetchEvents() async {
    try {
      final Response response = await _dio.get(
        AppConstants.todosEndpoint,
        queryParameters: {'_limit': 20},
      );

      final List<dynamic> data = response.data as List<dynamic>;

      return data
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw NetworkException('Unexpected error: ${e.toString()}');
    }
  }

  // Private helper that converts a DioException into a human-readable string.
  // Private because only this class needs to know about Dio error types.
  String _handleDioError(DioException e) {
    // DioException has a 'type' field that categorizes the error.
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond. Try again later.';
      case DioExceptionType.badResponse:
        // badResponse means server responded but with an error status code
        // e.response?.statusCode gives us the HTTP status code (404, 500, etc.)
        return 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please go online and try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error occurred. Please try again.';
    }
  }
}