import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

const kGoogleApiKey = "AIzaSyB-rMAdwtIjM7s_4Lb8SdRXAfhbiLTVl7s";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class PlacesSuggestions extends StatefulWidget {
  final String locationValue;
  final Function onPlaceSelect;
  final Map addressSearchObj;

  PlacesSuggestions(
      {this.locationValue, this.onPlaceSelect, this.addressSearchObj});

  @override
  _PlacesSuggestionsState createState() => _PlacesSuggestionsState();
}

bool isLoading = false;
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();
var locationTextController = TextEditingController();

var logger = Logger(
  printer: SimpleLogPrinter(),
  output: CustomOutput(),
);

class _PlacesSuggestionsState extends State<PlacesSuggestions> {
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPlaceById(placeId) async {
    if (placeId != null && placeId != "") {
      PlacesDetailsResponse respo = await _places.getDetailsByPlaceId(placeId);
      PlaceDetails placeDetails = respo.result;
      List placeAddress = placeDetails.addressComponents;

      Future.delayed(Duration(seconds: 1), () {
        logger.i("Place selected on place suggestions: " +
            placeDetails.name.toString());
      });

      Map addressInfo = {
        "address": "",
        "city": "",
        "state": "",
        "zipcode": "",
        "address2": ""
      };
      Map shortAddress = {"address": ""};

      placeAddress.forEach((element) {
        element.types.forEach((type) {
          switch (type) {
            case "street_number":
              addressInfo["address"] = element.shortName;
              shortAddress["address"] = element.shortName;
              break;
            case "route":
              addressInfo["address"] += " " + element.longName;
              shortAddress["address"] += " " + element.shortName;
              break;
            case "subpremise":
              addressInfo["address2"] = element.shortName;
              break;
            case "locality":
              addressInfo["city"] = element.shortName;
              break;
            case "administrative_area_level_1":
              addressInfo["state"] = element.shortName;
              break;
            case "postal_code":
              addressInfo["zipcode"] = element.shortName;
              break;
          }
        });
      });
      if (addressInfo["address2"] != "" && addressInfo["address2"] != null) {
        shortAddress["address"] += " " + addressInfo["address2"];
      }
      Map mixedReply = {
        "address": addressInfo,
        "place": placeDetails,
        "shortaddress": shortAddress
      };

      this.widget.onPlaceSelect(mixedReply);
    } else {
      logger.e("Couldn't find place id");
      Fluttertoast.showToast(
          msg: "Couldn't find place id!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Navigator.of(context).pop();
  }

  Future<void> notListed(addrObj) async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Not listed selected for: " + addrObj.toString());
    });

    this.widget.onPlaceSelect(addrObj);
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    return isLoading
        ? CenteredLoadingSpinner()
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                          child: Text(
                            "Nearby Businesses",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(),
                        Column(
                          children: this
                              .widget
                              .addressSearchObj["nearbyResults"]
                              .map<Widget>((PlacesSearchResult place) {
                            return WillPopScope(
                              onWillPop: () async {
                                return false;
                              },
                              child: GestureDetector(
                                onTap: () {
                                  getPlaceById(place.placeId);
                                  setState(() {
                                    isLoading = true;
                                  });
                                },
                                child: Card(
                                  child: place.types.contains('establishment')
                                      ? ListTile(
                                          title: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                child: Icon(Icons.business),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  place.name,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        GestureDetector(
                          onTap: () {
                            notListed(this.widget.addressSearchObj);
                            setState(() {
                              isLoading = true;
                            });
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(
                                "Not Listed",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
