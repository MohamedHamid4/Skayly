import 'package:geolocator/geolocator.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  const LocationResult(this.latitude, this.longitude);
}

class LocationService {
  Future<LocationResult> getCurrentPosition() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      throw const LocationFailure('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionFailure('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionFailure(
        'Location permission permanently denied',
        deniedForever: true,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition()
          .timeout(AppConstants.networkTimeout);
      return LocationResult(position.latitude, position.longitude);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw LocationFailure('Could not determine location: $e');
    }
  }
}
