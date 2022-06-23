import 'package:flutter/material.dart';
import 'package:flutter_google_map/directions_model.dart';
import 'package:flutter_google_map/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCamerPosition =
      CameraPosition(target: LatLng(11.0016, 77.5626), zoom: 12);

  GoogleMapController _googleMapController;
  Marker origin;
  Marker destination;
  Directions info;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _googleMapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCamerPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (origin != null) origin,
              if (destination != null) destination
            },
            polylines: {
              if (info != null)
                Polyline(
                    polylineId: PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: info.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList()),
            },
            onLongPress: _addMarker,
          ),
          if (info != null)
            Positioned(
                top: 20.0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0)
                      ]),
                  child: Text(
                    '${info.totalDistance},${info.totalDuration}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                  ),
                ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.center_focus_strong),
        onPressed: () => _googleMapController.animateCamera(info != null
            ? CameraUpdate.newLatLngBounds(info.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCamerPosition)),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (origin == null || (origin != null && destination != null)) {
      //Set origin
      setState(() {
        origin = Marker(
            markerId: MarkerId('origin'),
            infoWindow: const InfoWindow(title: "Origin"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        destination = null;
        info = null;
      });
    } else {
      //Set destination
      setState(() {
        destination = Marker(
            markerId: MarkerId('destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: pos);
      });
      //Get directions
      final directions = await DirectionRepository()
          .getDirections(origin.position, destination.position);
      setState(() => info = directions);
    }
  }
}
