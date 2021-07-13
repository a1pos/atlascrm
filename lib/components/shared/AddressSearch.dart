import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

const kGoogleApiKey = "AIzaSyB-rMAdwtIjM7s_4Lb8SdRXAfhbiLTVl7s";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class AddressSearch extends StatefulWidget {
  final String locationValue;
  final Function onAddressChange;
  final TextEditingController controller;
  final bool returnNearby;
  final Color lineColor;

  AddressSearch(
      {this.locationValue,
      this.onAddressChange,
      this.controller,
      this.returnNearby,
      this.lineColor});

  @override
  _AddressSearchState createState() => _AddressSearchState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();
String locationText;

var locationTextController = TextEditingController();

var logger = Logger(
  printer: SimpleLogPrinter(),
  output: CustomOutput(),
);

class _AddressSearchState extends State<AddressSearch> {
  @override
  void initState() {
    super.initState();
    setState(() {
      locationText = null;
    });
  }

  initLocationText() {
    if (locationText == null) {
      if (this.widget.locationValue != null) {
        locationText = this.widget.locationValue;
        logger.i("Address added to location value field: " +
            locationText.toString());
      } else {
        locationText = "Enter an address";
      }
    }
  }

  Widget build(BuildContext context) {
    initLocationText();
    return GestureDetector(
      onTap: () async {
        Prediction p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          mode: Mode.overlay,
          types: [],
          language: "en",
          components: [Component(Component.country, "us")],
          strictbounds: false,
        );
        displayPrediction(p);
      },
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Align(alignment: Alignment.bottomLeft, child: Text(locationText)),
            Divider(
                thickness: .5,
                color: this.widget.lineColor != null
                    ? this.widget.lineColor
                    : Colors.black)
          ],
        ),
      ),
    );
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
          new Location(
              lat: detail.result.geometry.location.lat,
              lng: detail.result.geometry.location.lng),
          100,
        );
        nearbyResults = respo.results;
      }
      Map addressInfo = {
        "address": "",
        "city": "",
        "state": "",
        "zipcode": "",
        "address2": ""
      };
      Map shortAddress = {"address": ""};
      List newAddress = detail.result.addressComponents;
      newAddress.forEach(
        (element) {
          element.types.forEach(
            (type) {
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
            },
          );
        },
      );
      setState(() {
        locationText = detail.result.formattedAddress;
      });
      if (nearbyCheck) {
        if (addressInfo["address2"] != "") {
          shortAddress["address"] += " " + addressInfo["address2"];
        }
        Map mixedReply = {
          "formattedaddr": detail.result.formattedAddress,
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
