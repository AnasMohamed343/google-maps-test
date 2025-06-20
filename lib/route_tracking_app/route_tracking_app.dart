import 'package:flutter/material.dart';
import 'package:google_maps_test/route_tracking_app/views/google_map_view.dart';

class RouteTrackingApp extends StatelessWidget {
  const RouteTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoogleMapView(),
    );
  }
}
