import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class MerchantDropDown extends StatefulWidget {
  final bool disabled;
  final Function callback;
  final String employeeId;
  final String value;

  MerchantDropDown({this.employeeId, this.callback, this.value, this.disabled});

  @override
  _MerchantDropDownState createState() => _MerchantDropDownState();
}

class _MerchantDropDownState extends State<MerchantDropDown> {
  var merchants = [];
  var disabled;
  var startVal;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();

    initMerchants(this.widget.employeeId);
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  Future<void> initMerchants(e) async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_MERCHANTS {
        merchant(where: {is_active: {_eq: true}}) {
          merchant
          businessName: document(path:"leadDocument['businessName']")
        }
      }
      """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var merchantsArrDecoded = result.data["merchant"];
        if (merchantsArrDecoded != null) {
          if (this.mounted) {
            Future.delayed(Duration(seconds: 1), () {
              logger.i("Merchant data loaded for dropdown");
            });

            merchantsArrDecoded.sort((a, b) => a["businessName"]
                .toString()
                .toUpperCase()
                .compareTo(b["businessName"].toString().toUpperCase()));
            setState(() {
              merchants = merchantsArrDecoded;
            });
          }
        }
        for (var merchant in merchants) {
          if (this.widget.value == merchant["merchant"] &&
              merchant["businessName"] != null) {
            startVal = merchant["businessName"];
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          logger.e("ERROR: Error getting merchant data for dropdown: " +
              result.exception.toString());
        });

        Fluttertoast.showToast(
          msg: "Error getting merchant data for dropdown: " +
              result.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Merchant',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        SearchableDropdown.single(
          value: startVal,
          onClear: () {
            setState(() {
              startVal = null;
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          items: merchants.map<DropdownMenuItem<String>>((dynamic item) {
            var merchantName;

            if (item["businessName"] != null) {
              merchantName = item["businessName"];
            } else {
              merchantName = "";
            }
            return DropdownMenuItem<String>(
              value: merchantName,
              child: Text(
                merchantName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: disabled
              ? null
              : (newValue) {
                  setState(() {
                    var setVal;
                    for (var merchant in merchants) {
                      var merchantBusinessName;
                      if (merchant["businessName"] != null) {
                        merchantBusinessName = merchant["businessName"];
                      } else {
                        merchantBusinessName = "";
                      }
                      if (newValue == merchantBusinessName) {
                        setVal = merchant["merchant"];
                        Future.delayed(Duration(seconds: 1), () {
                          logger.i("Merchant changed to: " +
                              merchantBusinessName +
                              " (" +
                              setVal.toString() +
                              ")");
                        });
                      }
                    }
                    startVal = newValue;
                    var returnObj = {"id": setVal, "name": newValue};
                    this.widget.callback(returnObj);
                  });
                },
        )
      ],
    );
  }
}
