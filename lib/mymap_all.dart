import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMapAll extends StatefulWidget {
  final String userId;

  const MyMapAll(this.userId, {Key? key}) : super(key: key);

  @override
  _MyMapAllState createState() => _MyMapAllState();
}

class _MyMapAllState extends State<MyMapAll> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;

  QueryDocumentSnapshot? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        // if (selectedUser != null)
        //   Column(
        //     children: [
        //       const Text(
        //         'SELECTED USER :',
        //         style: TextStyle(
        //           color: Colors.blue,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       const SizedBox(
        //         width: 10,
        //       ),
        //       Text(
        //         'Name: ${selectedUser!['name'].toString()}',
        //       ),
        //       const SizedBox(
        //         width: 10,
        //       ),
        //       Text(
        //         'LAT: ${selectedUser!['latitude'].toString()}',
        //       ),
        //       const SizedBox(
        //         width: 10,
        //       ),
        //       Text(
        //         'LNG: ${selectedUser!['longitude'].toString()}',
        //       ),
        //     ],
        //   ),
        // const SizedBox(
        //   height: 20,
        // ),
        Expanded(
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('location').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return GoogleMap(
                mapType: MapType.normal,
                markers: {
                  ...snapshot.data!.docs.map(
                    (e) => Marker(
                      position: LatLng(
                        e['latitude'],
                        e['longitude'],
                      ),
                      markerId: const MarkerId('id'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        widget.userId == e['id']
                            ? BitmapDescriptor.hueGreen
                            : (e['mode'] == 0
                                ? BitmapDescriptor.hueCyan
                                : BitmapDescriptor.hueRed),
                      ),
                      onTap: () {
                        setState(() {
                          selectedUser = e;
                        });
                      },
                    ),
                  ),
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      snapshot.data!.docs.singleWhere(
                          (element) => element.id == widget.userId)['latitude'],
                      snapshot.data!.docs.singleWhere((element) =>
                          element.id == widget.userId)['longitude'],
                    ),
                    zoom: 14.47),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                  });
                },
              );
            },
          ),
        ),
      ],
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
