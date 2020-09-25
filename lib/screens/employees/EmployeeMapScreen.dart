import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/services/api.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image/image.dart' as image;
import 'package:intl/intl.dart';

class EmployeeMapScreen extends StatefulWidget {
  @override
  _EmployeeMapScreenState createState() => _EmployeeMapScreenState();
}

class _EmployeeMapScreenState extends State<EmployeeMapScreen> {
  Completer<GoogleMapController> _fullScreenMapController = Completer();

  final Set<Marker> markers = new Set<Marker>();
  final List<LatLng> markerLatLngs = [];
  bool runOnce = true;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.907569, -79.923725),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    initBaseMap();
  }

  @override
  void dispose() {
    super.dispose();
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  Future initSubListener() async {
    // await initBaseMap();

    Operation options =
        Operation(operationName: "GET_EMPLOYEE_LOCATIONS", documentNode: gql("""
        subscription GET_EMPLOYEE_LOCATIONS {
          employee_device {
            device_id
            employee
            employee_locations(
              limit: 1
              order_by: { created_at: desc_nulls_last }
            ) {
              document
              created_at
            }
            employeeByEmployee {
              document
            }
          }
        }
    """));
    var result = client.subscribe(options);
    result.listen(
      (data) async {
        for (var currentLocation in data.data["employee_device"]) {
          if (currentLocation["employee_locations"].length == 0) {
            return;
          }
          var location = currentLocation["employee_locations"][0];
          var epoch = location["document"]["time"];
          var lastCheckinTime =
              new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

          var dateTime = lastCheckinTime;

          var formatter = DateFormat.yMd().add_jm();
          String datetimeFmt = formatter.format(dateTime.toLocal());

          var markerId = MarkerId(currentLocation["employee"]);
          var currentEmployeeMarker = markers
              .where((marker) => marker.markerId.value == markerId.value);

          var pictureUrl =
              currentLocation["employeeByEmployee"]["document"]["photoURL"];
          var icon = await getMarkerImageFromCache(pictureUrl);

          if (currentEmployeeMarker.length > 0) {
            if (this.mounted) {
              setState(() {
                markers.removeAll(currentEmployeeMarker.toList());

                markers.add(
                  Marker(
                    position: LatLng(
                      location["document"]["latitude"],
                      location["document"]["longitude"],
                    ),
                    markerId: markerId,
                    infoWindow: InfoWindow(
                      snippet: currentLocation["employeeByEmployee"]["document"]
                              ["displayName"] +
                          ", " +
                          datetimeFmt,
                      //  +
                      // " Stops:" +
                      // location["stop_count"],
                      title: currentLocation["employeeByEmployee"]["document"]
                          ["email"],
                    ),
                    icon: icon,
                  ),
                );
                markerLatLngs.add(LatLng(
                  location["document"]["latitude"],
                  location["document"]["longitude"],
                ));
              });
            }
          } else {
            setState(() {
              markers.add(
                Marker(
                  position: LatLng(
                    location["document"]["latitude"],
                    location["document"]["longitude"],
                  ),
                  markerId: markerId,
                  infoWindow: InfoWindow(
                    snippet: currentLocation["employeeByEmployee"]["document"]
                            ["displayName"] +
                        ", " +
                        datetimeFmt,
                    //     +
                    // " Stops:" +
                    // location["stop_count"],
                    title: currentLocation["employeeByEmployee"]["document"]
                        ["email"],
                  ),
                  icon: icon,
                ),
              );
              markerLatLngs.add(LatLng(
                location["document"]["latitude"],
                location["document"]["longitude"],
              ));
            });
          }
          if (runOnce == true) {
            LatLngBounds camBounds = boundsFromLatLngList(markerLatLngs);
            final GoogleMapController controller =
                await _fullScreenMapController.future;
            controller
                .animateCamera(CameraUpdate.newLatLngBounds(camBounds, 100));
          }
        }
      },
      onError: (error) {
        print(error);

        Fluttertoast.showToast(
            msg: "Failed to load Locations!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
    setState(() {
      runOnce = false;
    });
    // var channel = await Pusher.subscribe("location");

    // await channel.bind('new-location', (event) async {
    //   var location = jsonDecode(event.data);
    //   print(location);
    //   var epoch = location["location_document"]["time"];
    //   var lastCheckinTime =
    //       new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

    //   var dateTime = lastCheckinTime;

    //   var formatter = DateFormat.yMd().add_jm();
    //   String datetimeFmt = formatter.format(dateTime.toLocal());

    //   var markerId = MarkerId(location["employee_id"]);
    //   var currentEmployeeMarker =
    //       markers.where((marker) => marker.markerId.value == markerId.value);

    //   var pictureUrl = location["employee_document"]["googleClaims"]["picture"];
    //   var icon = await getMarkerImageFromCache(pictureUrl);

    //   if (currentEmployeeMarker.length > 0) {
    //     setState(() {
    //       markers.removeAll(currentEmployeeMarker.toList());

    //       markers.add(
    //         Marker(
    //           position: LatLng(
    //             location["location_document"]["latitude"],
    //             location["location_document"]["longitude"],
    //           ),
    //           markerId: markerId,
    //           infoWindow: InfoWindow(
    //             snippet: location["employee_document"]["fullName"] +
    //                 " " +
    //                 datetimeFmt +
    //                 " Stops:" +
    //                 location["stop_count"],
    //             title: location["employee_document"]["email"],
    //           ),
    //           icon: icon,
    //         ),
    //       );
    //     });
    //   } else {
    //     setState(() {
    //       markers.add(
    //         Marker(
    //           position: LatLng(
    //             location["location_document"]["latitude"],
    //             location["location_document"]["longitude"],
    //           ),
    //           markerId: markerId,
    //           infoWindow: InfoWindow(
    //             snippet: location["employee_document"]["fullName"] +
    //                 " Stops:" +
    //                 location["stop_count"],
    //             title: location["employee_document"]["email"],
    //           ),
    //           icon: icon,
    //         ),
    //       );
    //     });
    //   }
    // });
  }

  Future<void> initBaseMap() async {
    await initSubListener();

    var homeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/home.png');

    setState(() {
      markers.add(
        Marker(
          position: LatLng(40.907569, -79.923725),
          markerId: MarkerId("home"),
          icon: homeIcon,
          infoWindow: InfoWindow.noText,
        ),
      );
    });

    // DateTime now = DateTime.now();
    // var time = DateTime(now.year, now.month, now.day, 7, now.minute, now.second,
    //     now.millisecond, now.microsecond);
    // var today = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(time);
    // var lastLocationResponse;
    // //REPLACE WITH GRAPHQL
    // // var lastLocationResponse = await this
    // //     .widget
    // //     .apiService
    // //     .authGet(context, "/employee/lastknownlocation");
    // if (lastLocationResponse != null) {
    //   if (lastLocationResponse.statusCode == 200) {
    //     var lastLocationArr = lastLocationResponse.data;
    //     for (var item in lastLocationArr) {
    //       var stopCount;
    //       //REPLACE WITH GRAPHQL
    //       // var stopCount = await this.widget.apiService.authGet(
    //       //     context, "/employee/stopcount/${item["employee"]}/" + today);

    //       var count = await stopCount.data;

    //       var employeeDocument = item["employee_document"];

    //       var isActive = item["is_employee_active"];
    //       if (isActive != null) {
    //         if (!isActive) {
    //           continue;
    //         }
    //       }

    //       var markerId = MarkerId(item["employee"]);

    //       var pictureUrl = employeeDocument["googleClaims"]["picture"];
    //       var icon = await getMarkerImageFromCache(pictureUrl);

    //       var epoch = item["location_document"]["time"];
    //       var lastCheckinTime =
    //           new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

    //       var dateTime = lastCheckinTime;
    //       var formatter = DateFormat.yMd().add_jm();
    //       String datetimeFmt = formatter.format(dateTime.toLocal());

    //       setState(() {
    //         markers.add(
    //           Marker(
    //               position: LatLng(
    //                 item["location_document"]["latitude"],
    //                 item["location_document"]["longitude"],
    //               ),
    //               markerId: markerId,
    //               infoWindow: InfoWindow(
    //                 title: employeeDocument["email"],
    //                 snippet: employeeDocument["fullName"] +
    //                     " " +
    //                     datetimeFmt +
    //                     " Stops:" +
    //                     count.length.toString(),
    //               ),
    //               icon: icon),
    //         );
    //       });
    //     }
    //   }
    // }
  }

  Future<BitmapDescriptor> getMarkerImageFromCache(pictureUrl) async {
    try {
      Uint8List markerImageBytes;

      var markerImageFileInfo =
          await DefaultCacheManager().getFileFromCache(pictureUrl);
      if (markerImageFileInfo == null) {
        var markerImageFile =
            await DefaultCacheManager().getSingleFile(pictureUrl);
        markerImageBytes = await markerImageFile.readAsBytes();

        ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes,
            targetWidth: 100, targetHeight: 100);
        ui.FrameInfo fi = await codec.getNextFrame();
        ByteData byteData =
            await fi.image.toByteData(format: ui.ImageByteFormat.png);

        final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
        return BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
      } else {
        markerImageBytes = await markerImageFileInfo.file.readAsBytes();

        ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes,
            targetWidth: 100, targetHeight: 100);
        ui.FrameInfo fi = await codec.getNextFrame();
        ByteData byteData =
            await fi.image.toByteData(format: ui.ImageByteFormat.png);

        final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
        return BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
      }
    } catch (e) {
      var blah = e;
    }

    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/car.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: Key("employeeMapAppBar"),
        title: Text("Employee Map"),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        cameraTargetBounds: CameraTargetBounds.unbounded,
        markers: markers,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) async {
          if (!_fullScreenMapController.isCompleted) {
            _fullScreenMapController.complete(controller);
          }
        },
      ),
    );
  }
}
