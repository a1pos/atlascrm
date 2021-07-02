import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalStyles.themeColor,
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 300,
                  width: 300,
                  child: Image.asset(
                    "assets/globe-PS.gif",
                    height: 300.0,
                    width: 300.0,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
