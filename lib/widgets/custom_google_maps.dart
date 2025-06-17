import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/models/place_model.dart';

class CustomGoogleMaps extends StatefulWidget {
  const CustomGoogleMaps({super.key});

  @override
  State<CustomGoogleMaps> createState() => _CustomGoogleMapsState();
}

class _CustomGoogleMapsState extends State<CustomGoogleMaps> {
  late CameraPosition initialCameraPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialCameraPosition = const CameraPosition(
        target: LatLng(30.30508085801616, 31.74240675853906), zoom: 12);
    initMarkers();
  }
  //LatLng:
  // latitude, longitude
  // point on the map

  //zoom:
  // world view -> 0 to 3
  // country view -> 4 to 6
  // city view -> 10 to 12
  // street view -> 13 to 17
  // building view -> 18 to 20

  @override
  dispose() {
    super.dispose();
    googleMapController.dispose();
  }

  Set<Marker> markers = {};
  late GoogleMapController googleMapController;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          //mapType: MapType.normal, // the type of the map
          initialCameraPosition: // the first camera position
              initialCameraPosition,
          markers:
              markers, // markers > from type of Set<Marker>, because the marker is unique, so i can't add the same LatLng for another marker
          onMapCreated: (controller) {
            // use the controller to can control the google map , and can control the camera position of it
            googleMapController = controller;
            // update map style
            initMapStyle();
          },
          // cameraTargetBounds: CameraTargetBounds(
          //   LatLngBounds(
          //     // camera target bounds, the borders of the map that will be visible
          //     southwest: const LatLng(30.3136475891219, 31.692214008729618),
          //     northeast: const LatLng(30.320192748927237, 31.772583509448086),
          //   ),
          // ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          left: 16,
          child: ElevatedButton(
              onPressed: () {
                // CameraPosition newLocation = const CameraPosition(
                //     target: LatLng(30.265774406670108, 31.781848927381706),
                //     zoom: 12);
                // googleMapController
                //     .animateCamera(CameraUpdate.newCameraPosition(newLocation));
                // or if i want to update the latitude and longitude of the camera position only, i can update it only without need to create object from the whole CameraPosition
                LatLng newLatLng =
                    const LatLng(30.265774406670108, 31.781848927381706);
                googleMapController
                    .animateCamera(CameraUpdate.newLatLng(newLatLng));
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
    googleMapController.setMapStyle(mapStyle);
  }

  void initMarkers() {
    // var marker1 = Marker(
    //   markerId: const MarkerId('1'),
    //   position: LatLng(30.265774406670108, 31.781848927381706), // my location
    //   //infoWindow: const InfoWindow(title: 'Marker 1'),
    //   icon: BitmapDescriptor.defaultMarker,
    // );
    // // add the marker to the set of markers to show on the map
    // markers.add(marker1);
    // fetch the markers from list comes to me from api or some where:
    var myMarkers = places
        .map((placeModel) => Marker(
              markerId: MarkerId(placeModel.id.toString()),
              position: placeModel.latLng,
              infoWindow: InfoWindow(title: placeModel.name),
              icon: BitmapDescriptor.defaultMarker,
            ))
        .toSet(); // because markers is from type of Set<Marker>
    markers.addAll(myMarkers);
  }
}
