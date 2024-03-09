import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quanos_weather_app/data/services/location_service.dart';

class LocationController extends GetxController {
  final LocationService locationService = LocationService();
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString errorMessage = RxString('');

  @override
  void onInit() {
    // getCurrentLocation();
    super.onInit();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final position = await locationService.getCurrentLocation();
      currentPosition.value = position;
      return position;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }
}
