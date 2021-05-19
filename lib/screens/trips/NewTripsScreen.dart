import 'dart:developer';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/Notes.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/MerchantDropdown.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
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

  bool isLoading = true;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.907569, -79.923725),
    zoom: 9,
  );

  Completer<GoogleMapController> _fullScreenMapController = Completer();

  List installs = [];
  List activeInstalls = [];
  List unscheduledInstallsList = [];

  var employee = UserService.employee.employee;
  var currentDate = DateTime.now();
  var tripDateController = TextEditingController();
  var homeIcon;

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
      onMapCreated: (GoogleMapController controller) async {
        if (!_fullScreenMapController.isCompleted) {
          _fullScreenMapController.complete(controller);
          getInstallMarkers();
        }
      },
    );
  }

  Widget initTripDialog() {
    return AlertDialog(
      title: Text("Select Date and Starting Location"),
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
                    "Start from:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
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
                            isLoading = false;
                          });
                        },
                      ),
                      ElevatedButton(
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
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
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
            var installDate = DateTime.parse(install["date"]).toLocal();
            var installTime = DateFormat.yMd().add_jm().format(installDate);

            markers.add(
              Marker(
                markerId: MarkerId(UniqueKey().toString()),
                position: LatLng(
                  double.parse(install["lat"]),
                  double.parse(install["lng"]),
                ),
                infoWindow: InfoWindow(
                  title: install["merchantbusinessname"],
                  snippet: installTime,
                ),
              ),
            );

            var markerLatLng = LatLng(
                double.parse(install["lat"]), double.parse(install["lng"]));

            markerLatLngs.add(markerLatLng);
          }
          setState(
            () {
              isLoading = false;
              _markers.addAll(markers);

              _markers.add(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("tripCustomAppBar"),
        title: Text("Trips"),
      ),
      body: isLoading ? initTripDialog() : loadMap(),
    );
  }
}
