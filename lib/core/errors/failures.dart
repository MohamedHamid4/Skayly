sealed class AppFailure implements Exception {
  final String message;
  const AppFailure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network unavailable']);
}

class ApiFailure extends AppFailure {
  final int? statusCode;
  const ApiFailure(super.message, {this.statusCode});
}

class LocationFailure extends AppFailure {
  const LocationFailure([super.message = 'Location unavailable']);
}

class PermissionFailure extends AppFailure {
  final bool deniedForever;
  const PermissionFailure(super.message, {this.deniedForever = false});
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
