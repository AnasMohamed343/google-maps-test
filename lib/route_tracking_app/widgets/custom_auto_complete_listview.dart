import 'package:flutter/material.dart';
import 'package:google_maps_test/route_tracking_app/core/services/google_maps_place_service.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_details_model/place_details_model.dart';

class AutoCompleteListView extends StatelessWidget {
  const AutoCompleteListView({
    super.key,
    required this.places,
    required this.googleMapsPlaceService,
    required this.onPlaceSelect,
  });

  final List<PlaceModel> places;
  final GoogleMapsPlaceService googleMapsPlaceService;
  final void Function(PlaceDetailsModel) onPlaceSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.grey[600],
              ),
              title: Text(places[index].description ?? ''),
              trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                ),
                onPressed: () async {
                  var placeDetails =
                      await googleMapsPlaceService.getPlaceDetails(
                          placeId: places[index].placeId.toString());

                  /// add a callback function, to achieve(and send) something from this widget to another widget.
                  onPlaceSelect(placeDetails);

                  /// add () > to call the function
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              height: 0,
            );
          },
          itemCount: places.length),
    );
  }
}
