import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/core/network/todoist_response_interceptor.dart';

/// Dependency injection module for network-related dependencies.
///
/// This module provides singleton instances of:
/// - [Dio]: HTTP client configured for Todoist API
/// - [TodoistApi]: Retrofit-generated API client for Todoist REST API
@module
abstract class NetworkModule {
  /// Provides a configured [Dio] instance for HTTP requests.
  ///
  /// The instance is configured with:
  /// - Base URL: `https://api.todoist.com`
  /// - JSON content type headers
  /// - Authorization header with bearer token from environment variables
  ///
  /// Returns a lazy singleton instance that is created on first access.
  ///
  /// Throws an exception if `TODOIST_API_TOKEN` is not set in the environment.
  @lazySingleton
  Dio get dio {
    final apiToken = dotenv.env['TODOIST_API_TOKEN'];
    if (apiToken == null || apiToken.isEmpty) {
      throw Exception(
        'TODOIST_API_TOKEN is not set in .env file. '
        'Please create a .env file with your Todoist API token.',
      );
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.todoist.com',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
      ),
    );

    // Add interceptor to handle Todoist API v1 paginated responses
    dio.interceptors.add(TodoistResponseInterceptor());

    return dio;
  }

  /// Provides a [TodoistApi] instance for interacting with the Todoist REST API.
  ///
  /// Returns a lazy singleton instance that is created on first access.
  @lazySingleton
  TodoistApi get todoistApi => TodoistApi(dio);

  /// Provides a [Connectivity] instance for checking network connectivity.
  ///
  /// Returns a lazy singleton instance that is created on first access.
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}

