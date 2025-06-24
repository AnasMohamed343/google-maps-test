import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';

class GoogleMapsPlaceService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyA3rKLENN6Kev-Y4UKwvIvfPcNAwoH8ctc';

  Future<List<PlaceModel>> getPlaceAutocomplete({required String input}) async {
    var url = '$baseUrl/autocomplete/json?input=$input&key=$apiKey';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var places = json['predictions'] as List;
      return places.map((place) => PlaceModel.fromJson(place)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }
}
