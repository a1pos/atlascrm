import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:atlascrm/services/ApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:atlascrm/components/shared/BuildNotifList.dart';

class NotificationCenter extends StatefulWidget {
  final ApiService apiService = new ApiService();

  NotificationCenter();

  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  bool isEmpty = true;
  bool isLoading = false;
  var notifCountIcon;
  var notifCount = 0;
  var notifications = [];
  var notificationsDisplay = [];

  @override
  void initState() {
    super.initState();
  }

  final subscriptionDocument = gql("""
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
    """);

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
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {"employee": UserService.employee.employee},
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

    if (result.hasException == false) {
      Fluttertoast.showToast(
          msg: "Notifications Marked as Read!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).pop();
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
        return BuildNotifList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Subscription(
          options: SubscriptionOptions(
            operationName: "SUBSCRIPTION_NOTIFICATIONS",
            document: subscriptionDocument,
            variables: {"employee": "${UserService.employee.employee}"},
            cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
            fetchPolicy: FetchPolicy.networkOnly,
          ),
          builder: (result) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.data != null) {
              if (result.data["notification"].length > 0) {
                notifCountIcon = result.data["notification"].length;
                isEmpty = false;
              } else {
                isEmpty = true;
              }
            }
            return Stack(
              children: <Widget>[
                Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 35,
                ),
                Positioned(
                  right: 0,
                  top: 2,
                  child: !isEmpty
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
                            notifCountIcon.toString(),
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
            );
          },
        ),
        onTap: () {
          openNotificationPanel();
        });
  }
}
