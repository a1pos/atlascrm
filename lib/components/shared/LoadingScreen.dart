import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalStyles.backgroundColor,
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(UniversalStyles.themeColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(50),
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
