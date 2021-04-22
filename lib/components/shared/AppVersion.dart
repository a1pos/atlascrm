import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AppVersion extends StatelessWidget {
  final Key key;

  AppVersion({this.key});

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          enabled: false,
          title: Text("Version"),
          trailing: FutureBuilder(
            future: getVersionNumber(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
                Text(
              snapshot.hasData ? snapshot.data : "Loading ...",
              style: TextStyle(color: Colors.black38),
            ),
          ),
        )
      ],
    );
  }
}
