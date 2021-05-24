import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/DeviceDropdown.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final Set<Marker> _markers = new Set<Marker>();
  final Set<Polyline> _polyline = new Set<Polyline>();
  final List<LatLng> markerLatLngs = [];
  LatLngBounds _latLngBounds;

  bool isLoading = true;

  Completer<GoogleMapController> _fullScreenMapController2 = Completer();
  DateTime _startDate = DateTime.now().toUtc();
  DateTime _endDate = DateTime.now().toUtc();
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.907569, -79.923725),
    zoom: 13,
  );
  GoogleMapController _mapController;

  TextEditingController deviceIdController = TextEditingController();

  var employeeName = "";
  var numberStops = 0;
  var currentDate = DateTime.now();
  var north;
  var east;
  var south;
  var west;

  @override
  void initState() {
    super.initState();
    setState(
      () {
        isLoading = false;
      },
    );
  }

  Future<void> loadMarkerHistory(DateTime startDate) async {
    var endDate;
    setState(
      () {
        isLoading = true;
        _markers.clear();
        _polyline.clear();
      },
    );

    var homeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(5, 5)), 'assets/home.png');

    if (startDate != null) {
      startDate = DateTime(startDate.toUtc().year, startDate.toUtc().month,
          startDate.toUtc().day, 11, 0);

      endDate = DateTime(startDate.toUtc().year, startDate.toUtc().month,
          startDate.toUtc().day, 23, 0);
    } else {
      startDate =
          DateTime(_startDate.year, _startDate.month, _startDate.day, 11, 0);
      endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 0);
    }

    QueryOptions options = QueryOptions(
      document: gql("""
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
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);
    if (result != null) {
      if (result.hasException == false) {
        var locationDataDecoded = result.data["v_employee_route"];
        var locationDataArray = List.from(locationDataDecoded);
        List<Marker> markers = [];
        List<LatLng> latLngs = [];

        if (locationDataArray.length > 0) {
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
          }

          setState(() {
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

        QueryOptions options = QueryOptions(
          document: gql("""
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
      """),
          variables: {
            "device_id": deviceIdController.text,
            "date": startDate.toString(),
            "next_day": endDate.toString()
          },
        );

        final QueryResult countResult =
            await GqlClientFactory().authGqlquery(options);
        if (countResult != null) {
          if (countResult.hasException == false) {
            var count = await countResult.data["v_stop_count"];
            for (var i = 0; i < count.length; i++) {
              var stop = count[i];
              var today = DateTime.now();
              var localStop = DateTime.parse(stop["created_at"]).toLocal();
              var stopTime = DateFormat.yMd().add_jm().format(localStop);

              if (i == count.length - 1 &&
                  localStop.day == today.day &&
                  localStop.month == today.month &&
                  localStop.year == today.year) {
                var pictureUrl = stop["employee_document"]["photoURL"];
                var icon = await getMarkerImageFromCache(pictureUrl);
                markers.add(
                  Marker(
                    icon: icon,
                    position: LatLng(stop["location_document"]["latitude"],
                        stop["location_document"]["longitude"]),
                    markerId: MarkerId(UniqueKey().toString()),
                    infoWindow: InfoWindow(
                      title: stopTime,
                      snippet: "Duration: " + stop["delta"],
                    ),
                  ),
                );
              } else {
                markers.add(
                  Marker(
                    position: LatLng(
                      stop["location_document"]["latitude"],
                      stop["location_document"]["longitude"],
                    ),
                    markerId: MarkerId(
                      UniqueKey().toString(),
                    ),
                    infoWindow: InfoWindow(
                      title: stopTime,
                      snippet: "Duration: " + stop["delta"],
                    ),
                  ),
                );
              }
              var markerLatLng = LatLng(
                stop["location_document"]["latitude"],
                stop["location_document"]["longitude"],
              );
              markerLatLngs.add(markerLatLng);
            }

            if (latLngs != null && latLngs.length > 0) {
              markerLatLngs.sort((b, a) => a.latitude.compareTo(b.latitude));
              north = markerLatLngs[0];

              markerLatLngs.sort((a, b) => a.latitude.compareTo(b.latitude));
              south = markerLatLngs[0];

              markerLatLngs.sort((a, b) => b.longitude.compareTo(a.longitude));
              east = markerLatLngs[0];

              markerLatLngs.sort((b, a) => b.longitude.compareTo(a.longitude));
              west = markerLatLngs[0];
            }
            setState(
              () {
                numberStops = count.length;
                _markers.addAll(markers);

                if (numberStops > 0) {
                  _latLngBounds = LatLngBounds(
                    southwest: LatLng(south.latitude, west.longitude),
                    northeast: LatLng(north.latitude, east.longitude),
                  );

                  loadMap();
                }
              },
            );
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: result.exception.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
    // _markers.add(
    //   Marker(
    //     position: LatLng(40.907569, -79.923725),
    //     markerId: MarkerId("home"),
    //     icon: homeIcon,
    //     infoWindow: InfoWindow(title: "Home Base"),
    //   ),
    // );
    setState(
      () {
        _startDate = startDate;
        _endDate = endDate;
        isLoading = false;
      },
    );
  }

  Widget loadMap() {
    return GoogleMap(
      key: Key("historyMap"),
      myLocationEnabled: true,
      mapType: MapType.normal,
      markers: _markers,
      polylines: _polyline,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) async {
        _mapController = controller;
        if (!_fullScreenMapController2.isCompleted) {
          _fullScreenMapController2.complete(controller);
        }

        if (_latLngBounds != null) {
          Future.delayed(
            Duration(milliseconds: 200),
            () => _mapController.animateCamera(CameraUpdate.newLatLngBounds(
              _latLngBounds,
              70,
            )),
          );
        }
      },
    );
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
                    callback: (newValue) async {
                      setState(
                        () {
                          deviceIdController.text = newValue;
                        },
                      );
                      await loadMarkerHistory(currentDate);
                    },
                  ),
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
                            Text('Number of Stops: ${numberStops.toString()}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: isLoading ? Container() : loadMap(),
                ),
              ],
            ),
    );
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
