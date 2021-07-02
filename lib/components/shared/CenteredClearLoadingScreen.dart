import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:flutter/material.dart';

class CenteredClearLoadingScreen extends StatefulWidget {
  final String loadText;

  CenteredClearLoadingScreen({this.loadText});

  @override
  _CenteredClearLoadingScreenState createState() =>
      _CenteredClearLoadingScreenState();
}

class _CenteredClearLoadingScreenState
    extends State<CenteredClearLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(UniversalStyles.themeColor),
              ),
              Padding(
                padding: EdgeInsets.all(50),
                child: this.widget.loadText != null
                    ? Text(this.widget.loadText)
                    : Text('Loading...'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
