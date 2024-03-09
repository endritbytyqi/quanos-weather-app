import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quanos_weather_app/data/models/weather.dart';
import 'package:quanos_weather_app/utils/api_base.dart';

class WeatherService {
  final Dio dio = Dio();
  final apiBase = APIBase();
  DateTime? _lastApiCallTime;
  int _apiCallCount = 0;
  final int _apiCallThreshold = 10;
  final Duration _blockDuration = const Duration(seconds: 10);

  WeatherService() {
    _configureDio();
  }

  void _configureDio() {
    dio.options.baseUrl = apiBase.getApiBase();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Future<WeatherResponseWrapper<WeatherModel>> getWeatherForCity(
    String city,
    String unit,
  ) async {
    final currentTime = DateTime.now();
    if (_lastApiCallTime == null ||
        currentTime.difference(_lastApiCallTime!) >= _blockDuration) {
      _lastApiCallTime = currentTime;
      _apiCallCount = 1;
    } else {
      // Within block duration
      if (_apiCallCount >= _apiCallThreshold) {
        return WeatherResponseWrapper(
            false, true, "Rate limit exceeded. Please wait.", null);
      }
      _apiCallCount++;
    }

    try {
      var response =
          await dio.get("q=$city&appid=${apiBase.getAPIKey()}&units=$unit");
      if (response.statusCode == 200) {
        WeatherModel weatherModel = WeatherModel.fromJson(response.data);
        return WeatherResponseWrapper(true, false, null, weatherModel);
      } else {
        return WeatherResponseWrapper(false, false, 'No data received', null);
      }
    } on DioException catch (e) {
      return WeatherResponseWrapper(false, false, "Error fetching data!", null);
    } catch (e) {
      return WeatherResponseWrapper(
          false, false, "Something went wrong!", null);
    }
  }

  Future<WeatherResponseWrapper<WeatherModel>> getWeatherForLocation(
      double lat, double lon, String unit) async {
    final currentTime = DateTime.now();
    if (_lastApiCallTime == null ||
        currentTime.difference(_lastApiCallTime!) >= _blockDuration) {
      _lastApiCallTime = currentTime;
      _apiCallCount = 1;
    } else {
      if (_apiCallCount >= _apiCallThreshold) {
        return WeatherResponseWrapper(
            false, true, "Rate limit exceeded. Please wait.", null);
      }
      _apiCallCount++;
    }

    try {
      var response = await dio
          .get("lat=$lat&lon=$lon&appid=${apiBase.getAPIKey()}&units=$unit");
      if (response.statusCode == 200) {
        WeatherModel weatherModel = WeatherModel.fromJson(response.data);
        return WeatherResponseWrapper(true, false, null, weatherModel);
      } else {
        return WeatherResponseWrapper(false, false, 'No data received', null);
      }
    } on DioException catch (e) {
      return WeatherResponseWrapper(false, false, "Error fetching data!", null);
    } catch (e) {
      return WeatherResponseWrapper(
          false, false, "Something went wrong!", null);
    }
  }
}

class WeatherResponseWrapper<T> {
  bool isSuccess;
  bool rateLimitExceeded;
  String? error;
  T? data;

  WeatherResponseWrapper(
      this.isSuccess, this.rateLimitExceeded, this.error, this.data);
}
