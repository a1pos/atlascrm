import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:flutter/material.dart';

class CenteredLoadingSpinner extends StatelessWidget {
  final Key key;

  CenteredLoadingSpinner({this.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: this.key,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(UniversalStyles.themeColor),
        ),
      ),
    );
  }
}
