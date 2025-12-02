import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/network/todoist_response_interceptor.dart';

void main() {
  group('TodoistResponseInterceptor', () {
    late TodoistResponseInterceptor interceptor;

    setUp(() {
      interceptor = TodoistResponseInterceptor();
    });

    test('should extract results array from paginated response', () {
      final paginatedResponse = <String, dynamic>{
        'results': [
          <String, dynamic>{'id': 'task1', 'content': 'Task 1'},
          <String, dynamic>{'id': 'task2', 'content': 'Task 2'},
        ],
        'next_cursor': 'cursor123',
      };

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: paginatedResponse,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isA<List>());
      expect((handler.response?.data as List).length, 2);
      expect((handler.response?.data as List).first['id'], 'task1');
      expect((handler.response?.data as List).last['id'], 'task2');
    });

    test('should pass through single item response unchanged', () {
      final singleItemResponse = {
        'id': 'task1',
        'content': 'Task 1',
        'project_id': 'project1',
      };

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks/task1'),
        data: singleItemResponse,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isA<Map>());
      expect((handler.response?.data as Map)['id'], 'task1');
      expect((handler.response?.data as Map)['content'], 'Task 1');
    });

    test('should pass through list response unchanged', () {
      final listResponse = [
        {'id': 'task1', 'content': 'Task 1'},
        {'id': 'task2', 'content': 'Task 2'},
      ];

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: listResponse,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isA<List>());
      expect((handler.response?.data as List).length, 2);
    });

    test('should handle empty results array', () {
      final paginatedResponse = <String, dynamic>{
        'results': <dynamic>[],
        'next_cursor': null,
      };

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: paginatedResponse,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isA<List>());
      expect((handler.response?.data as List).isEmpty, true);
    });

    test('should handle response without results key', () {
      final responseWithoutResults = {
        'id': 'task1',
        'content': 'Task 1',
      };

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks/task1'),
        data: responseWithoutResults,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isA<Map>());
      expect((handler.response?.data as Map)['id'], 'task1');
    });

    test('should handle non-map, non-list response', () {
      final stringResponse = 'Simple string response';

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: stringResponse,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, 'Simple string response');
    });

    test('should handle null response data', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: null,
        statusCode: 204,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isNull);
    });

    test('should preserve response metadata when extracting results', () {
      final paginatedResponse = <String, dynamic>{
        'results': [
          <String, dynamic>{'id': 'task1', 'content': 'Task 1'},
        ],
        'next_cursor': 'cursor123',
      };

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: paginatedResponse,
        statusCode: 200,
        headers: Headers.fromMap({'content-type': ['application/json']}),
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.statusCode, 200);
      expect(handler.response?.requestOptions.path, '/tasks');
      expect(handler.response?.headers.value('content-type'), 'application/json');
    });

    test('should handle error in onError', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/tasks'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      );

      final handler = _TestErrorInterceptorHandler();
      interceptor.onError(dioException, handler);

      expect(handler.error, isNotNull);
      expect(handler.error?.type, DioExceptionType.connectionTimeout);
    });

    test('should handle error with response', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: <String, dynamic>{'error': 'Not found'},
        statusCode: 404,
      );

      final dioException = DioException(
        requestOptions: RequestOptions(path: '/tasks'),
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Not found',
      );

      final handler = _TestErrorInterceptorHandler();
      interceptor.onError(dioException, handler);

      expect(handler.error, isNotNull);
      expect(handler.error?.response?.statusCode, 404);
    });

    test('should handle large paginated response', () {
      final largeResults = List.generate(
        100,
        (index) => <String, dynamic>{'id': 'task$index', 'content': 'Task $index'},
      );

      final paginatedResponse = <String, dynamic>{
        'results': largeResults,
        'next_cursor': 'cursor123',
      };

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tasks'),
        data: paginatedResponse,
        statusCode: 200,
      );

      final handler = _TestResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(handler.response?.data, isA<List>());
      expect((handler.response?.data as List).length, 100);
    });
  });
}

/// Test helper class to capture response interceptor handler calls
class _TestResponseInterceptorHandler extends ResponseInterceptorHandler {
  Response? response;

  @override
  void next(Response response) {
    this.response = response;
  }

  @override
  void reject(DioException error, [bool callFollowingErrorInterceptor = true]) {
    // Not used in these tests
  }

  @override
  void resolve(Response response) {
    this.response = response;
  }
}

/// Test helper class to capture error interceptor handler calls
class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? error;

  @override
  void next(DioException error) {
    this.error = error;
  }

  @override
  void reject(DioException error) {
    this.error = error;
  }

  @override
  void resolve(Response response) {
    // Not used in error tests
  }
}

