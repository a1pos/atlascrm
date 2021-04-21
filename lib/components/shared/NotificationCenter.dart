import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/screens/leads/LeadNotes.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:atlascrm/services/ApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:atlascrm/components/shared/Empty.dart';

class NotificationCenter extends StatefulWidget {
  final ApiService apiService = new ApiService();

  NotificationCenter();

  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  bool notesEmpty = true;
  var notifCountIcon = 0;
  var notifCount = 0;
  var notifications = [];
  var subscription;

  @override
  void initState() {
    super.initState();
    initNotificationsSub();
    getNotifications();
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
        }
      },
      (error) {},
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  Future<void> getNotifications() async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_NOTIFICATIONS(\$employee: uuid!) {
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
          is_read
          document
          created_at
        }
      }
    """),
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      variables: {"employee": "${UserService.employee.employee}"},
    );

    final result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var notificationsArrDecoded1 = result.data["notification"];
        if (notificationsArrDecoded1 != null) {
          var notificationsArr = List.from(notificationsArrDecoded1);
          if (notificationsArr.length > 0) {
            setState(
              () {
                notesEmpty = false;
                notifications = notificationsArr;
                notifCount = notificationsArr.length;
              },
            );
          }
        }
      }
    }
  }

  Future<void> markOneAsRead(notification) async {
    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
          mutation UPDATE_NOTIFICATION (\$notification: uuid){
            update_notification(where: {notification: {_eq: \$notification}}, _set: {is_read: true}) {
              returning {
                notification
              }
            }
          }
      """),
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {"notification": notification},
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

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
    buildNotifList();
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
    getNotifications();
  }

  void openNotificationPanel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Notifications: ${notifCount.toString()}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return notesEmpty
                ? Empty("No notifcations to display")
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          width: 300,
                          height: 400,
                          child: buildNotifList(),
                        ),
                      )
                    ],
                  );
          }),
          actions: <Widget>[
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: UniversalStyles.actionColor,
              onPressed: () async {
                return showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Dismiss Notifications'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text("Dismiss all notifications?"),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Yes',
                            style: TextStyle(fontSize: 17),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            dismissAll();
                          },
                        ),
                        TextButton(
                            child: Text(
                              'No',
                              style: TextStyle(fontSize: 17),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: <Widget>[
                  Text(
                    'Dismiss All',
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
    getNotifications();
    return Padding(
      padding: EdgeInsets.only(left: 0),
      child: ListView(
        shrinkWrap: true,
        children: List.generate(
          notifications.length,
          (index) {
            var notification = notifications[index];
            var createdAt = DateTime.parse(notification["created_at"]);
            var moment = Moment.now();

            return GestureDetector(
              onTap: () {
                // markOneAsRead(notification["notification"]);
                // Navigator.pop(context);
              },
              child: Card(
                elevation: 3,
                shape: new RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.black26, width: .5),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 2.5, 0),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(top: 1),
                        leading: Transform.translate(
                          offset: Offset(-10, 0),
                          child: IconButton(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            icon: Icon(Icons.lens,
                                color: Colors.blue.shade300, size: 15),
                            onPressed: () {},
                          ),
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Transform.translate(
                            offset: Offset(-35, 0),
                            child: Text(
                              notification["document"]["title"],
                              softWrap: true,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        subtitle: Transform.translate(
                          offset: Offset(-35, 0),
                          child: Text(
                            moment.from(createdAt),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        trailing: Container(
                          width: 30,
                          padding: EdgeInsets.all(0),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.centerLeft,
                            icon: Icon(Icons.clear,
                                color: Colors.black26, size: 20),
                            onPressed: () {
                              markOneAsRead(notification["notification"]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
                          fontSize: 12,
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
