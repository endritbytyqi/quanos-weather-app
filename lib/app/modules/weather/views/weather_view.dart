import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanos_weather_app/utils/widgets.dart';
import '../controllers/weather_controller.dart';
import 'package:intl/intl.dart';

class WeatherView extends GetView<WeatherController> {
  WeatherView({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4788ED), Color(0xFF6CA8F1)],
              ),
            ),
          ),
          // Weather content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48), // Spacing for status bar
              // Location search and current weather
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
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
                            if (_searchController.text.isNotEmpty) {
                              controller
                                  .getWeatherForCity(_searchController.text);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.weather.value != null) {
                        return Column(
                          children: [
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
                      } else {
                        return const CircularProgressIndicator(
                            color: Colors.white);
                      }
                    }),
                  ],
                ),
              ),
              // Weather details list
              Expanded(
                child: Obx(() {
                  if (controller.weather.value != null) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          WeatherDetailCard(
                            title: 'Location',
                            value:
                                '${controller.weather.value!.name}, ${controller.weather.value!.sys!.country}',
                            iconData: Icons.location_on,
                          ),
                          WeatherDetailCard(
                            title: 'Temperature',
                            value:
                                '${controller.weather.value!.main!.temp!.toStringAsFixed(1)}°',
                            iconData: Icons.thermostat,
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
                            value: convertUnixToReadableHour(
                                controller.weather.value!.sys!.sunrise!),
                            iconData: Icons.wb_sunny_outlined,
                          ),
                          WeatherDetailCard(
                            title: 'Sunset',
                            value: convertUnixToReadableHour(
                                controller.weather.value!.sys!.sunset!),
                            iconData: Icons.nights_stay,
                          ),
                          SwitchListTile(
                            title: const Text('Toggle Units'),
                            subtitle: Text(controller.isMetric.value
                                ? 'Metric'
                                : 'Imperial'),
                            value: controller.isMetric.value,
                            onChanged: (bool value) {
                              controller.toggleUnit();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                        child: Text('Please search for a location'));
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String convertUnixToReadableHour(int unixTimestamp) {
  // Convert the Unix timestamp to a DateTime object
  DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

  // Format the DateTime object to a readable hour format
  String formattedTime = DateFormat('h:mm a').format(date);

  return formattedTime;
}
