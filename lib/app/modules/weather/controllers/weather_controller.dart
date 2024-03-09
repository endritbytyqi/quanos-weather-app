import 'dart:developer';

import 'package:get/get.dart';
import 'package:quanos_weather_app/app/modules/weather/controllers/location_controller.dart';
import 'package:quanos_weather_app/data/models/weather.dart';
import 'package:quanos_weather_app/data/services/weather_service.dart';
import 'package:quanos_weather_app/utils/images.dart';

class WeatherController extends GetxController {
  final WeatherService weatherService = WeatherService();
  final LocationController locationController = LocationController();
  final Rx<WeatherModel?> metricWeather = Rx<WeatherModel?>(null);
  final Rx<WeatherModel?> imperialWeather = Rx<WeatherModel?>(null);
  final isMetric = true.obs;
  final RxBool isLoading = false.obs;

  final rateLimitExceeded = false.obs;
  final errorMessage = "".obs;
  final isDayTime = true.obs;

  Map<String, String> conditionBackgroundImages = {
    'Sunny': Images.sunny,
    'Clouds': Images.cloudy,
    'Rain': Images.rainy,
    'Mist': Images.mist
  };

  Rx<WeatherModel?> get weather =>
      isMetric.value ? metricWeather : imperialWeather;

  @override
  void onInit() {
    getWeatherForLocation();
    super.onInit();
  }

  toggleUnit() {
    isMetric.toggle();
  }

  void updateDayNightStatus() {
    if (weather.value != null) {
      final now = DateTime.now().toUtc(); // Ensure 'now' is in UTC
      final sunrise = DateTime.fromMillisecondsSinceEpoch(
          weather.value!.sys!.sunrise! * 1000,
          isUtc: true);
      final sunset = DateTime.fromMillisecondsSinceEpoch(
          weather.value!.sys!.sunset! * 1000,
          isUtc: true);

      isDayTime.value = now.isAfter(sunrise) && now.isBefore(sunset);
    }
  }

  Future<void> checkRateLimitAndRefresh(String city) async {
    if (rateLimitExceeded.value) {
      return Future.error("Rate limit exceeded");
    } else {
      return getWeatherForCity(city, forceRefresh: true);
    }
  }

  Future<void> getWeatherForCity(String city,
      {bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    await fetchWeatherData(city);
    updateDayNightStatus();
    isLoading.value = false;
  }

  Future<void> getWeatherForLocation({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    await fetchWeatherForLocation();
    updateDayNightStatus();

    isLoading.value = false;
  }

  Future<void> fetchWeatherData(String city) async {
    rateLimitExceeded.value = false;
    errorMessage.value = "";

    WeatherResponseWrapper metricResponse =
        await weatherService.getWeatherForCity(city, "metric");

    if (metricResponse.rateLimitExceeded) {
      rateLimitExceeded.value = true;
      errorMessage.value = metricResponse.error!;
      return;
    }
    if (metricResponse.isSuccess) {
      metricWeather.value = metricResponse.data;
    } else {
      errorMessage.value = metricResponse.error.toString();
      log("Error fetching metric data: ${metricResponse.error.toString()}");
    }

    WeatherResponseWrapper imperialResponse =
        await weatherService.getWeatherForCity(city, "imperial");
    if (imperialResponse.isSuccess) {
      imperialWeather.value = imperialResponse.data;
    } else {
      log("Error fetching imperial data: ${imperialResponse.error.toString()}");
      errorMessage.value = metricResponse.error.toString();
    }
  }

  Future<void> fetchWeatherForLocation() async {
    rateLimitExceeded.value = false;
    errorMessage.value = "";

    var location = await locationController.getCurrentLocation();

    if (location == null) {
      return;
    }

    WeatherResponseWrapper metricResponse = await weatherService
        .getWeatherForLocation(location.latitude, location.longitude, "metric");

    if (metricResponse.rateLimitExceeded) {
      rateLimitExceeded.value = true;
      errorMessage.value = metricResponse.error!;
      return;
    }
    if (metricResponse.isSuccess) {
      metricWeather.value = metricResponse.data;
    } else {
      errorMessage.value = metricResponse.error.toString();
      log("Error fetching metric data: ${metricResponse.error.toString()}");
    }

    WeatherResponseWrapper imperialResponse =
        await weatherService.getWeatherForLocation(
            location.latitude, location.longitude, "imperial");
    if (imperialResponse.isSuccess) {
      imperialWeather.value = imperialResponse.data;
    } else {
      log("Error fetching imperial data: ${imperialResponse.error.toString()}");
      errorMessage.value = metricResponse.error.toString();
    }
  }
}
