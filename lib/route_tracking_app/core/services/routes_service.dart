import 'dart:convert';

import 'package:google_maps_test/route_tracking_app/data/api/models/location_info/location_info.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/routes_model/routes_model.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/routes_modifiers.dart';
import 'package:http/http.dart' as http;

class RoutesService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyA3rKLENN6Kev-Y4UKwvIvfPcNAwoH8ctc';

  Future<RoutesModel> getRoutes(
      {required LocationInfoModel origin,
      required LocationInfoModel destination,
      RoutesModifiers? routesModifiers}) async {
    Uri url = Uri.parse(baseUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
    };

    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routesModifiers != null
          ? routesModifiers.toJson()
          : RoutesModifiers().toJson(),

      /// : RoutesModifiers().toJson() > to take the default value(false), if the value with null.
      "languageCode": "en-US",
      "units": "METRIC"
    };

    var response = await http.post(url,
        headers: headers, body: jsonEncode(body)); // jsonEncode(body)

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return RoutesModel.fromJson(json);
    } else {
      throw Exception('no routes found');
    }
  }
}
