import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class RoleDropDown extends StatefulWidget {
  RoleDropDown({this.callback, this.value, this.disabled});

  final String value;
  final Function callback;
  final bool disabled;

  @override
  _RoleDropDownState createState() => _RoleDropDownState();
}

class _RoleDropDownState extends State<RoleDropDown> {
  var roles = [];
  var disabled;

  @override
  void initState() {
    super.initState();

    initRoles();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  var startVal;

  Future<void> initRoles() async {
    QueryOptions options = QueryOptions(documentNode: gql("""
      query GET_ROLES {
        role{
          role
          title
          document
        }
      }
      """), fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult rolesResp =
        await GqlClientFactory().authGqlquery(options);

    //REPLACE WITH GRAPHQL
    // var locationsResp = await apiService.authGet(context, "/inventory/tier");
    if (rolesResp != null) {
      if (rolesResp.hasException == false) {
        var rolesArrDecoded = rolesResp.data["role"];
        if (rolesArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              roles = rolesArrDecoded;
            });
          }
        }
        for (var role in roles) {
          if (this.widget.value == role["role"]) {
            startVal = role["title"];
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Role',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        SearchableDropdown.single(
          value: startVal,
          onClear: () {
            setState(() {
              this.widget.callback("");
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
          items: roles.map<DropdownMenuItem<String>>((dynamic item) {
            var businessName;
            if (item["title"]?.isEmpty ?? true) {
              businessName = "";
            } else {
              businessName = item["title"];
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
                    for (var role in roles) {
                      if (newValue == role["title"]) {
                        setVal = role["role"];
                      }
                    }
                    startVal = setVal;
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
