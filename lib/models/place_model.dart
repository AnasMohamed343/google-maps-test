import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latLng;

  PlaceModel(this.id, this.name, this.latLng);
}

List<PlaceModel> places = [
  PlaceModel(1, "Diamond", LatLng(30.315438991561837, 31.741801673924165)),
  PlaceModel(2, "H Rashad", LatLng(30.320429083859867, 31.769723403613956)),
  PlaceModel(3, "Mereta", LatLng(30.29745372077975, 31.742347020207166)),
  PlaceModel(4, "badr", LatLng(30.30884791414815, 31.716497606392785)),
];
