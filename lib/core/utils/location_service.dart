import 'package:location/location.dart';

class LocationService {
  /// steps to get user location
  /// first inquire about the location service
  /// 1- request permission from the user to access the location
  /// 2- get the current location
  /// 3- display the location on the map

  Location location = Location();

  Future<void> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        throw LocationServiceException();
      }
    }
  }

  Future<void> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.requestPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      throw LocationPermissionException();
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        throw LocationPermissionException();
      }
    }
  }

  void getRealTimeLocationData(
    void Function(LocationData)? onData,
  ) async {
    location.changeSettings(
      distanceFilter: 2,

      /// means > send the location data every 2 meters
    );
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();

    /// the stream works every 1 second(interval(frequency)) > every 1 second will look to the distanceFilter if was took 2 meters > send the location data, if not will look again after 1 second.
    location.onLocationChanged.listen(onData);
  }

  /// get the current location without the stream
  Future<LocationData> getCurrentLocation() async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    return await location.getLocation();
  }
}

class LocationServiceException implements Exception {}

class LocationPermissionException implements Exception {}
