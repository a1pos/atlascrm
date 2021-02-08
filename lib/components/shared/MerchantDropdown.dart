import 'package:atlascrm/services/GqlClientFactory.dart';
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
        merchant(where: {is_active: {_eq: true}}) {
          merchant
          businessName: document(path:"leadDocument['businessName']")
        }
      }
      """), fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var merchantsArrDecoded = result.data["merchant"];
        if (merchantsArrDecoded != null) {
          if (this.mounted) {
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
          print("MERCHANT: ");
          print(merchant);
          if (this.widget.value == merchant["merchant"] &&
              merchant["businessName"] != null) {
            startVal = merchant["businessName"];
          }
        }
      } else {
        print("GRAPHQL ERROR: " + result.exception.toString());
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
                      } else if (merchant["document"]["businessName"] != null) {
                        merchantBusinessName = merchant["businessName"];
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
