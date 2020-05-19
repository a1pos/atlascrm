import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

const kGoogleApiKey = "AIzaSyB-rMAdwtIjM7s_4Lb8SdRXAfhbiLTVl7s";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class AddressSearch extends StatefulWidget {
  final String locationValue;
  final Function onAddressChange;
  final TextEditingController controller;
  final bool returnNearby;
  AddressSearch(
      {this.locationValue,
      this.onAddressChange,
      this.controller,
      this.returnNearby});

  @override
  _AddressSearchState createState() => _AddressSearchState();
}

var locationTextController = TextEditingController();
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

String locationText = "Enter an address";

class _AddressSearchState extends State<AddressSearch> {
  @override
  void initState() {
    super.initState();
    initLocationText();
  }

  initLocationText() {
    if (this.widget.locationValue != null) {
      locationText = this.widget.locationValue;
    } else {
      locationText = "Enter an address";
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Prediction p = await PlacesAutocomplete.show(
              context: context, apiKey: kGoogleApiKey, mode: Mode.overlay);
          displayPrediction(p);
        },
        child: Column(children: <Widget>[
          Align(alignment: Alignment.bottomLeft, child: Text(locationText)),
          Divider(thickness: .5, color: Colors.black)
        ]));
  }

  Future<Null> displayPrediction(Prediction p) async {
    var nearbyCheck;
    if (this.widget.returnNearby == null || this.widget.returnNearby == false) {
      nearbyCheck = false;
    } else {
      nearbyCheck = true;
    }
    List nearbyResults;
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      if (nearbyCheck) {
        PlacesSearchResponse respo = await _places.searchNearbyWithRadius(
            new Location(detail.result.geometry.location.lat,
                detail.result.geometry.location.lng),
            200);
        nearbyResults = respo.results;
      }
      Map addressInfo = {"address": "", "city": "", "state": "", "zipcode": ""};
      Map shortAddress = {"address": ""};
      List newAddress = detail.result.addressComponents;
      newAddress.forEach((element) {
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
      setState(() {
        locationText = detail.result.formattedAddress;
      });
      if (nearbyCheck) {
        Map mixedReply = {
          "address": addressInfo,
          "nearbyResults": nearbyResults,
          "shortaddress": shortAddress
        };
        this.widget.onAddressChange(mixedReply);
      } else {
        this.widget.onAddressChange(addressInfo);
      }
    }
  }
}
