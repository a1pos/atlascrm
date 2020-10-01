import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:atlascrm/services/ApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class NotificationCenter extends StatefulWidget {
  final ApiService apiService = new ApiService();

  NotificationCenter();

  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  @override
  void initState() {
    super.initState();
    initNotificationsSub();
  }

  var notifCount = 0;

  Future<void> initNotificationsSub() async {
    Operation options =
        Operation(operationName: "NOTIFICATION_SUB", documentNode: gql("""
          subscription NOTIFICATION_SUB(\$employee: uuid) {
            notification(where: {employee: {_eq: \$employee}, _and: {is_read: {_eq: false}}}){
              document
            }
          }
            """), variables: {"employee": "${UserService.employee.employee}"});

    var result = client.subscribe(options);
    result.listen(
      (data) async {
        var notificationsArrDecoded = data.data["notification"];
        if (notificationsArrDecoded != null) {
          setState(() {
            notifCount = notificationsArrDecoded.length;
          });
        }
      },
      onError: (error) {
        print(error);

        Fluttertoast.showToast(
            msg: "Failed to load notifications for employee!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  void openNotificationPanel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Notifications: ${notifCount.toString()}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Take a new picture or upload from gallery?'),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: UniversalStyles.actionColor,
              onPressed: () async {},
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                  ),
                  Text(
                    'Take Picture',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: UniversalStyles.actionColor,
              onPressed: () async {},
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.collections,
                    color: Colors.white,
                  ),
                  Text(
                    'Gallery',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Stack(children: <Widget>[
          Icon(Icons.notifications, color: Colors.white, size: 40),
          Positioned(
            right: 2,
            top: 2,
            child: notifCount > 0
                ? Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${notifCount.toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(),
          ),
        ]),
        onTap: () {
          openNotificationPanel();
        });
  }
}
