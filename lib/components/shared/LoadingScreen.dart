import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

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

              // Container(
              //     height: 100,
              //     width: 100,
              //     child: LoadingDoubleFlipping.square(
              //       size: 100,
              //       duration: Duration(milliseconds: 1150),
              //       backgroundColor: Colors.white70,
              //     )
              //     ),
              // Padding(
              //   padding: EdgeInsets.all(50),
              //   child: Text(
              //     'Loading...',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 18,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
