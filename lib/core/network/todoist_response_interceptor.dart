import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor that extracts the 'results' field from Todoist API v1 paginated responses.
///
/// Todoist API v1 returns paginated responses in the format:
/// ```json
/// {
///   "results": [...],
///   "next_cursor": null
/// }
/// ```
///
/// This interceptor automatically extracts the 'results' array so that
/// Retrofit methods can return `List<T>` directly instead of a wrapper object.
class TodoistResponseInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTime,
    ),
  );

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    // Log the raw response for debugging
    _logger.d('=== Todoist API Response ===');
    _logger.d('URL: ${response.requestOptions.path}');
    _logger.d('Status: ${response.statusCode}');

    if (data is Map<String, dynamic>) {
      _logger.d('Response Type: Map');
      _logger.d('Keys: ${data.keys.toList()}');

      // Check if the response is a Map with a 'results' field
      // This indicates a paginated response from Todoist API v1
      if (data.containsKey('results')) {
        final resultsList = data['results'] as List?;
        _logger.d(
          'Found paginated response with ${resultsList?.length ?? 0} items',
        );

        // Log first item structure if available
        if (resultsList != null && resultsList.isNotEmpty) {
          final firstItem = resultsList.first;
          if (firstItem is Map) {
            _logger.d('First item keys: ${firstItem.keys.toList()}');
            _logger.d('First item sample:');
            try {
              final jsonStr = jsonEncode(firstItem);
              _logger.d(
                jsonStr.length > 1000
                    ? '${jsonStr.substring(0, 1000)}...'
                    : jsonStr,
              );
            } catch (e) {
              _logger.e('Could not encode first item', error: e);
            }
          }
        }

        // Extract the results array
        response.data = data['results'];
      } else {
        // Single item response - log its structure
        _logger.d('Single item response');
        _logger.d('Keys: ${data.keys.toList()}');
        _logger.d('Response sample:');
        try {
          final jsonStr = jsonEncode(data);
          _logger.d(
            jsonStr.length > 1000
                ? '${jsonStr.substring(0, 1000)}...'
                : jsonStr,
          );
        } catch (e) {
          _logger.e('Could not encode response', error: e);
        }
      }
    } else if (data is List) {
      _logger.d('Response Type: List (${data.length} items)');
      if (data.isNotEmpty && data.first is Map) {
        _logger.d('First item keys: ${(data.first as Map).keys.toList()}');
      }
    } else {
      _logger.d('Response Type: ${data.runtimeType}');
      _logger.d('Response: $data');
    }

    _logger.d('===========================');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('Todoist API Error', error: err, stackTrace: err.stackTrace);
    _logger.e(
      'Request: ${err.requestOptions.method} ${err.requestOptions.path}',
    );
    _logger.e('Response: ${err.response?.statusCode} - ${err.response?.data}');
    handler.next(err);
  }
}
