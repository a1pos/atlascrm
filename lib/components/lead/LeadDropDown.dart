import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
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

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

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
        document: gql("""
            query EMPLOYEE_LEADS {
              employee_by_pk(employee: "${this.widget.employeeId}") {
                leads {
                  lead
                  document
                }
              }
            }
            """),
      );
    }
    if (this.widget.employeeId != null) {
      final QueryResult result = await GqlClientFactory().authGqlquery(options);
      var leadsArrDecoded;
      if (result != null) {
        if (result.hasException == false) {
          logger.i("Leads loaded for lead dropdown");
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
        } else {
          print("Error loading leads for dropdown: " +
              result.exception.toString());
          logger.e("Error loading leads for dropdown: " +
              result.exception.toString());

          Fluttertoast.showToast(
            msg: "Error loading leads for dropdown: " +
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
              startVal = null;
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
                  if (newValue != null) {
                    setState(() {
                      var setVal;
                      for (var lead in leads) {
                        if (newValue == lead["document"]["businessName"]) {
                          setVal = lead["lead"];
                        }
                      }
                      startVal = newValue;
                      this.widget.callback(setVal);
                      logger.i("Lead dropdown value set: " +
                          newValue +
                          " (" +
                          setVal.toString() +
                          ")");
                    });
                  } else {
                    setState(() {
                      startVal = null;
                      this.widget.callback(null);
                    });
                    logger.i("Lead dropdown value cleared");
                  }
                },
        )
      ],
    );
  }
}
