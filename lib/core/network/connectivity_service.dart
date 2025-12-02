import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Service for checking internet connectivity status.
///
/// This service wraps the connectivity package to provide a simple
/// interface for checking if the device has an active internet connection.
@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  /// Checks if the device has an active internet connection.
  ///
  /// Returns `true` if connected to WiFi or mobile data, `false` otherwise.
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  /// Stream of connectivity status changes.
  ///
  /// Emits a new value whenever the connectivity status changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
