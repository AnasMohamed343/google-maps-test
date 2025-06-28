import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/core/utils/location_service.dart';
import 'package:google_maps_test/route_tracking_app/core/services/places_service.dart';
import 'package:google_maps_test/route_tracking_app/core/services/routes_service.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/lat_lng.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/location.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/location_info.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_details_model/place_details_model.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/routes_model/routes_model.dart';

class MapServices {
  LocationService locationService = LocationService();
  PlacesService placesService = PlacesService();
  RoutesService routesService = RoutesService();
  LatLng? currentLocation;

  /// when i going to create method that has logic take time(await), and this function not return anything, must make this function > Future<void> to make it await when calling it, to wait until the logic that take time inside it to finished first.
  Future<void> getPredictions(
      {required String sessionToken,
      required String input,
      required List<PlaceModel> places}) async {
    if (input.isNotEmpty) {
      var results = await placesService.getPlaceAutocomplete(
          input: input, sessionToken: sessionToken);
      places.clear();
      places.addAll(results);
    } else {
      /// to clear the list when the text field is empty
      places.clear();
    }
  }

  Future<List<LatLng>> getRouteData(
      {required LatLng destinationLocation}) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation!.latitude,
          longitude: currentLocation!.longitude,
        ),
      ),
    );

    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destinationLocation.latitude,
          longitude: destinationLocation.longitude,
        ),
      ),
    );
    RoutesModel routes =
        await routesService.getRoutes(origin: origin, destination: destination);
    List<LatLng> points = getDecodedRoute(routes);

    return points;
  }

  List<LatLng> getDecodedRoute(RoutesModel routes) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints
        .decodePolyline(routes.routes!.first.polyline!.encodedPolyline!);

    List<LatLng> points =
        result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }

  void displayRoute(List<LatLng> points,
      {required GoogleMapController googleMapController,
      required Set<Polyline> polylines}) {
    Polyline route = Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      width: 4,
      color: Colors.blue,
    );
    polylines.add(route);

    LatLngBounds bounds = getLatLngBounds(points);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
      bounds,
      100,
    ));
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    /// to make the camera covers the whole route
    /// south-west > the smallest latitude and longitude from the route(points)
    /// north-east > the largest latitude and longitude from the route(points)
    ///
    var southWestLatitude = points.first.latitude;
    var southWestLongitude = points.first.longitude;
    var northEastLatitude = points.last.latitude;
    var northEastLongitude = points.last.longitude;
    for (var point in points) {
      southWestLatitude = min(southWestLatitude, point.latitude);
      southWestLongitude = min(southWestLongitude, point.longitude);
      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southWestLatitude, southWestLongitude),
      northeast: LatLng(northEastLatitude, northEastLongitude),
    );
  }

  /// without stream
  // Future<LatLng> updateCurrentLocation(
  //     {required GoogleMapController googleMapController,
  //     required Set<Marker> markers}) async {
  //   var locationData = await locationService.getCurrentLocation();
  //   var currentLocation =
  //       LatLng(locationData.latitude!, locationData.longitude!);
  //   Marker myLocationMarker = Marker(
  //       markerId: const MarkerId('myLocation'), position: currentLocation);
  //   CameraPosition myCurrentCameraPosition =
  //       CameraPosition(target: currentLocation, zoom: 12);
  //   googleMapController
  //       .animateCamera(CameraUpdate.newCameraPosition(myCurrentCameraPosition));
  //   markers.add(myLocationMarker);
  //   return currentLocation;
  // }

  /// with stream
  void updateCurrentLocation(
      {required GoogleMapController googleMapController,
      required Set<Marker> markers,
      required Function onUpdateCurrentLocation,
      required bool isFirstCall}) {
    locationService.getRealTimeLocationData((locationData) {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker myLocationMarker = Marker(
          markerId: const MarkerId('myLocation'), position: currentLocation!);
      if (isFirstCall) {
        CameraPosition myCurrentCameraPosition =
            CameraPosition(target: currentLocation!, zoom: 12);
        googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(myCurrentCameraPosition));
        isFirstCall = false;
      } else {
        googleMapController
            .animateCamera(CameraUpdate.newLatLng(currentLocation!));
      }
      markers.add(myLocationMarker);
      onUpdateCurrentLocation(); // setState(() {}); to update the UI
    });
  }

  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    return await placesService.getPlaceDetails(placeId: placeId);
  }
}
