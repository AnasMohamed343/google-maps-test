import 'package:flutter/material.dart';
import 'package:google_maps_test/route_tracking_app/data/api/models/place_autocomplete_model/place_autocomplete_model.dart';

class AutoCompleteListView extends StatelessWidget {
  const AutoCompleteListView({
    super.key,
    required this.places,
  });

  final List<PlaceModel> places;

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
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
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
