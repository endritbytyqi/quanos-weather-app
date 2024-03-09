import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanos_weather_app/app/modules/weather/controllers/location_controller.dart';
import 'package:quanos_weather_app/utils/utils.dart';
import 'package:quanos_weather_app/utils/widgets.dart';
import '../controllers/weather_controller.dart';
import 'package:intl/intl.dart';

class WeatherView extends GetView<WeatherController> {
  WeatherView({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(LocationController());
    final locationController = Get.find<LocationController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (_searchController.text.isNotEmpty) {
            try {
              await controller.checkRateLimitAndRefresh(_searchController.text);
            } catch (e) {
              Get.snackbar("Rate Limit Exceeded", e.toString(),
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          }
        },
        child: Stack(
          children: [
            // Background gradient
            Obx(() => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: controller.isDayTime.value
                          ? [
                              const Color(0xFF4788ED),
                              const Color(0xFF6CA8F1)
                            ] // Day colors
                          : [
                              Color.fromARGB(255, 2, 41, 99),
                              Color.fromARGB(255, 4, 40, 77)
                            ], // Night colors
                    ),
                  ),
                )),
            // Weather content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48), // Spacing for status bar
                  // Location search and current weather
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
                                    _searchController.text = "";
                                  } else {
                                    // Handle error or show a message
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
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter a location',
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

                                        if (_searchController.text.isNotEmpty) {
                                          controller.getWeatherForCity(
                                              _searchController.text);
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
                      return Column(
                        children: [
                          WeatherDetailCard(
                            title: 'Location',
                            value:
                                '${controller.weather.value!.name}, ${controller.weather.value!.sys!.country}',
                            iconData: Icons.location_on,
                            details: Text(
                                "Latitude: ${controller.weather.value!.coord!.lat}, Longitude: ${controller.weather.value!.coord!.lon}"),
                          ),
                          WeatherDetailCard(
                            title: 'Temperature',
                            value:
                                '${controller.weather.value!.main!.temp!.toStringAsFixed(1)}°',
                            iconData: Icons.thermostat,
                            details: Text(
                                "Minimum Temperature: ${controller.weather.value!.main!.tempMin!.round()}°\nMaximum Temperature: ${controller.weather.value!.main!.tempMax!.round()}°"),
                          ),
                          WeatherDetailCard(
                            title: 'Wind Speed',
                            value:
                                '${controller.weather.value!.wind!.speed!.toStringAsFixed(1)} m/s',
                            iconData: Icons.air,
                          ),
                          WeatherDetailCard(
                            title: 'Weather',
                            value: controller
                                .weather.value!.weather![0].description!,
                            iconData: Icons.wb_sunny,
                            trailing: Image.network(
                              "http://openweathermap.org/img/w/${controller.weather.value!.weather![0].icon}.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                          WeatherDetailCard(
                            title: 'Sunrise',
                            value: Utils.convertUnixToReadableHour(
                                controller.weather.value!.sys!.sunrise!),
                            iconData: Icons.wb_sunny_outlined,
                          ),
                          WeatherDetailCard(
                            title: 'Sunset',
                            value: Utils.convertUnixToReadableHour(
                                controller.weather.value!.sys!.sunset!),
                            iconData: Icons.nights_stay,
                          ),
                          SwitchListTile(
                            title: const Text(
                              'Toggle Units',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              controller.isMetric.value ? 'Metric' : 'Imperial',
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: controller.isMetric.value,
                            onChanged: (bool value) {
                              controller.toggleUnit();
                            },
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() {
          String condition =
              controller.weather.value?.weather?[0].main ?? 'Clear';
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
          '${controller.weather.value!.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${controller.weather.value!.main!.temp!.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'H:${controller.weather.value!.main!.tempMax!.round()}° L:${controller.weather.value!.main!.tempMin!.round()}°',
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
          padding: const EdgeInsets.all(16.0),
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
