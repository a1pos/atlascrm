import 'package:atlascrm/components/install/InstallItem.dart';
import 'package:atlascrm/components/install/InstallScheduleForm.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class Installs extends StatefulWidget {
  @override
  _InstallsState createState() => _InstallsState();
}

class _InstallsState extends State<Installs> {
  bool isLoading = true;
  bool isEmpty = true;

  List installs = [];
  List activeInstalls = [];

  var subscription;
  var iDate;
  var viewDate;

  @override
  void initState() {
    super.initState();
    initInstalls();
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  Future<void> initInstalls() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "SUBSCRIBE_V_INSTALL",
      document: gql("""
          subscription SUBSCRIBE_V_INSTALL {
            v_install_table (order_by: {date: asc}) {
              install
              merchant
              merchantbusinessname
              employee
              employeefullname
              merchantdevice
              date
              location
              cash_discounting
              ticket_created
              ticket_open
            }
          }

        """),
      fetchPolicy: FetchPolicy.noCache,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) async {
        var installsArrDecoded = data.data["v_install_table"];
        if (installsArrDecoded != null && this.mounted) {
          setState(() {
            installs = installsArrDecoded;
            activeInstalls = installs
                .where((element) => element['ticket_open'] == true)
                .toList();
            isLoading = false;
          });

          if (activeInstalls.length > 0) {
            isEmpty = false;
          } else {
            isEmpty = true;
          }
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
      initInstalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CenteredLoadingSpinner()
        : !isEmpty
            ? ListView(
                shrinkWrap: true,
                children: activeInstalls.map((i) {
                  if (i['date'] != null) {
                    setState(() {
                      iDate = DateFormat("EEE, MMM d, ''yy")
                          .add_jm()
                          .format(DateTime.parse(i['date']).toLocal());
                      viewDate = DateFormat("yyyy-MM-dd HH:mm")
                          .format(DateTime.parse(i['date']).toLocal());
                    });
                  } else {
                    setState(() {
                      iDate = "TBD";
                      viewDate = "";
                    });
                  }
                  return InstallScheduleForm(
                    i,
                    viewDate,
                    iDate,
                    unscheduled: false,
                  );
                }).toList(),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Empty("No active Installs found"),
              );
  }
}
