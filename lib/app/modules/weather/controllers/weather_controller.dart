import 'dart:developer';

import 'package:get/get.dart';
import 'package:quanos_weather_app/data/models/weather.dart';
import 'package:quanos_weather_app/data/services/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService weatherService = WeatherService();

  final Rx<WeatherModel?> metricWeather = Rx<WeatherModel?>(null);
  final Rx<WeatherModel?> imperialWeather = Rx<WeatherModel?>(null);
  final isMetric = true.obs;

  String? lastSearchedCity;

  Rx<WeatherModel?> get weather =>
      isMetric.value ? metricWeather : imperialWeather;

  @override
  void onInit() {
    super.onInit();
  }

  toggleUnit() {
    isMetric.toggle();
  }

  Future<void> getWeatherForCity(String city) async {
    if (city != lastSearchedCity) {
      metricWeather.value = null;
      imperialWeather.value = null;

      lastSearchedCity = city;

      await fetchWeatherData(city);
    }
  }

  Future<void> fetchWeatherData(String city) async {
    
    WeatherResponseWrapper metricResponse =
        await weatherService.getWeatherForCity(city, "metric");
    if (metricResponse.isSuccess) {
      metricWeather.value = metricResponse.weatherModel;
    } else {
      log("Error fetching metric data: ${metricResponse.error.toString()}");
    }

    WeatherResponseWrapper imperialResponse =
        await weatherService.getWeatherForCity(city, "imperial");
    if (imperialResponse.isSuccess) {
      imperialWeather.value = imperialResponse.weatherModel;
    } else {
      log("Error fetching imperial data: ${imperialResponse.error.toString()}");
    }
  }
}
