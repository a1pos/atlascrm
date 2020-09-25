import 'dart:async';

import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/DeviceDropdown.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class EmployeeMapHistoryScreen extends StatefulWidget {
  final Map employee;

  EmployeeMapHistoryScreen(this.employee);

  @override
  _EmployeeMapHistoryScreenState createState() =>
      _EmployeeMapHistoryScreenState();
}

class _EmployeeMapHistoryScreenState extends State<EmployeeMapHistoryScreen> {
  var isLoading = true;

  Completer<GoogleMapController> _fullScreenMapController = Completer();

  final Set<Marker> _markers = new Set<Marker>();
  final Set<Polyline> _polyline = new Set<Polyline>();

  var employeeName = "";

  DateTime _startDate = DateTime.now().toUtc();
  DateTime _endDate = DateTime.now().toUtc();
  var numberStops = 0;
  var currentDate = DateTime.now();
  CameraPosition _kGooglePlex;
  TextEditingController deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
      if (_kGooglePlex == null) {
        _kGooglePlex = CameraPosition(
          target: LatLng(40.907569, -79.923725),
          zoom: 13.0,
        );
      }
    });
    // loadMarkerHistory(null);
  }

  Future<void> loadMarkerHistory(DateTime startDate) async {
    var endDate;
    setState(() {
      isLoading = true;
      _markers.clear();
      _polyline.clear();
    });

    var homeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/home.png');

    if (startDate != null) {
      startDate = DateTime(startDate.toUtc().year, startDate.toUtc().month,
          startDate.toUtc().day, 7, 0);

      endDate = DateTime(startDate.toUtc().year, startDate.toUtc().month,
          startDate.toUtc().day, 23, 59);
    } else {
      startDate =
          DateTime(_startDate.year, _startDate.month, _startDate.day, 7, 0);
      endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59);
    }

    QueryOptions options = QueryOptions(
        documentNode: gql("""
          query GET_EMPLOYEE_ROUTE(
            \$device_id: String
            \$date: timestamptz
            \$next_day: timestamptz
          ) {
            v_employee_route(
              where: {
                _and: [
                  { created_at: { _gt: \$date } }
                  { created_at: { _lt: \$next_day } }
                  { device_id: { _eq: \$device_id } }
                ]
              }
              order_by: { created_at: asc }
            ) {
              delta
              created_at
              device_id
              employee
              employee_document
              location_document
            }
          }
      """),
        variables: {
          "device_id": deviceIdController.text,
          "date": startDate.toString(),
          "next_day": endDate.toString()
        },
        fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult result = await client.query(options);
    if (result != null) {
      if (result.hasException == false) {
        var locationDataDecoded = result.data["v_employee_route"];
        var locationDataArray = List.from(locationDataDecoded);

        QueryOptions options = QueryOptions(documentNode: gql("""
          query GET_STOP_COUNT(
            \$device_id: String
            \$date: timestamptz
            \$next_day: timestamptz
          ) {
            v_stop_count(
              where: {
                _and: [
                  { created_at: { _gt: \$date } }
                  { created_at: { _lt: \$next_day } }
                  { device_id: { _eq: \$device_id } }
                ]
              }
            ) {
              location_document
              employee_location
              employee_document
              employee
              device_id
              delta
              created_at
            }
          }
      """), variables: {
          "device_id": deviceIdController.text,
          "date": startDate.toString(),
          "next_day": endDate.toString()
        });

        final QueryResult countResult = await client.query(options);
        if (countResult != null) {
          if (countResult.hasException == false) {}
        }

        var count = await countResult.data["v_stop_count"];
        setState(() {
          numberStops = count.length;
        });

        if (locationDataArray.length > 0) {
          var markers = List<Marker>();
          var latLngs = List<LatLng>();

          var previousLocation;
          for (var location in locationDataArray) {
            var employeeDocument = location["employee_document"];

            if (employeeName == "") {
              employeeName = employeeDocument["displayName"];
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

              if (timeDiff < Duration(minutes: -3)) {
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
                    markerId: MarkerId(UniqueKey().toString()),
                    // markerId: MarkerId(location["location_id"]),
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
            _polyline.add(
              Polyline(
                polylineId: PolylineId("polyLineId"),
                visible: true,
                points: latLngs,
                color: Colors.blue,
                width: 2,
              ),
            );
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: result.exception.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
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
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat.yMMMMd('en_US');
    String startDateFmt = formatter.format(_startDate);

    return Scaffold(
      appBar: CustomAppBar(
        key: Key("employeeMapHistoryAppBar"),
        title: Text(
          isLoading
              ? "Loading..."
              : "Map History - ${this.widget.employee["document"]["displayName"]}",
        ),
      ),
      body: isLoading
          ? CenteredClearLoadingScreen()
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: DeviceDropDown(
                      value: deviceIdController.text,
                      employee: this.widget.employee["employee"],
                      callback: (newValue) {
                        setState(() {
                          deviceIdController.text = newValue;
                          loadMarkerHistory(currentDate);
                        });
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.grey[200],
                          onPressed: deviceIdController.text != ""
                              ? () async {
                                  final DateTime picked = await showDatePicker(
                                      context: context,
                                      initialDate: currentDate,
                                      firstDate: DateTime(2015),
                                      lastDate: new DateTime(2040));
                                  if (picked != null) {
                                    currentDate = picked;
                                    await loadMarkerHistory(picked);
                                  }
                                }
                              : () {},
                          child: new Text(startDateFmt),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Text('Date: $startDateFmt'),
                            Text('Number of Stops: ${numberStops.toString()}'),
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
                    polylines: _polyline,
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
