import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class DeviceDropDown extends StatefulWidget {
  final bool disabled;
  final Function callback;
  final String value;
  final String employee;

  DeviceDropDown({this.callback, this.value, this.disabled, this.employee});

  @override
  _DeviceDropDownState createState() => _DeviceDropDownState();
}

class _DeviceDropDownState extends State<DeviceDropDown> {
  var devices = [];
  var disabled;
  var startVal;

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output:
  );

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

  Future<void> initDevices() async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_DEVICES (\$employee: uuid!){
        employee_device(where: {employee: {_eq: \$employee}}){
          employee_device
            deviceName: document(path: "deviceName")
            device_id
          }
        }
      """),
      variables: {"employee": this.widget.employee},
    );

    final QueryResult devicesResp =
        await GqlClientFactory().authGqlquery(options);

    if (devicesResp != null) {
      if (devicesResp.hasException == false) {
        var devicesArrDecoded = devicesResp.data["employee_device"];
        if (devicesArrDecoded != null) {
          if (this.mounted) {
            logger.i("Devices dropdown loaded");
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
      } else {
        print("Error in DeviceDropdown: " + devicesResp.exception.toString());
        logger
            .e("Error in DeviceDropdown: " + devicesResp.exception.toString());
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
                    logger.i("Device changed: " + newValue);
                  });
                },
        )
      ],
    );
  }
}
