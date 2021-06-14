import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:atlascrm/components/install/InstallScheduleForm.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/MerchantDropdown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripList extends StatefulWidget {
  final ApiService apiService = new ApiService();

  TripList();

  @override
  _TripListState createState() => _TripListState();
}

class _TripListState extends State<TripList> {}
