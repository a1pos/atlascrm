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
  var notifications = [];

  Future<void> initNotificationsSub() async {
    Operation options =
        Operation(operationName: "NOTIFICATION_SUB", documentNode: gql("""
          subscription NOTIFICATION_SUB(\$employee: uuid) {
            notification(where: {employee: {_eq: \$employee}, _and: {is_read: {_eq: false}}}){
              notification
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
            notifications = notificationsArrDecoded;
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

  Future<void> markOneAsRead(notification) async {
    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
          mutation UPDATE_NOTIFICATION (\$notification: uuid){
            update_notification(where: {notification: {_eq: \$notification}}, _set: {is_read: true}) {
              returning {
                notification
              }
            }
          }
      """), variables: {"notification": notification});
    final QueryResult result = await client.mutate(mutateOptions);

    if (result.hasException == false) {
      Fluttertoast.showToast(
          msg: "Notification Marked as Read!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to update Notifications!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> markAllAsRead() async {
    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
          mutation UPDATE_NOTIFICATIONS (\$employee: uuid){
            update_notification(where: {employee: {_eq: \$employee}, _and: {is_read: {_eq: false}}}, _set: {is_read: true}) {
              returning {
                notification
              }
            }
          }
      """), variables: {"employee": UserService.employee.employee});
    final QueryResult result = await client.mutate(mutateOptions);

    if (result.hasException == false) {
      Fluttertoast.showToast(
          msg: "Notifications Marked as Read!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to update Notifications!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void openNotificationPanel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Notifications: ${notifCount.toString()}'),
          content: Column(
            children: <Widget>[
              Container(width: 300, height: 400, child: buildNotifList()),
            ],
          ),
          actions: <Widget>[
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: UniversalStyles.actionColor,
              onPressed: () async {
                markAllAsRead();
                Navigator.pop(context);
              },
              child: Row(
                children: <Widget>[
                  // Icon(
                  //   Icons.add_a_photo,
                  //   color: Colors.white,
                  // ),
                  Text(
                    'Mark all as read',
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

  Widget buildNotifList() {
    return ListView(
        shrinkWrap: true,
        children: List.generate(notifications.length, (index) {
          var notification = notifications[index];
          return GestureDetector(
              onTap: () {
                markOneAsRead(notification["notification"]);
                Navigator.pop(context);
              },
              child: Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(4.0)),
                  child: ListTile(
                      title: Text(notification["document"]["title"]),
                      subtitle: Text(notification["document"]["body"]),
                      trailing: IconButton(
                        icon: Icon(Icons.lens, color: Colors.red, size: 15),
                        onPressed: () {},
                      ))));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Stack(children: <Widget>[
          Icon(Icons.notifications, color: Colors.white, size: 35),
          Positioned(
            right: 0,
            top: 2,
            child: notifCount > 0
                ? Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
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
