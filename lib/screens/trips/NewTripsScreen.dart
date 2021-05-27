import 'dart:async';
import 'dart:ui' as ui;
import 'package:atlascrm/components/install/InstallScheduleForm.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/MerchantDropdown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripsScreen extends StatefulWidget {
  final StorageService storageService = new StorageService();

  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final Set<Marker> _markers = new Set<Marker>();
  final Set<Polyline> _polyline = new Set<Polyline>();
  final List<LatLng> markerLatLngs = [];
  final _formKey = GlobalKey<FormState>();
  static LatLng initialPos = LatLng(40.907569, -79.923725);
  LatLngBounds _latLngBounds;

  int maxStops = 10;

  bool showMap = false;
  bool isVisible = false;
  bool customStart;
  bool unscheduled;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(initialPos.latitude, initialPos.longitude),
    zoom: 10,
  );

  BitmapDescriptor icon;

  GoogleMapController _mapController;
  Completer<GoogleMapController> _fullScreenMapController = Completer();

  List installs = [];
  List selectedInstalls = [];

  var employee = UserService.employee.employee;
  var currentDate = DateTime.now();
  var tripDateController = TextEditingController();
  var homeIcon;
  var locationValue;
  var startAddress;
  var north;
  var east;
  var south;
  var west;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();

    installs = [];
  }

  Widget loadMap() {
    return GoogleMap(
      key: Key("tripMap"),
      myLocationEnabled: true,
      mapType: MapType.normal,
      markers: _markers,
      initialCameraPosition: _kGooglePlex,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      zoomControlsEnabled: true,
      // onLongPress: ,
      onMapCreated: (GoogleMapController controller) async {
        _mapController = controller;
        if (!_fullScreenMapController.isCompleted) {
          _fullScreenMapController.complete(_mapController);
          getInstallMarkers();
        }
      },
    );
  }

  Widget initTripDialog() {
    return AlertDialog(
      title: Text("Select Date and Starting Location"),
      actions: [
        TextButton(
          child: Text(
            "Go",
            style: TextStyle(
              color: UniversalStyles.actionColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onPressed: () {
            if (customStart == null || tripDateController.text == "") {
              var msg;
              msg = "Please select both a start location and trip date";
              Fluttertoast.showToast(
                msg: msg,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else if (customStart == true &&
                (locationValue == null || locationValue == "")) {
              var msg = "Please add a custom address";
              Fluttertoast.showToast(
                msg: msg,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              if (customStart == true) {
                startAddress = locationValue;
                //add start address to list
              } else {
                startAddress = initialPos;
                // add startAddress to List
              }
              setState(() {
                showMap = true;
              });
            }
          },
        )
      ],
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DateTimeField(
                  decoration: InputDecoration(labelText: "Trip Date"),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  validator: (DateTime dateTime) {
                    if (dateTime == null) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  format: DateFormat("MM/dd/yyyy"),
                  controller: tripDateController,
                  initialValue: DateTime.now(),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    return date;
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 7.5),
                  child: Text(
                    "Start From:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: customStart == false || customStart == null
                          ? 1.0
                          : 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: UniversalStyles.actionColor,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              color: Colors.white,
                            ),
                            Text(
                              "Office",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            customStart = false;
                            isVisible = false;
                          });
                        },
                      ),
                    ),
                    Opacity(
                      opacity: customStart == true || customStart == null
                          ? 1.0
                          : 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: UniversalStyles.actionColor,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_location_alt,
                              color: Colors.white,
                            ),
                            Text(
                              "Custom Address",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            customStart = true;
                            isVisible = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Visibility(
                      visible: isVisible,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                        child: AddressSearch(
                          returnNearby: true,
                          locationValue: locationValue,
                          tripSearch: true,
                          onAddressChange: (val) {
                            locationValue = val.toString();
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Future getInstallMarkers() async {
    QueryOptions options = QueryOptions(
      operationName: "GET_V_INSTALL_TABLE",
      document: gql("""
      query GET_V_INSTALL_TABLE {
      v_install_table(
        where: {
          _or: [{ ticket_open: { _eq: true } }, { ticket: { _is_null: true } }]
        }
      ) {
        install
        merchant
        merchantbusinessname
        date
        ticket
        employee
        employeefullname
        install_address
        lead
        lat
        lng
      }
    }
    """),
    );

    final result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var installsArrDecoded = result.data["v_install_table"];
        var installsArr = List.from(installsArrDecoded);
        List<Marker> markers = [];

        homeIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(5, 5)),
          'assets/homeSmall.png',
        );

        if (installsArr.length > 0) {
          for (var install in installsArr) {
            var installDate = install["date"] == null
                ? "TBD"
                : DateTime.parse(install["date"]).toLocal();
            var installTime = installDate == "TBD"
                ? ""
                : DateFormat.yMd().add_jm().format(installDate);
            var viewDate = install["date"] == null
                ? null
                : DateFormat("yyyy-MM-dd HH:mm")
                    .format(DateTime.parse(install["date"]).toLocal());

            var employee = install["employee"];

            icon = install["date"] == null || install["employee"] == null
                ? await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(size: Size(2.5, 2.5)),
                    'assets/scheduleInstall.png',
                  )
                : await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(size: Size(2.5, 2.5)),
                    'assets/install.png',
                  );

            markers.add(
              Marker(
                icon: icon,
                markerId: MarkerId(UniqueKey().toString()),
                position: LatLng(
                  double.parse(install["lat"]),
                  double.parse(install["lng"]),
                ),
                infoWindow: InfoWindow(
                  title: install["merchantbusinessname"],
                  snippet: installTime == "" ? "TBD" : installTime,
                ),
                onTap: () {
                  if (installTime == "" || employee == null) {
                    if (install['date'] != null) {
                      unscheduled = false;
                      viewDate = DateFormat("yyyy-MM-dd HH:mm")
                          .format(DateTime.parse(install['date']).toLocal());
                    } else {
                      unscheduled = true;
                      viewDate = "";
                    }

                    openInstallForm(install, viewDate, unscheduled);
                  } else {
                    if (!selectedInstalls.contains(install)) {
                      selectedInstalls.add(install);
                      Fluttertoast.showToast(
                        msg: install['merchantbusinessname'] +
                            " added to trip list",
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "This merchant is already on the trip list",
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  }
                },
              ),
            );

            var markerLatLng = LatLng(
              double.parse(install["lat"]),
              double.parse(install["lng"]),
            );

            markerLatLngs.add(markerLatLng);
          }

          markerLatLngs.sort((b, a) => a.latitude.compareTo(b.latitude));
          north = markerLatLngs[0];

          markerLatLngs.sort((a, b) => a.latitude.compareTo(b.latitude));
          south = markerLatLngs[0];

          markerLatLngs.sort((a, b) => b.longitude.compareTo(a.longitude));
          east = markerLatLngs[0];

          markerLatLngs.sort((b, a) => b.longitude.compareTo(a.longitude));
          west = markerLatLngs[0];

          setState(
            () {
              _markers.addAll(markers);

              _markers.add(
                Marker(
                  position: LatLng(40.907569, -79.923725),
                  markerId: MarkerId("home"),
                  icon: homeIcon,
                  infoWindow: InfoWindow.noText,
                ),
              );

              _latLngBounds = LatLngBounds(
                southwest: LatLng(
                  south.latitude,
                  west.longitude,
                ),
                northeast: LatLng(
                  north.latitude,
                  east.longitude,
                ),
              );

              _mapController.animateCamera(
                CameraUpdate.newLatLngBounds(_latLngBounds, 35),
              );
            },
          );
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
  }

  void openInstallForm(i, viewDate, unscheduled) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InstallScheduleForm(
            i,
            viewDate,
            unscheduled: unscheduled,
          );
        });
  }

  Widget buildTripList() {
    return Expanded(
      child: Container(
        height: 400,
        child: selectedInstalls.length > 0
            ? ReorderableListView(
                children: List.generate(
                  selectedInstalls.length,
                  (index) {
                    var install = selectedInstalls[index];
                    var merchantName = install["merchantbusinessname"];
                    var listIndex = index + 1;

                    return Container(
                      key: Key('$index'),
                      child: Card(
                        key: Key('$index'),
                        elevation: 3,
                        shape: new RoundedRectangleBorder(
                          side: new BorderSide(
                            color: Colors.black26,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Column(
                          key: Key('$index'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              key: Key('$index'),
                              padding: EdgeInsets.fromLTRB(5, 0, 2.5, 0),
                              child: ListTile(
                                key: Key('$index'),
                                contentPadding: EdgeInsets.only(top: 1),
                                leading: Text(listIndex.toString() + ". "),
                                title: Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: Text(
                                    merchantName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = selectedInstalls.removeAt(oldIndex);
                    selectedInstalls.insert(newIndex, item);
                  });
                },
              )
            : Empty("Add installs to calculate your trip"),
      ),
    );
  }

  // ? ListView(
  //     shrinkWrap: true,
  //     children: List.generate(
  //       selectedInstalls.length,
  //       (index) {
  //         var install = selectedInstalls[index];
  //         var merchantName = install["merchantbusinessname"];
  //         var listIndex = index + 1;

  // return Container(
  //   child: Card(
  //     elevation: 3,
  //     shape: new RoundedRectangleBorder(
  //       side: new BorderSide(
  //         color: Colors.black26,
  //         width: 0.5,
  //       ),
  //       borderRadius: BorderRadius.circular(4.0),
  //     ),
  //   child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.fromLTRB(5, 0, 2.5, 0),
  //                 child: ListTile(
  //                   contentPadding: EdgeInsets.only(top: 1),
  //                   leading: Text(listIndex.toString() + ". "),
  //                   title: Padding(
  //                     padding: EdgeInsets.only(right: 0),
  //                     child: Text(
  //                       merchantName,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   ),
  // )

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("tripCustomAppBar"),
        title: Text("Trips"),
      ),
      body: !showMap ? initTripDialog() : loadMap(),
      floatingActionButton: !showMap
          ? Container()
          : FloatingActionButton.extended(
              elevation: 5,
              label: const Text('Review Trip'),
              icon: const Icon(Icons.keyboard_arrow_up),
              onPressed: () {
                showModalBottomSheet(
                    enableDrag: true,
                    elevation: 10,
                    barrierColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Trip Review",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey[750],
                                            size: 30.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  buildTripList(),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    });
                // show container hidden with trip list
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
