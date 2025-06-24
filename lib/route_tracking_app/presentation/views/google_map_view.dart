import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/core/utils/location_service.dart';
import 'package:google_maps_test/route_tracking_app/core/services/google_maps_place_service.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_test/route_tracking_app/widgets/custom_auto_complete_listview.dart';
import 'package:google_maps_test/route_tracking_app/widgets/custom_text_field.dart';

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
  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();
    googleMapsPlaceService = GoogleMapsPlaceService();
    textEditingController = TextEditingController();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      /// to listen to text changes, every time i write something in the text field > i will call the logic in this function
      if (textEditingController.text.isEmpty) {
        var results = await googleMapsPlaceService.getPlaceAutocomplete(
            input: textEditingController.text);
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
  @override
  Widget build(BuildContext context) {
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
        ),
        Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                CustomTextField(
                  textEditingController: textEditingController,
                ),
                SizedBox(
                  height: 15,
                ),
                AutoCompleteListView(places: places)
              ],
            )),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getCurrentLocation();
      var newLatLng = LatLng(locationData.latitude!, locationData.longitude!);
      Marker myLocationMarker =
          Marker(markerId: MarkerId('myLocation'), position: newLatLng);
      CameraPosition myCurrentCameraPosition =
          CameraPosition(target: newLatLng, zoom: 12);
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraPosition));
      markers.add(myLocationMarker);
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
