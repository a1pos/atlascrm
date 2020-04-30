import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:atlascrm/components/shared/CustomAppBar.dart';

import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/SocketService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pusher/pusher.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class EmployeeMapScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();
  final SocketService socketService = new SocketService();

  @override
  _EmployeeMapScreenState createState() => _EmployeeMapScreenState();
}

class _EmployeeMapScreenState extends State<EmployeeMapScreen> {
  Completer<GoogleMapController> _fullScreenMapController = Completer();

  final Set<Marker> markers = new Set<Marker>();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.907569, -79.923725),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();

    initSocketListener();
  }

  @override
  void dispose() {
    super.dispose();

    // if (SocketService.SOCKET != null) {
    //   if (SocketService.SOCKET.hasListeners("newLocation")) {
    //     SocketService.SOCKET.off("newLocation");
    //   }
    // }
  }

  void initSocketListener() async {
    await initBaseMap();

    var channel = await Pusher.subscribe("location");

    await channel.bind('new-location', (event) async {
      var location = jsonDecode(event.data);
      print(location);
      var epoch = location["location_document"]["time"];
      var lastCheckinTime =
          new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

      var dateTime = lastCheckinTime;

      var formatter = DateFormat.yMd().add_jm();
      String datetimeFmt = formatter.format(dateTime.toLocal());

      var markerId = MarkerId(location["employee_id"]);
      var currentEmployeeMarker =
          markers.where((marker) => marker.markerId.value == markerId.value);

      var pictureUrl = location["employee_document"]["googleClaims"]["picture"];
      var icon = await getMarkerImageFromCache(pictureUrl);

      if (currentEmployeeMarker.length > 0) {
        setState(() {
          markers.removeAll(currentEmployeeMarker.toList());

          markers.add(
            Marker(
              position: LatLng(
                location["location_document"]["latitude"],
                location["location_document"]["longitude"],
              ),
              markerId: markerId,
              infoWindow: InfoWindow(
                snippet: location["employee_document"]["fullName"] +
                    " " +
                    datetimeFmt,
                title: location["employee_document"]["email"],
              ),
              icon: icon,
            ),
          );
        });
      } else {
        setState(() {
          markers.add(
            Marker(
              position: LatLng(
                location["location_document"]["latitude"],
                location["location_document"]["longitude"],
              ),
              markerId: markerId,
              infoWindow: InfoWindow(
                snippet: location["employee_document"]["fullName"],
                title: location["employee_document"]["email"],
              ),
              icon: icon,
            ),
          );
        });
      }
    });
  }

  Future<void> initBaseMap() async {
    var homeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/home.png');

    setState(() {
      markers.add(
        Marker(
          position: LatLng(40.907569, -79.923725),
          markerId: MarkerId("home"),
          icon: homeIcon,
          infoWindow: InfoWindow(title: "Home Base"),
        ),
      );
    });

    var lastLocationResponse = await this
        .widget
        .apiService
        .authGet(context, "/employee/lastknownlocation");
    if (lastLocationResponse != null) {
      if (lastLocationResponse.statusCode == 200) {
        var lastLocationArr = lastLocationResponse.data;
        for (var item in lastLocationArr) {
          var employeeDocument = item["employee_document"];

          var isActive = item["is_employee_active"];
          if (isActive != null) {
            if (!isActive) {
              continue;
            }
          }

          var markerId = MarkerId(item["employee"]);

          var pictureUrl = employeeDocument["googleClaims"]["picture"];
          var icon = await getMarkerImageFromCache(pictureUrl);

          var epoch = item["location_document"]["time"];
          var lastCheckinTime =
              new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

          var dateTime = lastCheckinTime;
          var formatter = DateFormat.yMd().add_jm();
          String datetimeFmt = formatter.format(dateTime.toLocal());

          setState(() {
            markers.add(
              Marker(
                  position: LatLng(
                    item["location_document"]["latitude"],
                    item["location_document"]["longitude"],
                  ),
                  markerId: markerId,
                  infoWindow: InfoWindow(
                    title: employeeDocument["email"],
                    snippet: employeeDocument["fullName"] + " " + datetimeFmt,
                  ),
                  icon: icon),
            );
          });
        }
      }
    }
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
      } else {
        markerImageBytes = await markerImageFileInfo.file.readAsBytes();
      }

      return BitmapDescriptor.fromBytes(markerImageBytes);
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
