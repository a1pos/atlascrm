import 'package:atlascrm/components/install/InstallItem.dart';
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
        }
        isLoading = false;
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
    return Container(
      child: isLoading
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CenteredLoadingSpinner(),
              ],
            )
          : activeInstalls == null
              ? Empty("No Active Installs found")
              : buildDLGridView(context, activeInstalls),
    );
  }
}

Widget buildDLGridView(BuildContext context, list) {
  return list.length == 0
      ? Empty("No Active Installs found")
      : ListView(
          shrinkWrap: true,
          children: List.generate(
            list.length,
            (index) {
              var install = list[index];
              var date = DateFormat("EEE, MMM d, ''yy")
                  .add_jm()
                  .format(DateTime.parse(install["date"]).toLocal());

              return GestureDetector(
                onTap: () {
                  return null;
                },
                child: InstallItem(
                  merchant: install["merchantbusinessname"],
                  dateTime: date ?? "TBD",
                  merchantDevice: install["merchantdevice"] ?? "No Terminal",
                  employeeFullName: install["employeefullname"] ?? "",
                  location: install["location"],
                ),
              );
            },
          ),
        );
}
