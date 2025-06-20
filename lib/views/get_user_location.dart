import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/core/utils/location_service.dart';
import 'package:location/location.dart';

///  to didn't had issue when i lunch the app on play store:
/// note > when i add a permission to info.plist, after i add the permission key , to add a string that describe the exactly permission purpose and why i want to add this permission.
class GetUserLocation extends StatefulWidget {
  const GetUserLocation({super.key});

  @override
  State<GetUserLocation> createState() => _GetUserLocationState();
}

class _GetUserLocationState extends State<GetUserLocation> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;

  @override
  initState() {
    super.initState();
    initialCameraPosition = const CameraPosition(
        target: LatLng(30.30508085801616, 31.74240675853906), zoom: 12);
    locationService = LocationService();
    updateMyLocation();
  }

  @override
  dispose() {
    googleMapController?.dispose();
    super.dispose();
  }

  bool isFirstCall = true;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid, // the type of the map
          initialCameraPosition: // the first camera position
              initialCameraPosition,
          zoomControlsEnabled: false, // to hide the zoom buttons on the map
          markers: markers,
          onMapCreated: (controller) {
            // use the controller to can control the google map , and can control the camera position of it
            googleMapController = controller;
            // update map style
            initMapStyle();
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          left: 16,
          child: ElevatedButton(
              onPressed: () {
                LatLng newLatLng =
                    const LatLng(30.265774406670108, 31.781848927381706);
                googleMapController
                    ?.animateCamera(CameraUpdate.newLatLng(newLatLng));
              },
              child: Text('Change Location')),
        ),
      ],
    );
  }

  void initMapStyle() async {
    //DefaultAssetBundle -> to load String from assets
    var mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/retro_map_style.json');
    googleMapController!.setMapStyle(mapStyle);
  }

  void updateMyLocation() async {
    await locationService.checkAndRequestLocationService();
    var hasPermission =
        await locationService.checkAndRequestLocationPermission();
    if (hasPermission) {
      locationService.getRealTimeLocationData(
        (locationData) {
          var newLatLng =
              LatLng(locationData.latitude!, locationData.longitude!);
          setMyLocationMarker(newLatLng);
          updateMyRealTimeCamera(newLatLng);
        },
      );
    } else {
      // TODO: show a dialog to the user to enable the location permission
    }
  }

  void updateMyRealTimeCamera(LatLng newLatLng) {
    //var newCameraPosition = CameraPosition(target: newLatLng, zoom: 12);
    // googleMapController
    //     ?.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    /// or update only the newLatLng, to not update the zoom with it, and provide the user to can make zoom while moving without returning it to the new updated zoom every newCameraPosition.
    //googleMapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
    ///best case:
    if (isFirstCall) {
      var newCameraPosition = CameraPosition(target: newLatLng, zoom: 12);
      googleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
      isFirstCall = false;
    } else {
      googleMapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
    }
  }

  void setMyLocationMarker(LatLng newLatLng) {
    var myLocationMarker =
        Marker(markerId: MarkerId('myLocation'), position: newLatLng);
    markers.add(myLocationMarker);
    setState(() {});

    ///will rebuild when location data changed(means every 2 meters(based on distanceFilter)), to update the marker on the UI with the every new camera position
  }
}
