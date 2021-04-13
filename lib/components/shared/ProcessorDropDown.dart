import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class ProcessorDropDown extends StatefulWidget {
  final String processorId;
  final String value;
  final Function callback;
  final String role;
  final bool disabled;
  final bool displayClear;
  final String caption;

  ProcessorDropDown(
      {this.processorId,
      this.callback,
      this.value,
      this.role,
      this.disabled,
      this.displayClear = true,
      this.caption = "Processor"});

  @override
  _ProcessorDropDownState createState() => _ProcessorDropDownState();
}

class _ProcessorDropDownState extends State<ProcessorDropDown> {
  var processors = [];
  var disabled;
  var startVal;

  @override
  void initState() {
    super.initState();

    initProcessors();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  Future<void> initProcessors() async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_PROCESSORS {
        processor {
          processor
          name:document(path:"name")
        }
      }
    """),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var processorArrDecoded = result.data["processor"];
        if (processorArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              processors = processorArrDecoded;
            });
          }
        }
        for (var processor in processors) {
          if (this.widget.value == processor["processor"]) {
            startVal = processor["name"];
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
          this.widget.caption,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        SearchableDropdown.single(
          displayClearIcon: this.widget.displayClear,
          value: startVal,
          onClear: () {
            setState(() {
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          items: processors.map<DropdownMenuItem<String>>((dynamic item) {
            var processorName;
            if (item["name"]?.isEmpty ?? true) {
              processorName = "";
            } else {
              processorName = item["name"];
            }
            return DropdownMenuItem<String>(
              value: processorName,
              child: Text(
                processorName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: disabled
              ? null
              : (newValue) {
                  setState(() {
                    startVal = null;
                    var setVal;
                    if (newValue != null) {
                      for (var processor in processors) {
                        if (newValue == processor["name"]) {
                          setVal = processor["processor"];
                        }
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
