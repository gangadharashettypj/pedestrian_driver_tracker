import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:location1/main.dart';

class MyMap extends StatefulWidget {
  final String userId;
  const MyMap(this.userId, {Key? key}) : super(key: key);
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (_added) {
          mymap(snapshot);
        }
        return GoogleMap(
          mapType: MapType.normal,
          markers: {
            Marker(
              position: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.userId)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.userId)['longitude'],
              ),
              markerId: const MarkerId('id'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                mode == 0
                    ? BitmapDescriptor.hueMagenta
                    : BitmapDescriptor.hueRed,
              ),
            ),
          },
          initialCameraPosition: CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.userId)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.userId)['longitude'],
              ),
              zoom: 14.47),
          onMapCreated: (GoogleMapController controller) async {
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              if (mounted) {
                setState(() {
                  _controller.dispose();
                  _controller = controller;
                  _added = true;
                });
              }
            });
          },
        );
      },
    ));
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.userId)['latitude'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.userId)['longitude'],
            ),
            zoom: 14.47),
      ),
    );
  }
}
