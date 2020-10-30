import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class MerchantDropDown extends StatefulWidget {
  MerchantDropDown({this.employeeId, this.callback, this.value, this.disabled});

  final String employeeId;
  final String value;
  final Function callback;
  final bool disabled;

  @override
  _MerchantDropDownState createState() => _MerchantDropDownState();
}

class _MerchantDropDownState extends State<MerchantDropDown> {
  var merchants = [];
  var disabled;

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

  var startVal;

  Future<void> initMerchants(e) async {
    QueryOptions options = QueryOptions(documentNode: gql("""
        query GET_MERCHANTS {
          merchant{
            merchant
            document
          }
        }
      """), fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult result = await authGqlQuery(options);

    if (result != null) {
      if (result.hasException == false) {
        var merchantsArrDecoded = result.data["merchant"];
        if (merchantsArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              merchants = merchantsArrDecoded;
            });
          }
        }
        for (var merchant in merchants) {
          if (this.widget.value == merchant["merchant"]) {
            startVal = merchant["document"]["leadDocument"]["businessName"];
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // initMerchants(this.widget.employeeId);
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
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
          items: merchants.map<DropdownMenuItem<String>>((dynamic item) {
            var merchantName;
            if (item["document"]["leadDocument"]?.isEmpty ?? true) {
              merchantName = "";
            } else {
              merchantName = item["document"]["leadDocument"]["businessName"];
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
                      if (merchant["document"]["leadDocument"] != null) {
                        merchantBusinessName = merchant["document"]
                            ["leadDocument"]["businessName"];
                      } else if (merchant["document"]["businessName"] != null) {
                        merchantBusinessName =
                            merchant["document"]["businessName"];
                      } else {
                        merchantBusinessName = "";
                      }
                      if (newValue == merchantBusinessName) {
                        setVal = merchant["merchant"];
                      }
                    }
                    startVal = newValue;
                    var returnObj = {"id": setVal, "name": newValue};
                    this.widget.callback(returnObj);
                  });
                },
        )

        // DropdownButtonFormField<String>(
        //   isExpanded: true,
        //   value: this.widget.value,
        //   hint: Text("Please choose one"),
        //   items: merchants.map((dynamic item) {
        //     var merchantname;
        //     if (item["document"]?.isEmpty ?? true) {
        //       merchantname = "";
        //     } else {
        //       merchantname = item["document"]["dbaname"];
        //     }
        //     return DropdownMenuItem<String>(
        //       value: item["merchant"],
        //       child: Text(
        //         merchantname,
        //       ),
        //     );
        //   }).toList(),
        //   onChanged: (newValue) {
        //     this.widget.callback(newValue);
        //   },
        // ),
      ],
    );
  }
}
