import 'package:fluttertoast/fluttertoast.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

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

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();

    initTypes();
  }

  Future<void> initTypes() async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query TASK_TYPES {
        task_type {
          task_type
          document
          parent
          title
        }
      }
    """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var taskTypesArrDecoded = result.data["task_type"];
        if (taskTypesArrDecoded != null) {
          setState(() {
            types = taskTypesArrDecoded;
          });
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Task types loaded for dropdown");
          });
        }
      } else {
        print("Error getting task types for dropdown: " +
            result.exception.toString());
        logger.e("Error getting task types for dropdown: " +
            result.exception.toString());

        Fluttertoast.showToast(
          msg: "Error getting task types for dropdown: " +
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
              Future.delayed(Duration(seconds: 1), () {
                logger.i("No task type selected for dropdown");
              });

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
            Future.delayed(Duration(seconds: 1), () {
              logger.i("Task type value changed in ");
            });

            this.widget.callback(newValue);
          },
        ),
      ],
    );
  }
}
