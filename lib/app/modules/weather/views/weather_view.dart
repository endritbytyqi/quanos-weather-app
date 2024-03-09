import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanos_weather_app/app/modules/weather/controllers/location_controller.dart';
import 'package:quanos_weather_app/utils/utils.dart';
import 'package:quanos_weather_app/utils/widgets.dart';
import '../controllers/weather_controller.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(LocationController());
    final locationController = Get.find<LocationController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await controller.refreshWeather();
          } catch (e) {
            Get.snackbar("Error", e.toString(),
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        },
        child: Stack(
          children: [
            Obx(() => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: controller.isDayTime.value
                          ? [const Color(0xFF4788ED), const Color(0xFF6CA8F1)]
                          : [
                              const Color.fromARGB(255, 2, 41, 99),
                              const Color.fromARGB(255, 4, 40, 77)
                            ],
                    ),
                  ),
                )),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FloatingActionButton(
                                onPressed: () async {
                                  await locationController.getCurrentLocation();
                                  if (locationController
                                          .currentPosition.value !=
                                      null) {
                                    await controller.getWeatherForLocation();
                                    controller.searchController.text = "";
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Unable to fetch location: ${locationController.errorMessage.value}",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                                child: const Icon(Icons.assistant_navigation),
                              ),
                              SizedBox(
                                width: Get.width * 0.7,
                                child: TextField(
                                  controller: controller.searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search for a city',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () {
                                        controller.errorMessage.value = '';

                                        if (controller
                                            .searchController.text.isNotEmpty) {
                                          controller.getWeatherForCity(
                                              controller.searchController.text);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          if (controller.errorMessage.value.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Get.snackbar(
                                "Error",
                                controller.errorMessage.value,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            });
                          }
                          return const SizedBox.shrink();
                        }),
                        const SizedBox(height: 16),
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white));
                          } else if (controller.weather.value != null) {
                            return WeatherItemsWidget(controller: controller);
                          } else if (controller.errorMessage.isNotEmpty &&
                              controller.weather.value == null) {
                            return const WeatherHomeDescriptionWidget();
                          } else {
                            return const WeatherHomeDescriptionWidget();
                          }
                        }),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (controller.weather.value != null) {
                      final weatherData = controller.weather.value!;
                      return Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Toggle Units',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              controller.isMetric.value ? 'Metric' : 'Imperial',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            value: controller.isMetric.value,
                            onChanged: (bool value) {
                              controller.toggleUnit();
                            },
                          ),
                          WeatherDetailCard(
                            title: 'Location',
                            value:
                                '${weatherData.name}, ${weatherData.sys!.country}',
                            iconData: Icons.location_on,
                            details: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Latitude: ${weatherData.coord!.lat!.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Longitude: ${weatherData.coord!.lon!.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          WeatherDetailCard(
                            title: 'Temperature',
                            value:
                                '${weatherData.main!.temp!.toStringAsFixed(1)}°',
                            iconData: Icons.thermostat,
                            details: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_downward_outlined,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Minimum: ${weatherData.main!.tempMin!.round()}°",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward_outlined,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Maximum: ${weatherData.main!.tempMax!.round()}°",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          WeatherDetailCard(
                            title: 'Wind Speed',
                            value:
                                '${weatherData.wind!.speed!.toStringAsFixed(1)} m/s',
                            iconData: Icons.air,
                          ),
                          WeatherDetailCard(
                            title: 'Weather',
                            value: controller
                                .weather.value!.weather![0].description!,
                            iconData: Icons.wb_sunny,
                            trailing: Image.network(
                              "http://openweathermap.org/img/w/${weatherData.weather![0].icon}.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                          WeatherDetailCard(
                            title: 'Sunrise',
                            value: Utils.convertUnixToReadableHour(
                                weatherData.sys!.sunrise!),
                            iconData: Icons.wb_sunny_outlined,
                          ),
                          WeatherDetailCard(
                            title: 'Sunset',
                            value: Utils.convertUnixToReadableHour(
                                weatherData.sys!.sunset!),
                            iconData: Icons.nights_stay,
                          ),
                          const SizedBox(
                            height: 40,
                          )
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherItemsWidget extends StatelessWidget {
  const WeatherItemsWidget({
    super.key,
    required this.controller,
  });

  final WeatherController controller;

  @override
  Widget build(BuildContext context) {
    final weatherData = controller.weather.value!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() {
          String condition =
              controller.weather.value!.weather?[0].main ?? 'Clear';
          String imagePath =
              controller.conditionBackgroundImages[condition] ?? '';
          return imagePath != ""
              ? Image.asset(
                  imagePath,
                  width: 200,
                  height: 200,
                )
              : const SizedBox.shrink();
        }),
        Text(
          '${weatherData.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${weatherData.main!.temp!.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          Utils.capitalizeFirstLetters(weatherData.weather![0].description!),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'H:${weatherData.main!.tempMax!.round()}° L:${weatherData.main!.tempMin!.round()}°',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class WeatherHomeDescriptionWidget extends StatelessWidget {
  const WeatherHomeDescriptionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome to the Weather App',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Start by searching for a location to see the weather forecast.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      ],
    );
  }
}
