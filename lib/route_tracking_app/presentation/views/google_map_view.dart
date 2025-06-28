import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/core/utils/location_service.dart';
import 'package:google_maps_test/route_tracking_app/core/services/map_services.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';
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
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late Uuid uuid;
  late LatLng currentLocation;
  late LatLng destinationLocation;
  late MapServices mapServices;

  ///
  String? sessionToken;

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    textEditingController = TextEditingController();
    mapServices = MapServices();
    uuid = const Uuid();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();

      ///
      /// to listen to text changes, every time i write something in the text field > i will call the logic in this function
      await mapServices.getPredictions(
          sessionToken: sessionToken!,
          input: textEditingController.text,
          places: places);
      setState(() {});
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
    if (kDebugMode) {
      print(uuid.v4());
    }
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
                          var points = await mapServices.getRouteData(
                              currentLocation: currentLocation,
                              destinationLocation: destinationLocation);
                          mapServices.displayRoute(points,
                              googleMapController: googleMapController,
                              polylines: polylines);
                          setState(() {});
                        },
                        mapServices: mapServices),
              ],
            )),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      currentLocation = await mapServices.updateCurrentLocation(
          googleMapController: googleMapController, markers: markers);
      setState(() {});
    } on LocationServiceException catch (e) {
    } on LocationPermissionException catch (e) {
    } catch (e) {}
  }
}

// create text field
// listen to the text field
// search place
// display results
