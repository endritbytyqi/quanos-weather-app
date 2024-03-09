import 'package:dio/dio.dart';
import 'package:quanos_weather_app/data/models/response_wrapper.dart';
import 'package:quanos_weather_app/data/models/weather.dart';
import 'package:quanos_weather_app/utils/api_base.dart';

class WeatherService {
  Dio dio = Dio();
  final baseUrl = APIBase().getApiBaseURL();
  final apiKey = APIBase().getAPIKey();
  DateTime? _lastApiCallTime;
  int _apiCallCount = 0;
  final int _apiCallThreshold = 10;
  final Duration _blockDuration = const Duration(seconds: 10);

  WeatherService({Dio? dioClient, bool configureDio = true})
      : dio = dioClient ?? Dio() {
    if (configureDio) {
      _configureDio();
    }
  }

  void _configureDio() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final currentTime = DateTime.now();
        if (_lastApiCallTime != null &&
            currentTime.difference(_lastApiCallTime!) < _blockDuration &&
            _apiCallCount >= _apiCallThreshold) {
          return handler.reject(DioException(
              requestOptions: options,
              error: "Rate limit exceeded. Please wait."));
        }
        _updateRateLimit(currentTime);
        return handler.next(options);
      },
    ));
  }

  void _updateRateLimit(DateTime currentTime) {
    if (_lastApiCallTime == null ||
        currentTime.difference(_lastApiCallTime!) >= _blockDuration) {
      _lastApiCallTime = currentTime;
      _apiCallCount = 1;
    } else {
      _apiCallCount++;
    }
  }

  Future<ResponseWrapper<WeatherModel>> getWeatherForCity(
    String city,
    String unit,
  ) async {
    try {
      var response = await dio.get("q=$city&appid=$apiKey&units=$unit");
      if (response.statusCode == 200) {
        WeatherModel weatherModel = WeatherModel.fromJson(response.data);
        return ResponseWrapper(true, false, null, weatherModel);
      } else {
        return ResponseWrapper(false, false, 'No data received', null);
      }
    } on DioException catch (e) {
      return ResponseWrapper(false, false, "Error fetching data!", null);
    } catch (e) {
      return ResponseWrapper(
          false, false, "No data found for the location provided!", null);
    }
  }

  Future<ResponseWrapper<WeatherModel>> getWeatherForLocation(
      double lat, double lon, String unit) async {
    try {
      var response =
          await dio.get("lat=$lat&lon=$lon&appid=$apiKey&units=$unit");
      if (response.statusCode == 200) {
        WeatherModel weatherModel = WeatherModel.fromJson(response.data);
        return ResponseWrapper(true, false, null, weatherModel);
      } else {
        return ResponseWrapper(false, false, 'No data received', null);
      }
    } on DioException catch (e) {
      return ResponseWrapper(false, false, "Error fetching data!", null);
    } catch (e) {
      return ResponseWrapper(
          false, false, "No data found for the location provided!", null);
    }
  }
}
