import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quanos_weather_app/data/models/weather.dart';
import 'package:quanos_weather_app/data/services/weather_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('WeatherService Tests', () {
    late WeatherService weatherService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      weatherService = WeatherService(dioClient: mockDio, configureDio: false);
    });

    test('Fetches weather data successfully for city', () async {
      const city = "Test City";
      const unit = "metric";
      final responsePayload = {
        "main": {
          "temp": 20.0,
          "temp_min": 15.0,
          "temp_max": 25.0,
        },
      };
      final response = Response(
        data: responsePayload,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await weatherService.getWeatherForCity(city, unit);

      expect(result.isSuccess, true);
      expect(result.data, isA<WeatherModel>());
      expect(result.data!.main!.temp, 20.0);
    });

    test('Fetches weather data successfully for location', () async {
      const lat = 40.7128;
      const lon = -74.0060;
      const unit = "metric";
      final responsePayload = {
        "main": {
          "temp": 20.0,
          "temp_min": 15.0,
          "temp_max": 25.0,
        },
      };
      final response = Response(
        data: responsePayload,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await weatherService.getWeatherForLocation(lat, lon, unit);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isA<WeatherModel>());
      expect(result.data!.main!.temp, 20.0);
    });

    test('Handles DioException', () async {
      const city = "Test City";
      const unit = "metric";
      when(() => mockDio.get(any()))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await weatherService.getWeatherForCity(city, unit);

      expect(result.isSuccess, false);
      expect(result.error, "Error fetching data!");
    });

    test('Handles generic error', () async {
      const city = "Test City";
      const unit = "metric";
      when(() => mockDio.get(any())).thenThrow(Exception());

      final result = await weatherService.getWeatherForCity(city, unit);

      expect(result.isSuccess, false);
      expect(result.error, "No data found for the location provided!");
    });
  });
}
