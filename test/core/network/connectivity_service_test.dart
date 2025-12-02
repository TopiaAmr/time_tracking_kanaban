import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/network/connectivity_service.dart';

import 'connectivity_service_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late ConnectivityService service;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    service = ConnectivityService(mockConnectivity);
  });

  group('ConnectivityService', () {
    test('should check connectivity status', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await service.isConnected();

      expect(result, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return false when not connected', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await service.isConnected();

      expect(result, false);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return true for mobile connection', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.mobile]);

      final result = await service.isConnected();

      expect(result, true);
    });

    test('should return true for ethernet connection', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.ethernet]);

      final result = await service.isConnected();

      expect(result, true);
    });

    test('should provide connectivity change stream', () {
      final streamController = StreamController<List<ConnectivityResult>>();
      when(
        mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => streamController.stream);

      final stream = service.onConnectivityChanged;

      expect(stream, isA<Stream<List<ConnectivityResult>>>());
      verify(mockConnectivity.onConnectivityChanged).called(1);

      streamController.close();
    });
  });
}
