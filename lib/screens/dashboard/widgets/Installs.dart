import 'package:round2crm/components/install/InstallScheduleForm.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class Installs extends StatefulWidget {
  Installs({Key key}) : super(key: key);

  @override
  InstallsState createState() => InstallsState();
}

class InstallsState extends State<Installs> {
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output:
  );

  bool isLoading = true;
  bool isEmpty = true;

  List installs = [];
  List activeInstalls = [];

  ScrollController _scrollController = ScrollController();

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
          logger.i("Installs widget initialized");
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
      (error) {
        print("Error in installs widget: " + error.toString());
        logger.e("Error in installs widget: " + error.toString());
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      _scrollController.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      logger.i("Installs widget refreshed");
      initInstalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CenteredLoadingSpinner()
        : !isEmpty
            ? ListView(
                controller: _scrollController,
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
