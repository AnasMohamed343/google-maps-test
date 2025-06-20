import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

import 'package:google_maps_test/core/models/place_model.dart';

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
    initPolyLines();
    initPolyGons();
    initCircles();
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
  Set<Polyline> polyLines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};
  late GoogleMapController googleMapController;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          //mapType: MapType.normal, // the type of the map
          initialCameraPosition: // the first camera position
              initialCameraPosition,
          zoomControlsEnabled: false, // to hide the zoom buttons on the map
          markers:
              markers, // markers > from type of Set<Marker>, because the marker is unique, so i can't add the same LatLng for another marker
          polylines: polyLines,
          polygons: polygons,
          circles:
              circles, // use it when as example > has a restaurant that order his service with delivery around 1k distance from his place,
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

  /// use this method when i didn't have access on the marker images(like if fetch it from api)
  /// but if i was had access on the marker image , i can use any tool from the internet to resize the image then show it with the new size without needing to use the method(because the method taking time to resize the image)
  /// change the size of the image(marker)
  Future<Uint8List> getImageFromRowData(String imagePath, double width) async {
    var imageData = await rootBundle.load(
        imagePath); // first convert the image to Uint8List(row) to can use it to change the size
    var imageCodec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetWidth: width.round());
    var imageFrameInfo = await imageCodec.getNextFrame();
    var imageByteData =
        await imageFrameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return imageByteData!.buffer.asUint8List();

    /// buffer -> is a type of dataStructure that holds data
  }

  Future<void> initMarkers() async {
    // BitmapDescriptor customMarkerIcon = await BitmapDescriptor.asset(
    //     ImageConfiguration(), 'assets/images/marker.png');
    BitmapDescriptor customMarkerIcon = BitmapDescriptor.bytes(
      await getImageFromRowData('assets/images/marker.png', 50),
    );
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

              ///must make the markerId unique
              position: placeModel.latLng,

              /// must make the position unique, because if there was two markers with same position, the second marker will be hidden
              infoWindow: InfoWindow(title: placeModel.name),
              icon: customMarkerIcon,
            ))
        .toSet(); // because markers is from type of Set<Marker>
    markers.addAll(myMarkers);
    setState(() {});
  }

  void initPolyLines() {
    Polyline polyLine1 = const Polyline(
      polylineId: PolylineId('1'),
      color: Colors.blue,
      endCap: Cap.roundCap, // the end of the line
      startCap: Cap.roundCap, // the start of the line
      zIndex: 2,
      width: 4,
      points: [
        LatLng(30.315438991561837, 31.741801673924165),
        LatLng(30.320429083859867, 31.769723403613956),
        LatLng(30.29745372077975, 31.742347020207166),
      ],
    );
    Polyline polyLine2 = const Polyline(
      //geodesic: true, // to make the line not straight but geodesic(mean the line will be curved), should use it with the big polyLine
      polylineId: PolylineId('1'),
      color: Colors.red,
      endCap: Cap.roundCap, // the end of the line
      startCap: Cap.roundCap, // the start of the line
      zIndex:
          1, // this polyLine will drawn first because its zIndex is small than the other zIndex of the other polyLine, so this polyLine will be in the bottom
      width: 4,
      patterns: [PatternItem.dot], // the line will be dotted
      points: [
        LatLng(30.292974093636985, 31.77061039336038),
        LatLng(30.335856445783744, 31.738616709506385),
      ],
    );
    polyLines.add(polyLine1);
    polyLines.add(polyLine2);
  }

  void initPolyGons() {
    // Polygons is used to draw 2 dimensional shapes
    Polygon polygon1 = Polygon(
        polygonId: PolygonId('1'),
        fillColor: Colors.red.withOpacity(0.5),
        strokeColor: Colors.red,
        strokeWidth: 3,
        points: [
          LatLng(30.295954660340257,
              31.708306903749975), // the first point in polygon will be the end point
          LatLng(30.299516682209024, 31.71470564052077),
          LatLng(30.295809268944158, 31.718494366240325),
          LatLng(30.292683301791765, 31.712937568518313),
        ],

        /// holoPolygon
        holes: [
          [
            LatLng(30.29668984337322, 31.710759470967737),
            LatLng(30.296560153701588, 31.711177895552506),
            LatLng(30.296310037421986, 31.711124251374972),
            LatLng(30.296198874426263, 31.710287402205438)
          ]
        ]);
    polygons.add(polygon1);
  }

  void initCircles() {
    Circle restaurantServiceCircle = Circle(
        circleId: CircleId('1'),
        center: LatLng(30.296824269116843,
            31.726004979635828), // the LatLng of the restaurant
        radius: 1000,

        ///(1k) the distance that the restaurant provide his service arround it(as examole).
        fillColor: Colors.lightGreen.withOpacity(0.5),
        strokeColor: Colors.lightGreen,
        strokeWidth: 2);
    circles.add(restaurantServiceCircle);
  }
}
