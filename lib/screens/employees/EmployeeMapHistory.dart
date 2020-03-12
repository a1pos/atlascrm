import 'dart:async';

import 'package:atlascrm/components/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/CustomAppBar.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:intl/intl.dart';

class EmployeeMapHistory extends StatefulWidget {
  final String employeeId;

  EmployeeMapHistory(this.employeeId);

  @override
  _EmployeeMapHistoryState createState() => _EmployeeMapHistoryState();
}

class _EmployeeMapHistoryState extends State<EmployeeMapHistory> {
  var isLoading = true;
  final ApiService apiService = new ApiService();

  Completer<GoogleMapController> _fullScreenMapController = Completer();

  final Set<Marker> _markers = new Set<Marker>();

  var employeeName = "";

  DateTime _startDate = DateTime.now().toUtc();
  DateTime _endDate = DateTime.now().toUtc();

  CameraPosition _kGooglePlex;

  @override
  void initState() {
    super.initState();

    loadMarkerHistory(null, null);
  }

  Future<void> loadMarkerHistory(DateTime startDate, DateTime endDate) async {
    setState(() {
      isLoading = true;
      _markers.clear();
    });

    var homeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/home.png');

    var url = "/employees/locationdata/" + this.widget.employeeId;

    if (startDate != null && endDate != null) {
      if (startDate.day == endDate.day) {
        startDate = DateTime(startDate.toUtc().year, startDate.toUtc().month,
            startDate.toUtc().day, 0, 0);

        endDate = DateTime(startDate.toUtc().year, startDate.toUtc().month,
            startDate.toUtc().day, 23, 59);
      }

      url += "?startDate=" + startDate.toString();
      url += "&endDate=" + endDate.toString();
    } else {
      startDate =
          DateTime(_startDate.year, _startDate.month, _startDate.day, 0, 0);

      endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59);

      url += "?startDate=" + startDate.toString();
      url += "&endDate=" + endDate.toString();
    }

    var resp = await apiService.authGet(context, url);
    if (resp.statusCode == 200) {
      var locationDataDecoded = resp.data;
      var locationDataArray = List.from(locationDataDecoded);

      if (locationDataArray.length > 0) {
        var markers = List<Marker>();
        var latLngs = List<LatLng>();

        var previousLocation;
        for (var location in locationDataArray) {
          var employeeDocument = location["employee_document"];

          if (employeeName == "") {
            employeeName = employeeDocument["fullName"];
          }

          var latLng = LatLng(
            location["location_document"]["latitude"],
            location["location_document"]["longitude"],
          );

          latLngs.add(latLng);

          if (previousLocation != null) {
            var epoch = location["location_document"]["time"];
            var locationDateTime =
                new DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);

            var previousEpoch = previousLocation["location_document"]["time"];
            var previousLocationDateTime =
                new DateTime.fromMicrosecondsSinceEpoch(previousEpoch * 1000);

            var timeDiff =
                previousLocationDateTime.difference(locationDateTime);

            if (timeDiff > Duration(minutes: 5)) {
              setState(() {
                if (_kGooglePlex == null) {
                  _kGooglePlex = CameraPosition(
                    target: latLng,
                    zoom: 13.0,
                  );
                }
              });

              markers.add(
                Marker(
                  position: latLng,
                  markerId: MarkerId(location["location_id"]),
                  infoWindow: InfoWindow(
                    title: locationDateTime.toString(),
                  ),
                ),
              );
            }
          }

          previousLocation = location;
        }

        setState(() {
          _markers.addAll(markers);

          if (_kGooglePlex == null) {
            _kGooglePlex = CameraPosition(
              target: LatLng(40.907569, -79.923725),
              zoom: 13.0,
            );
          }

          // _polyline.add(
          //   Polyline(
          //     polylineId: PolylineId("polyLineId"),
          //     visible: true,
          //     points: latLngs,
          //     color: Colors.blue,
          //     width: 2,
          //   ),
          // );
        });
      }
    } else {
      var errorBody = resp.data;

      Fluttertoast.showToast(
          msg: errorBody["errorMessage"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() {
      _markers.add(
        Marker(
          position: LatLng(40.907569, -79.923725),
          markerId: MarkerId("home"),
          icon: homeIcon,
          infoWindow: InfoWindow(title: "Home Base"),
        ),
      );

      if (_kGooglePlex == null) {
        _kGooglePlex = CameraPosition(
          target: LatLng(40.907569, -79.923725),
          zoom: 13.0,
        );
      }

      _startDate = startDate;
      _endDate = endDate;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat('yyyy-MM-dd');
    String startDateFmt = formatter.format(_startDate);
    String endDateFmt = formatter.format(_endDate);

    return Scaffold(
      appBar: CustomAppBar(
        key: Key("employeeMapHistoryAppBar"),
        title: Text(
          isLoading ? "Loading..." : "Map History - $employeeName",
        ),
      ),
      body: isLoading
          ? CenteredClearLoadingScreen()
          : Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.grey[200],
                          onPressed: () async {
                            final List<DateTime> picked =
                                await DateRangePicker.showDatePicker(
                                    context: context,
                                    initialFirstDate: DateTime.now(),
                                    initialLastDate: DateTime.now(),
                                    firstDate: DateTime(2015),
                                    lastDate: new DateTime(2040));
                            if (picked != null && picked.length == 2) {
                              await loadMarkerHistory(picked[0], picked[1]);
                            }
                          },
                          child: new Text("Pick date range"),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Start Date: $startDateFmt'),
                            Text('End Date: $endDateFmt'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    mapType: MapType.normal,
                    markers: _markers,
                    // polylines: _polyline,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) async {
                      if (!_fullScreenMapController.isCompleted) {
                        _fullScreenMapController.complete(controller);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
