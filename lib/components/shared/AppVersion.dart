import 'package:flutter/material.dart';
import 'dart:async';
import 'package:round2crm/services/ApiService.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion extends StatefulWidget {
  final ApiService apiService = new ApiService();

  AppVersion();

  @override
  _AppVersionState createState() => _AppVersionState();
}

class _AppVersionState extends State<AppVersion> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          enabled: false,
          title: Text("Version"),
          trailing: Text(
            _packageInfo.version,
            style: TextStyle(color: Colors.black38),
          ),
        )
      ],
    );
  }
}
