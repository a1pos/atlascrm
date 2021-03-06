import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:round2crm/services/ApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/components/shared/BuildNotifList.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class NotificationCenter extends StatefulWidget {
  final ApiService apiService = new ApiService();

  NotificationCenter();

  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  bool notesEmpty = true;
  bool isLoading = false;
  var notifCountIcon = 0;
  var notifCount = 0;
  var notifications = [];
  var notificationsDisplay = [];
  var subscription;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();
    initNotificationsSub();
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  Future<void> initNotificationsSub() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "SUBSCRIPTION_NOTIFICATIONS",
      document: gql("""
          subscription SUBSCRIPTION_NOTIFICATIONS(\$employee: uuid!){
              notification(
              order_by: {created_at: desc},
              where: {
                _and: [
                  {employee: {_eq: \$employee}}
                  {is_read: {_eq: false}}
                ]
              }
            ){
              notification
            }
          }
            """),
      fetchPolicy: FetchPolicy.noCache,
      variables: {"employee": "${UserService.employee.employee}"},
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
        var notificationsArrDecoded = data.data["notification"];
        if (notificationsArrDecoded != null && this.mounted) {
          setState(() {
            notifCountIcon = notificationsArrDecoded.length;
          });

          Future.delayed(Duration(seconds: 1), () {
            logger.i("Notification center data initialized, " +
                notifCountIcon.toString() +
                " notifications loaded");
          });
        }
      },
      (error) {
        Future.delayed(Duration(seconds: 1), () {
          logger.e("ERROR: Error in notifications center: " + error.toString());
        });
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initNotificationsSub();
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Notifications center data refreshed");
      });
    }
  }

  Future<void> dismissAll() async {
    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
          mutation UPDATE_NOTIFICATIONS (\$employee: uuid){
            update_notification(where: {employee: {_eq: \$employee}, _and: {is_read: {_eq: false}}}, _set: {is_read: true}) {
              returning {
                notification
              }
            }
          }
      """),
      fetchPolicy: FetchPolicy.noCache,
      variables: {"employee": UserService.employee.employee},
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

    if (result.hasException == false) {
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Notifications marked as read");
      });

      Fluttertoast.showToast(
        msg: "Notifications Marked as Read!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        logger.e(
            "Failed to update notifications: " + result.exception.toString());
      });

      Fluttertoast.showToast(
        msg: "Failed to update Notifications: " + result.exception.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void openNotificationPanel() {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Notification panel opened");
    });

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return BuildNotifList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Stack(
          children: <Widget>[
            Icon(
              Icons.notifications,
              color: Colors.white,
              size: 35,
            ),
            Positioned(
              right: 0,
              top: 2,
              child: notifCountIcon > 0
                  ? Container(
                      padding: EdgeInsets.all(2),
                      decoration: new BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${notifCountIcon.toString()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
        onTap: () {
          openNotificationPanel();
        });
  }
}
