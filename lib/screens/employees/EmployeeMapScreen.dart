import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class EmployeeMapScreen extends StatefulWidget {
  @override
  _EmployeeMapScreenState createState() => _EmployeeMapScreenState();
}

class _EmployeeMapScreenState extends State<EmployeeMapScreen> {
  final Set<Marker> markers = new Set<Marker>();
  final List<LatLng> markerLatLngs = [];
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.907569, -79.923725),
    zoom: 13.0,
  );

  bool runOnce = true;
  Completer<GoogleMapController> _fullScreenMapController = Completer();

  var subscription;
  var today =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " 11:00";
  var todayEnd =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " 23:00";

  @override
  void initState() {
    super.initState();
    initBaseMap();
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
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
    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  Future initSubListener() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "GET_EMPLOYEE_LOCATIONS",
      document: gql("""
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
    """),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) async {
        for (var currentLocation in data.data["employee_device"]) {
          var stopCount;
          if (currentLocation["employee_locations"].length != 0) {
            QueryOptions options = QueryOptions(
              document: gql("""
          query GET_STOP_COUNT(\$device_id: String, \$date: timestamptz) {
                      v_stop_count_aggregate(
                        where: {
                          _and: [
                            { device_id: { _eq: \$device_id } }
                            { created_at: { _gte: \$date } }
                          ]
                        }
                      ) {
                        aggregate {
                          count
                        }
                      }
                    }
              """),
              variables: {
                "device_id": currentLocation["device_id"],
                "date": today
              },
            );

            final QueryResult result2 =
                await GqlClientFactory().authGqlquery(options);
            if (result2 != null) {
              if (result2.hasException == false) {
                var stopsArrDecoded = result2.data["v_stop_count_aggregate"]
                    ["aggregate"]["count"];
                if (stopsArrDecoded != null) {
                  stopCount = stopsArrDecoded.toString();
                }
              }
            }

            var location = currentLocation["employee_locations"][0];
            var epoch = location["document"]["time"];
            var lastCheckinTime =
                new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

            var dateTime = lastCheckinTime;

            var formatter = DateFormat.yMd().add_jm();
            String datetimeFmt = formatter.format(
              dateTime.toLocal(),
            );

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
                        snippet: currentLocation["employeeByEmployee"]
                                ["document"]["displayName"] +
                            ", " +
                            datetimeFmt +
                            " Stops:" +
                            stopCount,
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
              setState(
                () {
                  markers.add(
                    Marker(
                      position: LatLng(
                        location["document"]["latitude"],
                        location["document"]["longitude"],
                      ),
                      markerId: markerId,
                      infoWindow: InfoWindow(
                        snippet: currentLocation["employeeByEmployee"]
                                ["document"]["displayName"] +
                            ", " +
                            datetimeFmt +
                            " Stops:" +
                            stopCount,
                        title: currentLocation["employeeByEmployee"]["document"]
                            ["email"],
                      ),
                      icon: icon,
                    ),
                  );
                  markerLatLngs.add(
                    LatLng(
                      location["document"]["latitude"],
                      location["document"]["longitude"],
                    ),
                  );
                },
              );
            }
          }
        }
      },
      (error) {},
      () => refreshSub(),
    );

    // subscription = result.listen(
    //   (data) async {
    //     for (var currentLocation in data.data["employee_device"]) {
    //       var stopCount;
    //       if (currentLocation["employee_locations"].length != 0) {
    //         QueryOptions options = QueryOptions(document: gql("""
    //       query GET_STOP_COUNT(\$device_id: String, \$date: timestamptz) {
    //                   v_stop_count_aggregate(
    //                     where: {
    //                       _and: [
    //                         { device_id: { _eq: \$device_id } }
    //                         { created_at: { _gte: \$date } }
    //                       ]
    //                     }
    //                   ) {
    //                     aggregate {
    //                       count
    //                     }
    //                   }
    //                 }
    //           """), fetchPolicy: FetchPolicy.networkOnly, variables: {
    //           "device_id": currentLocation["device_id"],
    //           "date": today
    //         });

    //         final QueryResult result2 =
    //             await GqlClientFactory().authGqlquery(options);
    //         if (result2 != null) {
    //           if (result2.hasException == false) {
    //             var stopsArrDecoded = result2.data["v_stop_count_aggregate"]
    //                 ["aggregate"]["count"];
    //             if (stopsArrDecoded != null) {
    //               stopCount = stopsArrDecoded.toString();
    //             }
    //           }
    //         }

    //         var location = currentLocation["employee_locations"][0];
    //         var epoch = location["document"]["time"];
    //         var lastCheckinTime =
    //             new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

    //         var dateTime = lastCheckinTime;

    //         var formatter = DateFormat.yMd().add_jm();
    //         String datetimeFmt = formatter.format(dateTime.toLocal());

    //         var markerId = MarkerId(currentLocation["employee"]);
    //         var currentEmployeeMarker = markers
    //             .where((marker) => marker.markerId.value == markerId.value);

    //         var pictureUrl =
    //             currentLocation["employeeByEmployee"]["document"]["photoURL"];
    //         var icon = await getMarkerImageFromCache(pictureUrl);

    //         if (currentEmployeeMarker.length > 0) {
    //           if (this.mounted) {
    //             setState(() {
    //               markers.removeAll(currentEmployeeMarker.toList());

    //               markers.add(
    //                 Marker(
    //                   position: LatLng(
    //                     location["document"]["latitude"],
    //                     location["document"]["longitude"],
    //                   ),
    //                   markerId: markerId,
    //                   infoWindow: InfoWindow(
    //                     snippet: currentLocation["employeeByEmployee"]
    //                             ["document"]["displayName"] +
    //                         ", " +
    //                         datetimeFmt +
    //                         " Stops:" +
    //                         stopCount,
    //                     title: currentLocation["employeeByEmployee"]["document"]
    //                         ["email"],
    //                   ),
    //                   icon: icon,
    //                 ),
    //               );
    //               markerLatLngs.add(LatLng(
    //                 location["document"]["latitude"],
    //                 location["document"]["longitude"],
    //               ));
    //             });
    //           }
    //         } else {
    //           setState(() {
    //             markers.add(
    //               Marker(
    //                 position: LatLng(
    //                   location["document"]["latitude"],
    //                   location["document"]["longitude"],
    //                 ),
    //                 markerId: markerId,
    //                 infoWindow: InfoWindow(
    //                   snippet: currentLocation["employeeByEmployee"]["document"]
    //                           ["displayName"] +
    //                       ", " +
    //                       datetimeFmt +
    //                       " Stops:" +
    //                       stopCount,
    //                   title: currentLocation["employeeByEmployee"]["document"]
    //                       ["email"],
    //                 ),
    //                 icon: icon,
    //               ),
    //             );
    //             markerLatLngs.add(LatLng(
    //               location["document"]["latitude"],
    //               location["document"]["longitude"],
    //             ));
    //           });
    //         }
    //         // if (runOnce == true) {
    //         //   LatLngBounds camBounds = boundsFromLatLngList(markerLatLngs);
    //         //   final GoogleMapController controller =
    //         //       await _fullScreenMapController.future;
    //         //   controller
    //         //       .animateCamera(CameraUpdate.newLatLngBounds(camBounds, 100));
    //         // }
    //       }
    //     }
    //   },
    //   onError: (error) async {
    //     var errMsg = error.payload["message"];
    //     print(errMsg);
    //     if (errMsg.contains("JWTExpired")) {
    //       await refreshSub();
    //     } else {
    //       Fluttertoast.showToast(
    //           msg: errMsg,
    //           toastLength: Toast.LENGTH_LONG,
    //           gravity: ToastGravity.BOTTOM,
    //           backgroundColor: Colors.grey[600],
    //           textColor: Colors.white,
    //           fontSize: 16.0);
    //     }
    //   },
    // );
    // an attempt was made at auto-zooming to include all employees in initial view
    // Future.delayed(const Duration(milliseconds: 3000), () async {
    //   if (runOnce == true) {
    //     LatLngBounds camBounds = boundsFromLatLngList(markerLatLngs);
    //     final GoogleMapController controller =
    //         await _fullScreenMapController.future;
    //     controller.animateCamera(CameraUpdate.newLatLngBounds(camBounds, 100));
    //   }
    //   setState(() {
    //     runOnce = false;
    //   });
    // });
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initSubListener();
    }
  }

  Future<void> initBaseMap() async {
    await initSubListener();

    var homeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/home.png');

    setState(
      () {
        markers.add(
          Marker(
            position: LatLng(40.907569, -79.923725),
            markerId: MarkerId("home"),
            icon: homeIcon,
            infoWindow: InfoWindow.noText,
          ),
        );
      },
    );
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
      print(e);
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
        key: Key("liveMap"),
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
