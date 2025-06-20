import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/views/get_user_location.dart';
import 'package:google_maps_test/widgets/custom_google_maps.dart';

void main() {
  runApp(const GoogleMapTestApp());
}

class GoogleMapTestApp extends StatelessWidget {
  const GoogleMapTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetUserLocation(),
    );
  }
}
