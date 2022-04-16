import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:location1/mymap.dart';
import 'package:location1/mymap_all.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_device_id/platform_device_id.dart';

String deviceId = '';
String userName = '';
int mode = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  deviceId = await PlatformDeviceId.getDeviceId ?? '';
  final data = await FirebaseFirestore.instance
      .collection('location')
      .doc(deviceId)
      .get();
  try {
    mode = data.data()?['mode'] ?? 0;
    userName = data.data()?['name'] ?? 'GUEST';
  } catch (e) {
    print(e);
  }
  FirebaseFirestore.instance.collection('location').doc(deviceId).set({
    'id': deviceId,
    'name': userName,
    'mode': mode,
  }, SetOptions(merge: true));
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final loc.Location location = loc.Location();
  final nameController = TextEditingController(text: userName);
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool map = true;
  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 2000,
    );
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: mode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'LOCATION TRACKER',
          ),
          actions: [
            Row(
              children: [
                const Text('LIST'),
                Switch(
                  value: map,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    setState(() {
                      map = val;
                    });
                  },
                ),
                const Text('MAP'),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(
                text: "Driver",
              ),
              Tab(
                text: "Pedestrian",
              ),
            ],
            onTap: (index) {
              mode = index;
              FirebaseFirestore.instance
                  .collection('location')
                  .doc(deviceId)
                  .set({
                'mode': index,
              }, SetOptions(merge: true));
            },
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'ID: $deviceId',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (deviceId.isEmpty) return;
                      await FirebaseFirestore.instance
                          .collection('location')
                          .doc(deviceId)
                          .set({
                        'name': nameController.text,
                        'id': deviceId,
                        'latitude': '',
                        'longitude': '',
                      }, SetOptions(merge: true));
                    },
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     _getLocation();
            //   },
            //   child: const Text('add my location'),
            // ),
            const SizedBox(
              height: 16,
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  if (_locationSubscription == null) {
                    _listenLocation();
                  } else {
                    _stopListening();
                  }
                });
              },
              child: Text(
                _locationSubscription == null
                    ? 'ENABLE  LOCATION'
                    : 'DISABLE  LOCATION',
                style: TextStyle(
                  color:
                      _locationSubscription == null ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     _stopListening();
            //   },
            //   child: const Text('STOP'),
            // ),
            Visibility(
              visible: map,
              child: Expanded(
                child: MyMapAll(
                  deviceId,
                ),
              ),
            ),
            Visibility(
              visible: !map,
              child: Expanded(
                  child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('location')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        var lat = '';
                        var long = '';
                        try {
                          lat =
                              snapshot.data!.docs[index]['latitude'].toString();
                          long = snapshot.data!.docs[index]['longitude']
                              .toString();
                        } catch (_) {}
                        return ListTile(
                          title: Text(
                            '${snapshot.data!.docs[index]['name'].toString()}  ${snapshot.data!.docs[index]['id'].toString() == deviceId ? '(YOU)' : ''}',
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                snapshot.data!.docs[index]['mode'] == 0
                                    ? 'DRIVER'
                                    : 'PEDESTRIAN',
                                style: TextStyle(
                                  color: snapshot.data!.docs[index]['mode'] == 0
                                      ? Colors.cyan
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(lat),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(long),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.directions,
                              color: lat.isNotEmpty && long.isNotEmpty
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              if (lat.isNotEmpty && long.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MyMap(
                                      snapshot.data!.docs[index].id,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      });
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      if (deviceId.isEmpty) return;
      await FirebaseFirestore.instance
          .collection('location')
          .doc(deviceId)
          .set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      if (deviceId.isEmpty) return;
      await FirebaseFirestore.instance
          .collection('location')
          .doc(deviceId)
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
