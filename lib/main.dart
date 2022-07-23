import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart' as loc;
import 'package:location1/auth/auth_utils.dart';
import 'package:location1/images.dart';
import 'package:location1/login/login.dart';
import 'package:location1/mymap.dart';
import 'package:location1/mymap_all.dart';
import 'package:location1/profile.dart';
import 'package:location1/routes.dart';
import 'package:location1/sized_box.dart';
import 'package:location1/splash_screen.dart';
import 'package:location1/widgets/image_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:url_launcher/url_launcher.dart';

String deviceId = '';
String userName = '';
int mode = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerLazySingleton<AuthUtils>(() => AuthUtils());
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/logo',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  await Firebase.initializeApp();
  await _requestPermission();
  final isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    // This is just a basic example. For real apps, you must show some
    // friendly dialog box before call the request method.
    // This is very important to not harm the user experience
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  deviceId = await PlatformDeviceId.getDeviceId ?? '';

  runApp(
    MaterialApp(
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.home: (_) => const MyApp(),
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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

    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 2000,
    );
    location.enableBackgroundMode(enable: true);
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: mode,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              InkWell(
                radius: 100,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
                child: ImageWidget(
                  imageLocation: MyImages.profile,
                  height: 26,
                ),
              ),
              CustomSizedBox.w12,
              const Text(
                'TRACKER',
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                const Text('LIST'),
                Switch(
                  value: map,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    if (mounted) {
                      setState(() {
                        map = val;
                      });
                    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        if (_locationSubscription == null) {
                          _listenLocation();
                        } else {
                          _stopListening();
                        }
                      });
                    }
                  },
                  child: Text(
                    _locationSubscription == null
                        ? 'ENABLE  LOCATION'
                        : 'DISABLE  LOCATION',
                    style: TextStyle(
                      color: _locationSubscription == null
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final loc.LocationData _locationResult =
                        await location.getLocation();
                    print('>>>>>>>>>>>');
                    print(_locationResult.latitude);
                    print(_locationResult.longitude);
                    print(
                        'https://maps.google.com?q=${_locationResult.latitude},${_locationResult.longitude}');
                    final uri =
                        'mailto:${FirebaseAuth.instance.currentUser?.photoURL ?? "emergency@gmail.com"}?cc=roadsafety71@gmail.com&subject=Emergency Alert&body=Hello sir,\nThere is some emregency for ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}.\nLocation: ${Uri.encodeComponent('https://maps.google.com?q=${_locationResult.latitude?.toStringAsFixed(6) ?? ''},${_locationResult.longitude?.toStringAsFixed(6) ?? ''}')}\nPlease check with them once.\n\nThank You';
                    print(await canLaunchUrl(Uri.parse(uri)));
                    if (await canLaunchUrl(Uri.parse(uri))) {
                      await launchUrl(Uri.parse(uri));
                    } else {
                      throw 'Could not launch $uri';
                    }
                  },
                  child: const Text(
                    'Send Emergency Mail',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
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
                  int usersCount = getAlert(snapshot.data!.docs);
                  return Column(
                    children: [
                      Container(
                        child: Center(
                          child: Text(
                            getMessage(usersCount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        color: getColor(usersCount),
                        width: double.infinity,
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              var lat = '';
                              var long = '';
                              try {
                                lat = snapshot.data!.docs[index]['latitude']
                                    .toString();
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
                                        color: snapshot.data!.docs[index]
                                                    ['mode'] ==
                                                0
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
                            }),
                      ),
                    ],
                  );
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
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            _locationSubscription = null;
          });
        }
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {
          _locationSubscription = null;
        });
      }
    });
  }
}

String getMessage(int count) {
  String str = 'RISK LEVEL:  LOW';

  if (count > 2) {
    str = 'RISK LEVEL:  HIGH';
  }
  else if (count > 1) {
    str = 'RISK LEVEL:  MEDIUM';
  }
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'Pedestrian Tracker',
      body: str,
    ),
  );
  return str;
}

Color getColor(int count) {
  if (count > 2) {
    return Colors.red;
  }
  if (count > 1) {
    return Colors.orange;
  }
  return Colors.green;
}

int getAlert(List<QueryDocumentSnapshot<Object?>> docs) {
  final selfData = docs.where((element) => element.id == deviceId).toList();
  if (selfData.isEmpty) {
    return 0;
  }
  int count = 0;
  for (var i in docs) {
    if (i.id != deviceId &&
        (i.data() as Map).containsKey('latitude') &&
        (i.data() as Map).containsKey('longitude') &&
        (i.data() as Map)['mode'] == 0) {
      final dis = Geolocator.distanceBetween(
          (i.data() as Map)['latitude'],
          (i.data() as Map)['longitude'],
          (selfData[0].data() as Map)['latitude'],
          (selfData[0].data() as Map)['longitude']);
      if (dis < 100) {
        count++;
      }
    }
  }
  return count;
}

Future<void> _requestPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    print('done');
  } else if (status.isDenied) {
    _requestPermission();
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
