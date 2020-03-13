import 'package:geolocator/geolocator.dart';

class LocationManager {
  static final LocationManager _singleton = new LocationManager._internal();

  factory LocationManager() => _singleton;

  LocationManager._internal() {}

  Future<Position> getCurrentLocation({int timeout = 5}) async {
    Position position;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final Geolocator geolocator = Geolocator();
      position = await geolocator
          .getCurrentPosition()
          .timeout(Duration(seconds: timeout));
    } catch (ex, stacktrace) {
      position = null;
    }
    return Future.value(position);
  }
}
