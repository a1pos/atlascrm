import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/ApiService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class InventoryHistoryList extends StatefulWidget {
  final ApiService apiService = new ApiService();
  final String inventoryID;

  InventoryHistoryList(this.inventoryID);

  @override
  _InventoryHistoryListState createState() => _InventoryHistoryListState();
}

class _InventoryHistoryListState extends State<InventoryHistoryList> {
  bool isLoading = true;
  var historyList = [];
  var subscription;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();
    getHistoryData();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> getHistoryData() async {
    SubscriptionOptions options = SubscriptionOptions(
      document: gql("""
      subscription GET_INVENTORY_HISTORY {
        inventory_tracking(order_by: {created_at: desc}, where: {inventory: {_eq: "${this.widget.inventoryID}"}}) {
          inventory_tracking
          inventoryTrackingTypeByInventoryTrackingType {
            title
          }
          old_employee
          employeeByEmployee {
            document
          }
          created_by
          created_at
          merchant
          old_merchant
          inventoryLocationByInventoryLocation {
            name
          }
          merchantByMerchant {
            document
          }
        }
      }
      """),
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
        var inventoryTracking = data.data["inventory_tracking"];
        if (inventoryTracking != null && this.mounted) {
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Inventory history data loaded");
          });

          setState(() {
            historyList = inventoryTracking;
            isLoading = false;
          });
        }
      },
      (error) {
        debugPrint("Error in loading device history list: " + error.toString());
        logger.e("Error in loading device history list: " + error.toString());
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  getEmployee(employeeId) async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_EMPLOYEE_BY_PK {
        employee_by_pk(employee: "$employeeId"){
          displayName: document(path: "displayName")
        }
      }
    """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result.hasException == false) {
      var body = result.data["employee_by_pk"];
      if (body != null) {
        return await body["displayName"];
      }
    }
  }

  Widget buildHistoryList() {
    return ListView(
      shrinkWrap: true,
      children: List.generate(
        historyList.length,
        (index) {
          var event = historyList[index];
          var eventType =
              event["inventoryTrackingTypeByInventoryTrackingType"]["title"];
          var eventEmployee;
          if (eventType == "Returned" || eventType == "Scanned In") {
            eventEmployee = FutureBuilder(
              future: getEmployee(event["created_by"]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data);
                } else {
                  return Text("loading");
                }
              },
            );
          } else {
            eventEmployee =
                Text(event["employeeByEmployee"]["document"]["displayName"]);
          }
          var initDate = DateTime.parse(event["created_at"]).toLocal();
          var eventDate = DateFormat.yMd().add_jm().format(initDate);
          var inventoryMerchant = event["merchant"];
          var inventoryMerchantDoc = event["merchantByMerchant"];
          var otherCompany = false;

          if (inventoryMerchantDoc == null && inventoryMerchant != null) {
            otherCompany = true;
          }

          return !otherCompany
              ? Card(
                  shape: new RoundedRectangleBorder(
                    side: new BorderSide(color: Colors.grey[200], width: 2.0),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(
                      eventType == "Returned" || eventType == "Scanned In"
                          ? event["inventoryLocationByInventoryLocation"]
                              ["name"]
                          : event["merchantByMerchant"]["document"]
                              ["leadDocument"]["businessName"],
                      style:
                          eventType == "Returned" || eventType == "Scanned In"
                              ? TextStyle(color: UniversalStyles.actionColor)
                              : null,
                    ),
                    subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: eventEmployee,
                      ),
                    ),
                    trailing: Column(
                      children: <Widget>[
                        Text(eventDate),
                        Text(eventType),
                      ],
                    ),
                  ),
                )
              : Container();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? CenteredLoadingSpinner() : buildHistoryList();
  }
}
