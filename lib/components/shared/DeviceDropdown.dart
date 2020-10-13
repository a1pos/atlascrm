import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class DeviceDropDown extends StatefulWidget {
  DeviceDropDown({this.callback, this.value, this.disabled, this.employee});

  final String value;
  final Function callback;
  final bool disabled;
  final String employee;

  @override
  _DeviceDropDownState createState() => _DeviceDropDownState();
}

class _DeviceDropDownState extends State<DeviceDropDown> {
  var devices = [];
  var disabled;

  @override
  void initState() {
    super.initState();

    initDevices();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  var startVal;

  Future<void> initDevices() async {
    QueryOptions options = QueryOptions(
        documentNode: gql("""
      query MyQuery (\$employee: uuid!){
        employee_device(where: {employee: {_eq: \$employee}}){
          employee_device
            deviceName: document(path: "deviceName")
            device_id
          }
        }
      """),
        variables: {"employee": this.widget.employee},
        fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult devicesResp = await authGqlQuery(options);

    //REPLACE WITH GRAPHQL
    // var locationsResp = await apiService.authGet(context, "/inventory/tier");
    if (devicesResp != null) {
      if (devicesResp.hasException == false) {
        var devicesArrDecoded = devicesResp.data["employee_device"];
        if (devicesArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              devices = devicesArrDecoded;
            });
          }
        }
        for (var device in devices) {
          if (this.widget.value == device["device_id"]) {
            startVal = device["deviceName"];
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
          'Device',
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
          items: devices.map<DropdownMenuItem<String>>((dynamic item) {
            var deviceName;
            if (item["deviceName"]?.isEmpty ?? true) {
              deviceName = "";
            } else {
              deviceName = item["deviceName"];
            }
            return DropdownMenuItem<String>(
              value: deviceName,
              child: Text(
                deviceName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: disabled
              ? null
              : (newValue) {
                  setState(() {
                    var setVal;
                    for (var device in devices) {
                      if (newValue == device["deviceName"]) {
                        setVal = device["device_id"];
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
        //     var deviceName;
        //     if (item["document"]?.isEmpty ?? true) {
        //       deviceName = "";
        //     } else {
        //       deviceName = item["document"]["deviceName"];
        //     }
        //     return DropdownMenuItem<String>(
        //       value: item["lead"],
        //       child: Text(
        //         deviceName,
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
