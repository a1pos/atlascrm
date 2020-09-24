import 'package:atlascrm/services/api.dart';
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
      """), pollInterval: 5);

    final QueryResult result = await client.query(options);

    if (result != null) {
      if (result.hasException == false) {
        var rolesArrDecoded = result.data["role"];
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
    initRoles();
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
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
          items: roles.map<DropdownMenuItem<String>>((dynamic item) {
            var roleName;
            if (item["title"]?.isEmpty ?? true) {
              roleName = "";
            } else {
              roleName = item["title"];
            }
            return DropdownMenuItem<String>(
              value: roleName,
              child: Text(
                roleName,
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
                    startVal = newValue;
                    this.widget.callback(setVal);
                  });
                },
        )

        // DropdownButtonFormField<String>(
        //   isExpanded: true,
        //   value: this.widget.value,
        //   hint: Text("Please choose one"),
        //   items: roles.map((dynamic item) {
        //     var rolename;
        //     if (item["document"]?.isEmpty ?? true) {
        //       rolename = "";
        //     } else {
        //       rolename = item["document"]["dbaname"];
        //     }
        //     return DropdownMenuItem<String>(
        //       value: item["role"],
        //       child: Text(
        //         rolename,
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
