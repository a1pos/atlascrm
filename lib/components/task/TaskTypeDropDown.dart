import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class TaskTypeDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  TaskTypeDropDown({this.employeeId, this.callback, this.value});

  @override
  _TaskTypeDropDownState createState() => _TaskTypeDropDownState();
}

class _TaskTypeDropDownState extends State<TaskTypeDropDown> {
  final ApiService apiService = ApiService();

  var types = [];

  @override
  void initState() {
    super.initState();

    initTypes();
  }

  Future<void> initTypes() async {
    var taskTypesResp = await apiService.authGet(context, "/task/type");
    if (taskTypesResp != null) {
      if (taskTypesResp.statusCode == 200) {
        var taskTypesArrDecoded = taskTypesResp.data;
        if (taskTypesArrDecoded != null) {
          var temp = [];
          for (var item in taskTypesArrDecoded) {
            temp.add({
              "type": item["type"],
              "parent": item["parent"],
              "title": item["title"]
            });
          }

          setState(() {
            types = temp;
          });
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
          'Type',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        DropdownButtonFormField<String>(
          validator: (value) {
            if (value == null) {
              return 'Please select a task type';
            }
            return null;
          },
          isExpanded: true,
          value: this.widget.value,
          hint: Text("Please choose one"),
          items: types.map((dynamic item) {
            if (item["parent"] != null) {
              return DropdownMenuItem<String>(
                value: item["type"],
                child: Text('${item["title"]}'),
              );
            }

            return DropdownMenuItem<String>(
              value: item["type"],
              child: Text(
                '> ${item["title"]}',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            this.widget.callback(newValue);
          },
        ),
      ],
    );
  }
}
