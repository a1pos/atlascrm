import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';

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

var locationTextController = TextEditingController();
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();
bool isLoading = false;

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
      if (addressInfo["address2"] != "") {
        addressInfo["address"] += " #" + addressInfo["address2"];
        shortAddress["address"] += " #" + addressInfo["address2"];
      }
      Map mixedReply = {
        "address": addressInfo,
        "place": placeDetails,
        "shortaddress": shortAddress
      };

      this.widget.onPlaceSelect(mixedReply);
    } else {
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
                          child: Text("Nearby Businesses",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Divider(),
                        Column(
                          children: this
                              .widget
                              .addressSearchObj["nearbyResults"]
                              .map<Widget>((PlacesSearchResult place) {
                            return GestureDetector(
                                onTap: () {
                                  getPlaceById(place.placeId);
                                  setState(() {
                                    isLoading = true;
                                  });
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
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
                                  ),
                                ));
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
                                title: Text("Not Listed",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
