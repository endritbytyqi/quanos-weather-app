import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quanos_weather_app/data/models/weather.dart';
import 'package:quanos_weather_app/utils/api_base.dart';

class WeatherService {

//TOOD: Retry policy, circuit breaker policy in flutter,  exception handling
//TODO: check if the same request is sent more than 5 times, don't overload the API for 20 sec or smth. 

  final dio = Dio();
  final apiBase = APIBase();

  void configureDio() {
    // Set default configs
    dio.options.baseUrl = apiBase.getApiBase();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Future<dynamic> getWeatherForCity(String city, String unit) async {
    configureDio();
    try {
      var response =
          await dio.get("$city&appid=${apiBase.getAPIKey()}&units=$unit");
      if (response.data != null) {
        WeatherModel weatherModel = WeatherModel.fromJson(response.data);
        return WeatherResponseWrapper(true, null, weatherModel);
      }
    } on DioException catch (e) {
      return WeatherResponseWrapper(false, e.message.toString(), null);
    }
  }


}

class WeatherResponseWrapper {
  bool isSuccess = false;
  String? error;
  WeatherModel? weatherModel;

  WeatherResponseWrapper(this.isSuccess, this.error, this.weatherModel);
}
