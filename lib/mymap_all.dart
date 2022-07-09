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

              List<dynamic> datas = [];

              snapshot.data!.docs.forEach((element) {
                final mapData = element.data() as Map;
                if (mapData.containsKey('latitude') &&
                    mapData.containsKey('longitude')) {
                  datas.add(element);
                }
              });
              return GoogleMap(
                mapType: MapType.normal,
                markers: {
                  ...datas.map(
                    (e) {
                      final data = e.data() as Map;
                      return Marker(
                        position: LatLng(
                          data['latitude'],
                          data['longitude'],
                        ),
                        markerId: const MarkerId('id'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          widget.userId == data['id']
                              ? BitmapDescriptor.hueGreen
                              : (data['mode'] == 0
                                  ? BitmapDescriptor.hueCyan
                                  : BitmapDescriptor.hueRed),
                        ),
                        onTap: () {
                          if (mounted)
                            setState(() {
                              selectedUser = e;
                            });
                        },
                      );
                    },
                  ),
                },
                initialCameraPosition: CameraPosition(
                    target: (datas
                            .where((element) => element.id == widget.userId)
                            .isNotEmpty)
                        ? LatLng(
                            (datas
                                .singleWhere(
                                    (element) => element.id == widget.userId)
                                .data() as Map)['latitude'],
                            (datas
                                .singleWhere(
                                    (element) => element.id == widget.userId)
                                .data() as Map)['longitude'],
                          )
                        : const LatLng(13.321546, 77.099664),
                    zoom: 14.47),
                onMapCreated: (GoogleMapController controller) async {
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    if (mounted) {
                      setState(() {
                        _controller = controller;
                      });
                    }
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
