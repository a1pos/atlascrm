import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TaskTypeDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  TaskTypeDropDown({this.employeeId, this.callback, this.value});

  @override
  _TaskTypeDropDownState createState() => _TaskTypeDropDownState();
}

class _TaskTypeDropDownState extends State<TaskTypeDropDown> {
  var types = [];

  @override
  void initState() {
    super.initState();

    initTypes();
  }

  Future<void> initTypes() async {
    QueryOptions options = QueryOptions(
      documentNode: gql("""
      query TASK_TYPES {
        task_type {
          task_type
          document
          parent
          title
        }
      }
    """),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var taskTypesArrDecoded = result.data["task_type"];
        if (taskTypesArrDecoded != null) {
          setState(() {
            types = taskTypesArrDecoded;
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
                value: item["task_type"],
                child: Text('${item["title"]}'),
              );
            }

            return DropdownMenuItem<String>(
              value: item["task_type"],
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
