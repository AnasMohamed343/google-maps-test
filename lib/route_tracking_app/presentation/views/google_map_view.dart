import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/core/utils/location_service.dart';
import 'package:google_maps_test/route_tracking_app/core/services/google_maps_place_service.dart';
import 'package:google_maps_test/route_tracking_app/core/services/routes_service.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/lat_lng.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/location.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/location_info.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/routes_model/route.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/routes_model/routes_model.dart';
import 'package:google_maps_test/route_tracking_app/widgets/custom_auto_complete_listview.dart';
import 'package:google_maps_test/route_tracking_app/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late GoogleMapsPlaceService googleMapsPlaceService;
  late Uuid uuid;
  late RoutesService routesService;
  late LatLng currentLocation;
  late LatLng destinationLocation;

  ///
  String? sessionToken;

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();
    googleMapsPlaceService = GoogleMapsPlaceService();
    textEditingController = TextEditingController();
    uuid = const Uuid();
    routesService = RoutesService();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();

      ///
      /// to listen to text changes, every time i write something in the text field > i will call the logic in this function
      if (textEditingController.text.isEmpty) {
        var results = await googleMapsPlaceService.getPlaceAutocomplete(
            input: textEditingController.text, sessionToken: sessionToken!);
        places.clear();
        places.addAll(results);
        setState(() {});
      } else {
        /// to clear the list when the text field is empty
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Set<Marker> markers = {};
  List<PlaceModel> places = [];
  Set<Polyline> polylines = {};
  @override
  Widget build(BuildContext context) {
    print(uuid.v4());
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();

            /// put updateCurrentLocation here > to be inure that googleMapController is already initialized.
          },
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          polylines: polylines,
        ),
        Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Column(
              children: [
                CustomTextField(
                  textEditingController: textEditingController,
                ),
                const SizedBox(
                  height: 15,
                ),
                places.isEmpty
                    ? const SizedBox()
                    : AutoCompleteListView(
                        places: places,
                        onPlaceSelect: (placeDetailsModel) async {
                          textEditingController.clear();
                          places.clear();
                          sessionToken = null;

                          /// make the sessionToken null at the end of request(when click on place details), to create a new sessionToken at the first of the request.
                          setState(() {});
                          googleMapController.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                                  target: LatLng(
                                      placeDetailsModel
                                          .geometry!.location!.lat!,
                                      placeDetailsModel
                                          .geometry!.location!.lng!),
                                  zoom: 12)));
                          destinationLocation = LatLng(
                              placeDetailsModel.geometry!.location!.lat!,
                              placeDetailsModel.geometry!.location!.lng!);
                          var points = await getRouteData();
                          displayRoute(points);
                        },
                        googleMapsPlaceService: googleMapsPlaceService),
              ],
            )),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getCurrentLocation();
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker myLocationMarker = Marker(
          markerId: const MarkerId('myLocation'), position: currentLocation);
      CameraPosition myCurrentCameraPosition =
          CameraPosition(target: currentLocation, zoom: 12);
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraPosition));
      markers.add(myLocationMarker);
      setState(() {});
    } on LocationServiceException catch (e) {
    } on LocationPermissionException catch (e) {
    } catch (e) {}
  }

  Future<List<LatLng>> getRouteData() async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
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

  void displayRoute(List<LatLng> points) {
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
    setState(() {});
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
}

// create text field
// listen to the text field
// search place
// display results
