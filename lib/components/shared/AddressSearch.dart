import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

const kGoogleApiKey = "AIzaSyB-rMAdwtIjM7s_4Lb8SdRXAfhbiLTVl7s";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class AddressSearch extends StatefulWidget {
  final String locationValue;
  final Function onAddressChange;
  final TextEditingController controller;

  AddressSearch({this.locationValue, this.onAddressChange, this.controller});

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
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      List newAddress = detail.result.addressComponents;

      List addressInfo = [
        newAddress[0].shortName + " " + newAddress[1].longName,
        newAddress[2].shortName,
        newAddress[5].shortName,
        newAddress[7].shortName,
      ];
      print(addressInfo);
      setState(() {
        locationText = detail.result.formattedAddress;
      });
      this.widget.onAddressChange(addressInfo);
    }
  }
}
