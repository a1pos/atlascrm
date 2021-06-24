import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class CompanyDropDown extends StatefulWidget {
  final bool disabled;
  final Function callback;
  final String employeeId;
  final String value;

  CompanyDropDown({this.employeeId, this.callback, this.value, this.disabled});

  @override
  _CompanyDropDownState createState() => _CompanyDropDownState();
}

class _CompanyDropDownState extends State<CompanyDropDown> {
  var companies = [];
  var disabled;
  var startVal;
  String companyDropdownVal = "";

  @override
  void initState() {
    super.initState();

    initCompanies();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  Future<void> initCompanies() async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_V_COMPANY {
          v_company(order_by: { title: asc }) {
            company
            title
          }
        }
      """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var companiesArrDecoded = result.data["v_company"];
        if (companiesArrDecoded != null) {
          if (this.mounted) {
            companiesArrDecoded.sort((a, b) => a["title"]
                .toString()
                .toUpperCase()
                .compareTo(b["title"].toString().toUpperCase()));
            setState(() {
              companies = companiesArrDecoded;
            });
          }
        }
        for (var company in companies) {
          if (this.widget.value == company["company"] &&
              company["title"] != null) {
            startVal = company["title"];
          }
        }
      } else {
        print("GRAPHQL ERROR: " + result.exception.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Company',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        DropdownButtonFormField(
          value: startVal,
          hint: Text("Please choose one"),
          isExpanded: true,
          items: companies.map<DropdownMenuItem<String>>((dynamic item) {
            var companyName;

            if (item["title"] != null) {
              companyName = item["title"];
            } else {
              companyName = "";
            }
            return DropdownMenuItem<String>(
              value: companyName,
              child: Text(
                companyName,
              ),
            );
          }).toList(),
          onChanged: disabled
              ? null
              : (newValue) {
                  setState(() {
                    var setVal;
                    for (var company in companies) {
                      var companyName;
                      if (company["title"] != null) {
                        companyName = company["title"];
                      } else {
                        companyName = "";
                      }
                      if (newValue == companyName) {
                        setVal = company["company"];
                      }
                    }
                    startVal = newValue;
                    var returnObj = {"id": setVal, "name": newValue};
                    this.widget.callback(returnObj);
                  });
                },
          validator: (value) {
            if (value == null) {
              return "Please select a company";
            }
            return null;
          },
        ),
        // SearchableDropdown.single(
        //   value: startVal,
        //   onClear: () {
        //     setState(() {
        //       this.widget.callback(null);
        //     });
        //   },
        //   hint: "Please choose one",
        //   displayClearIcon: true,
        //   searchHint: null,
        //   isExpanded: true,
        //   items: companies.map<DropdownMenuItem<String>>((dynamic item) {
        //     var companyName;

        //     if (item["title"] != null) {
        //       companyName = item["title"];
        //     } else {
        //       companyName = "";
        //     }
        //     return DropdownMenuItem<String>(
        //       value: companyName,
        //       child: Text(
        //         companyName,
        //       ),
        //     );
        //   }).toList(),
        //   disabledHint: startVal,
        //   onChanged: disabled
        //       ? null
        //       : (newValue) {
        //           setState(() {
        //             var setVal;
        //             for (var company in companies) {
        //               var companyName;
        //               if (company["title"] != null) {
        //                 companyName = company["title"];
        //               } else {
        //                 companyName = "";
        //               }
        //               if (newValue == companyName) {
        //                 setVal = company["company"];
        //               }
        //             }
        //             startVal = newValue;
        //             var returnObj = {"id": setVal, "name": newValue};
        //             this.widget.callback(returnObj);
        //           });
        //         },
        //   validator: (value) {
        //     if (value == null) {
        //       return "Please select a company";
        //     }
        //     return null;
        //   },
        // )
      ],
    );
  }
}
