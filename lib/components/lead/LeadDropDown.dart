import 'package:atlascrm/screens/tasks/TaskScreen.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class LeadDropDown extends StatefulWidget {
  LeadDropDown({this.employeeId, this.callback, this.value, this.disabled});

  final String employeeId;
  final String value;
  final Function callback;
  final bool disabled;

  @override
  _LeadDropDownState createState() => _LeadDropDownState();
}

class _LeadDropDownState extends State<LeadDropDown> {
  var leads = [];
  var disabled;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initLeads();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  var startVal;

  Future<void> initLeads() async {
    QueryOptions options;
    if (this.widget.employeeId == null) {
      if (this.mounted) {
        setState(() {
          leads = [];
          isLoading = false;
        });
      }
      return;
      // options = QueryOptions(documentNode: gql("""
      //       query Leads {
      //         lead{
      //           lead
      //           document
      //         }
      //       }
      //       """), fetchPolicy: FetchPolicy.networkOnly);
    } else {
      options = QueryOptions(documentNode: gql("""
            query EMPLOYEE_LEADS {
              employee_by_pk(employee: "${this.widget.employeeId}") {
                leads {
                  lead
                  document
                }
              }
            }
            """), fetchPolicy: FetchPolicy.networkOnly);
    }
    if (this.widget.employeeId != null) {
      final QueryResult result = await authGqlQuery(options);
      var leadsArrDecoded;
      if (result != null) {
        if (result.hasException == false) {
          if (this.widget.employeeId == null) {
            leadsArrDecoded = result.data["lead"];
          } else {
            leadsArrDecoded = result.data["employee_by_pk"]["leads"];
          }
          if (leadsArrDecoded != null) {
            if (this.mounted) {
              setState(() {
                leads = leadsArrDecoded;
              });
            }
          }
          for (var lead in leads) {
            if (this.widget.value == lead["lead"]) {
              startVal = lead["document"]["businessName"];
            }
          }
        }
      }
    }
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Lead',
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
          hint: isLoading ? "Loading..." : "Please choose one",
          searchHint: null,
          isExpanded: true,
          // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
          items: leads.map<DropdownMenuItem<String>>((dynamic item) {
            var businessName;
            if (item["document"]?.isEmpty ?? true) {
              businessName = "";
            } else {
              businessName = item["document"]["businessName"];
            }
            return DropdownMenuItem<String>(
              value: businessName,
              child: Text(
                businessName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: disabled
              ? null
              : (newValue) {
                  setState(() {
                    var setVal;
                    for (var lead in leads) {
                      if (newValue == lead["document"]["businessName"]) {
                        setVal = lead["lead"];
                      }
                    }
                    startVal = newValue;
                    this.widget.callback(setVal);
                  });
                },
        )

        // DropdownButtonFormField<String>(
        //   isExpanded: true,
        //   value: this.widget.value,
        //   hint: Text("Please choose one"),
        //   items: leads.map((dynamic item) {
        //     var businessName;
        //     if (item["document"]?.isEmpty ?? true) {
        //       businessName = "";
        //     } else {
        //       businessName = item["document"]["businessName"];
        //     }
        //     return DropdownMenuItem<String>(
        //       value: item["lead"],
        //       child: Text(
        //         businessName,
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
