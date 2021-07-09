import 'package:logger/logger.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:round2crm/services/ApiService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:simple_moment/simple_moment.dart';
import 'Empty.dart';

class BuildNotifList extends StatefulWidget {
  final ApiService apiService = new ApiService();

  BuildNotifList();

  @override
  _BuildNotifListState createState() => _BuildNotifListState();
}

class _BuildNotifListState extends State<BuildNotifList> {
  bool notesEmpty = true;
  bool isLoading = true;
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

  Future<void> getNotifications() async {
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
              is_read
              document
              created_at
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
          logger.i("Notifications loaded in notifications center");
          setState(
            () {
              isLoading = false;
              notifications = notificationsArrDecoded;
              notifCount = notificationsArrDecoded.length;
              notificationsDisplay = notifications;
            },
          );

          if (notifCount > 0) {
            setState(
              () {
                notesEmpty = false;
              },
            );
          }
        }
      },
      (error) {
        print("Error in loading notifications: " + error.toString());
        logger.e("Error in loading notifications: " + error.toString());
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      getNotifications();
      logger.i("Notifications refreshed");
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
      fetchPolicy: FetchPolicy.noCache,
      variables: {"notification": notification},
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

    if (result.hasException == false) {
      logger.i("Notification marked as read: " + notification.toString());
      Fluttertoast.showToast(
          msg: "Notification Marked as Read!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
      getNotifications();
    } else {
      print(
          "Error marking notification as read: " + result.exception.toString());
      logger.e(
          "Error marking notification as read: " + result.exception.toString());

      Fluttertoast.showToast(
          msg: "Failed to mark notification as read: " +
              result.exception.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    notifCount--;
    if (notifCount == 0) {
      logger.i("Notification count 0, closing notifications panel");
      Navigator.of(context).pop();
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
      logger.i("Notifications marked as read");
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
      print("Error marking all notifications as read: " +
          result.exception.toString());
      logger.e("Error marking all notifications as read: " +
          result.exception.toString());
      Fluttertoast.showToast(
        msg: "Error marking all notifications as read: " +
            result.exception.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Widget buildNotifList() {
    return Padding(
      padding: EdgeInsets.only(left: 0),
      child: isLoading
          ? CenteredLoadingSpinner()
          : !notesEmpty
              ? ListView(
                  shrinkWrap: true,
                  children: List.generate(
                    notificationsDisplay.length,
                    (index) {
                      var notification = notificationsDisplay[index];
                      var createdAt =
                          DateTime.parse(notification["created_at"]);
                      var moment = Moment.now();

                      return Container(
                        child: Card(
                          elevation: 3,
                          shape: new RoundedRectangleBorder(
                            side: new BorderSide(
                              color: Colors.black26,
                              width: .5,
                            ),
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
                                          color: Colors.blue.shade300,
                                          size: 15),
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
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.black26,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        markOneAsRead(
                                            notification["notification"]);
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
                )
              : Empty("No notifications to display"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Notifications: ${notifCount.toString()}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  logger.i("Notifications panel closed");
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey[750],
                  size: 30.0,
                ),
              ),
            ],
          )),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(
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
        notifCount > 0
            ? MaterialButton(
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
              )
            : Container(),
      ],
    );
  }
}
