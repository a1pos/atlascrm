import 'package:atlascrm/services/GqlClientFactory.dart';
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
  bool isLoading = true;

  var leads = [];
  var disabled;
  var startVal;

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
    } else {
      options = QueryOptions(
        documentNode: gql("""
            query EMPLOYEE_LEADS {
              employee_by_pk(employee: "${this.widget.employeeId}") {
                leads {
                  lead
                  document
                }
              }
            }
            """),
        fetchPolicy: FetchPolicy.networkOnly,
      );
    }
    if (this.widget.employeeId != null) {
      final QueryResult result = await GqlClientFactory().authGqlquery(options);
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
      ],
    );
  }
}
