import 'dart:ui';
import 'package:atlascrm/components/install/InstallItem.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class InstallScheduleForm extends StatefulWidget {
  final dynamic installList;
  final dynamic viewDate;
  final bool unscheduled;
  final dynamic iDate;

  InstallScheduleForm(this.installList, this.viewDate, this.iDate,
      {this.unscheduled});

  @override
  _InstallScheduleFormState createState() => _InstallScheduleFormState();
}

class _InstallScheduleFormState extends State<InstallScheduleForm> {
  final _formKey = GlobalKey<FormState>();

  bool isSaveDisabled;

  TimeOfDay initTime;
  DateTime initDate;

  Map data;

  var installDateController = TextEditingController();
  var employeeDropdownValue;

  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    initDate = DateTime.now();
    initTime = TimeOfDay.fromDateTime(initDate);
  }

  Widget installForm(viewDate, installList) {
    return GestureDetector(
      onTap: () {
        setState(() {
          installDateController.text = viewDate;
          employeeDropdownValue = UserService.isTech
              ? UserService.employee.employee
              : installList['employee'];
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  MaterialButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  !isSaveDisabled
                      ? MaterialButton(
                          child: this.widget.installList['date'] != null
                              ? Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                )
                              : Text(
                                  'Schedule',
                                  style: TextStyle(color: Colors.white),
                                ),
                          color: UniversalStyles.actionColor,
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                isSaveDisabled = true;
                              });
                              await changeInstall(this.widget.installList);
                            }
                          },
                        )
                      : Container(),
                ],
                title: Text(
                  this.widget.installList["merchantbusinessname"],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: UserService.isAdmin ||
                                  UserService.isSalesManager
                              ? EmployeeDropDown(
                                  value:
                                      this.widget.installList['employee'] ?? "",
                                  callback: (val) {
                                    setState(() {
                                      employeeDropdownValue = val;
                                    });
                                  },
                                )
                              : Container(),
                        ),
                        DateTimeField(
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          validator: (DateTime dateTime) {
                            if (dateTime == null) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          decoration:
                              InputDecoration(labelText: "Install Date"),
                          format: DateFormat("yyyy-MM-dd HH:mm"),
                          controller: installDateController,
                          initialValue: this.widget.unscheduled
                              ? null
                              : DateTime.parse(viewDate),
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? initDate,
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  currentValue ?? DateTime.now(),
                                ),
                              );
                              return DateTimeField.combine(date, time);
                            } else {
                              return currentValue;
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child: InstallItem(
        merchant: this.widget.installList["merchantbusinessname"],
        dateTime: this.widget.iDate ?? "TBD",
        merchantDevice:
            this.widget.installList["merchantdevice"] ?? "No Terminal",
        employeeFullName: this.widget.installList["employeefullname"] ?? "",
        location: this.widget.installList["location"],
      ),
    );
  }

  Future<void> changeInstall(i) async {
    var installEmployee = employeeDropdownValue;
    var merchantName = i['merchantbusinessname'];
    var merchant = i['merchant'];
    var install = i['install'];
    var ticketStatus;
    var ticketCategory;
    var ticket;

    var installDate = DateTime.parse(installDateController.text).toUtc();
    var installDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(installDate);

    QueryOptions options = QueryOptions(
      document: gql("""
        query TICKET_STATUS {
          ticket_status{
            ticket_status
            title
          }
        }
      """),
    );

    final QueryResult ticketStatusResult =
        await GqlClientFactory().authGqlquery(options);

    if (ticketStatusResult != null) {
      if (ticketStatusResult.hasException == false) {
        ticketStatusResult.data["ticket_status"].forEach((item) {
          if (item["title"] == "Scheduled For Install") {
            ticketStatus = item["ticket_status"];
          }
        });
      } else {
        print(new Error());
      }
    }

    QueryOptions ticketCategoryOptions = QueryOptions(
      document: gql("""
      query TICKET_CATEGORY{
        ticket_category{
          ticket_category
          title
        }
      }
    """),
    );

    final QueryResult ticketCategoryResult =
        await GqlClientFactory().authGqlquery(ticketCategoryOptions);

    if (ticketCategoryResult != null) {
      if (ticketCategoryResult.hasException == false) {
        ticketCategoryResult.data["ticket_category"].forEach((item) {
          if (item["title"] == "Install") {
            ticketCategory = item["ticket_category"];
          }
        });
      } else {
        print(new Error());
      }
    }

    QueryOptions installDocumentOptions = QueryOptions(
      document: gql("""
      query GET_INSTALL_DOC(\$install: uuid!){
        install(where: {install: {_eq: \$install}}) {
          document
          ticket
        }
      }
    """),
      variables: {
        "install": install,
      },
    );

    final QueryResult installDocumentResult =
        await GqlClientFactory().authGqlquery(installDocumentOptions);

    if (installDocumentResult != null) {
      if (installDocumentResult.hasException == false) {
        i["document"] = installDocumentResult.data["install"][0]["document"];

        if (installDocumentResult.data["install"][0]["ticket"] != null) {
          ticket = installDocumentResult.data["install"][0]["ticket"];
        }
      } else {
        print(new Error());
      }
    }

    if (i["date"] == null || i['employee'] == null) {
      data = {
        "ticket_status": ticketStatus,
        "ticket_category": ticketCategory,
        "document": {
          "title": "Installation: $merchantName",
        },
        "is_active": true,
        "employee": installEmployee,
        "date": installDateFormat,
        "merchant": merchant,
        "install": install,
      };

      confirmInstall(data, i);
    } else {
      data = {
        "install": install,
        "employee": employeeDropdownValue,
        "date": installDateFormat,
        "ticket": ticket
      };
      updateInstall(data);
    }
  }

  void confirmInstall(data, i) async {
    var successMsg = "Install claimed and ticket created!";
    var msgLength = Toast.LENGTH_SHORT;
    var ticket;

    MutationOptions updateInstallEmployeeByPKOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_INSTALL_EMPLOYEE_BY_PK(\$install: uuid!, \$employee: uuid!){
        update_install_by_pk(
          pk_columns: {install: \$install}
          _set: {employee: \$employee}
        ) {
          install
        }
      }
    """),
      variables: {
        "install": data["install"],
        "employee": data["employee"],
      },
    );

    final QueryResult updateInstallEmployeeByPKResult = await GqlClientFactory()
        .authGqlmutate(updateInstallEmployeeByPKOptions);

    if (updateInstallEmployeeByPKResult.hasException) {
      Fluttertoast.showToast(
          msg: updateInstallEmployeeByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions updateInstallDateByPKOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_INSTALL_DATE_BY_PK(\$install: uuid!, \$date: timestamptz!){
        update_install_by_pk(
          pk_columns: {install: \$install}
          _set: {date: \$date}
        ) {
          install
        }
      }
    """),
      variables: {
        "install": data["install"],
        "date": data["date"],
      },
    );

    final QueryResult updateInstallDateByPKResult =
        await GqlClientFactory().authGqlmutate(updateInstallDateByPKOptions);

    if (updateInstallDateByPKResult.hasException) {
      Fluttertoast.showToast(
          msg: updateInstallDateByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions insertTicketOptions = MutationOptions(
      document: gql("""
        mutation NEW_TICKET(
          \$document: jsonb!
          \$date: timestamptz!
          \$ticket_status: uuid!
          \$is_active: Boolean
        ) {
          insert_ticket(
            objects: {
              date: \$date
              document: \$document
              ticket_status: \$ticket_status
              is_active: \$is_active
            }
          ) {
            returning {
              ticket
            }
          }
        }
        """),
      variables: {
        "document": data["document"],
        "date": data["date"],
        "ticket_status": data["ticket_status"],
        "is_active": data["is_active"],
      },
    );

    final QueryResult insertTicketResult =
        await GqlClientFactory().authGqlmutate(insertTicketOptions);

    if (insertTicketResult.hasException) {
      Fluttertoast.showToast(
          msg: insertTicketResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    ticket = insertTicketResult.data["insert_ticket"]["returning"][0]["ticket"];

    MutationOptions insertAssigneeOptions = MutationOptions(
      document: gql("""
          mutation INSERT_TICKET_ASSIGNEE(\$ticket: uuid!, \$employee: uuid!){
            insert_ticket_assignee(
              objects: {ticket: \$ticket, employee: \$employee}
            ) {
              returning {
                ticket_assignee
              }
            }
          }
        """),
      variables: {
        "ticket": ticket,
        "employee": data["employee"],
      },
    );

    final QueryResult insertAssigneeResult =
        await GqlClientFactory().authGqlmutate(insertAssigneeOptions);

    if (insertAssigneeResult.hasException) {
      Fluttertoast.showToast(
          msg: insertAssigneeResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions insertTicketMerchantOptions = MutationOptions(
      document: gql("""
          mutation INSERT_TICKET_MERCHANT(\$merchant: uuid!, \$ticket: uuid!){
            insert_ticket_merchant(
              objects: {merchant: \$merchant, ticket: \$ticket}
            ){
              returning {
                ticket_merchant
              }
            }
          }
      """),
      variables: {
        "ticket": ticket,
        "merchant": data["merchant"],
      },
    );

    final QueryResult insertTicketMerchantResult =
        await GqlClientFactory().authGqlmutate(insertTicketMerchantOptions);

    if (insertTicketMerchantResult.hasException) {
      Fluttertoast.showToast(
          msg: insertTicketMerchantResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions insertTicketLabelOptions = MutationOptions(
      document: gql("""
          mutation INSERT_TICKET_LABEL(\$ticket_category: uuid!, \$ticket: uuid!){
            insert_ticket_label(
              objects: {ticket_category: \$ticket_category, ticket: \$ticket}
            ) {
              returning {
                ticket_label
              }
            }
          }
        """),
      variables: {
        "ticket": ticket,
        "ticket_category": data["ticket_category"],
      },
    );

    final QueryResult insertTicketLabelResult =
        await GqlClientFactory().authGqlmutate(insertTicketLabelOptions);

    if (insertTicketLabelResult.hasException) {
      Fluttertoast.showToast(
          msg: insertTicketMerchantResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions updateInstallOptions = MutationOptions(
      document: gql("""
          mutation UPDATE_INSTALL_BY_PK(\$install: uuid!, \$ticket: uuid!){
            update_install_by_pk(
              pk_columns: {install: \$install}
              _set: {ticket: \$ticket}
            ) {
              install
            }
          }
        """),
      variables: {
        "install": data["install"],
        "ticket": ticket,
      },
    );

    final QueryResult updateInstallResult =
        await GqlClientFactory().authGqlmutate(updateInstallOptions);

    if (updateInstallResult.hasException) {
      Fluttertoast.showToast(
          msg: updateInstallResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    if (this.widget.installList['document'] != null) {
      MutationOptions insertTicketCommentOptions = MutationOptions(
        document: gql("""
          mutation INSERT_TICKET_COMMENT(\$ticket: uuid!, \$document: jsonb!, \$initial_comment: Boolean!){
            insert_ticket_comment_one(
              object: {
                ticket: \$ticket,
                document: \$document,
                initial_comment: \$initial_comment
              }
            ) {
              ticket_comment
            }
          }
        """),
        variables: {
          "document": this.widget.installList["document"],
          "ticket": ticket,
          "initial_comment": true,
        },
      );

      final QueryResult insertTicketCommentResult =
          await GqlClientFactory().authGqlmutate(insertTicketCommentOptions);

      if (insertTicketCommentResult.hasException) {
        Fluttertoast.showToast(
            msg: updateInstallResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }

      MutationOptions updateInstallByPKOptions = MutationOptions(
        document: gql("""
          mutation UPDATE_INSTALL_BY_PK(\$install: uuid!, \$ticket_created: Boolean){
            update_install_by_pk (
              pk_columns: {install: \$install}
              _set: {ticket_created: \$ticket_created}
            ) {
              install
            }
          }
        """),
        variables: {
          "install": data["install"],
          "ticket_created": true,
        },
      );

      final QueryResult updateInstallByPKResult =
          await GqlClientFactory().authGqlmutate(updateInstallByPKOptions);

      if (updateInstallByPKResult.hasException) {
        Fluttertoast.showToast(
            msg: updateInstallResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
    Fluttertoast.showToast(
      msg: successMsg,
      toastLength: msgLength,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pop(context);
    isSaveDisabled = false;
  }

  void updateInstall(data) async {
    var successMsg = "Install Ticket Updated!";
    var msgLength = Toast.LENGTH_SHORT;

    MutationOptions updateInstallDateByPKOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_INSTALL_DATE_BY_PK(\$install: uuid!, \$date: timestamptz!){
        update_install_by_pk(
          pk_columns: {install: \$install}
          _set: {date: \$date}
        ) {
          install
        }
      }
    """),
      variables: {
        "install": data["install"],
        "date": data["date"],
      },
    );

    final QueryResult updateInstallDateByPKResult =
        await GqlClientFactory().authGqlmutate(updateInstallDateByPKOptions);

    if (updateInstallDateByPKResult.hasException) {
      print(updateInstallDateByPKResult);
      Fluttertoast.showToast(
          msg: updateInstallDateByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions updateInstallEmployeeByPKOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_INSTALL_DATE_BY_PK(\$install: uuid!, \$employee: uuid!){
        update_install_by_pk(
          pk_columns: {install: \$install}
          _set: {employee: \$employee}
        ) {
          install
        }
      }
    """),
      variables: {
        "install": data["install"],
        "employee": data["employee"],
      },
    );

    final QueryResult updateInstallEmployeeByPKResult = await GqlClientFactory()
        .authGqlmutate(updateInstallEmployeeByPKOptions);

    if (updateInstallEmployeeByPKResult.hasException) {
      Fluttertoast.showToast(
          msg: updateInstallEmployeeByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions updateTicketDateByPKOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_TICKET_DATE_BY_PK(\$ticket: uuid!, \$date: timestamptz!){
        update_ticket_by_pk(
          pk_columns: {ticket: \$ticket}
          _set: {date: \$date}
        ){
          date
        }
      }
    """),
      variables: {
        "ticket": data["ticket"],
        "date": data["date"],
      },
    );

    final QueryResult updateTicketDateByPKResult =
        await GqlClientFactory().authGqlmutate(updateTicketDateByPKOptions);

    if (updateTicketDateByPKResult.hasException) {
      Fluttertoast.showToast(
          msg: updateTicketDateByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    MutationOptions updateTicketAssigneeOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_TICKET_ASSIGNEE(\$ticket: uuid!, \$employee: uuid!) {
        update_ticket_assignee(
          where: { ticket: { _eq: \$ticket } }
          _set: { employee: \$employee }
        ) {
          returning {
            employee
          }
        }
      }
    """),
      variables: {
        "ticket": data["ticket"],
        "employee": data["employee"],
      },
    );

    final QueryResult updateTicketAssigneeResult =
        await GqlClientFactory().authGqlmutate(updateTicketAssigneeOptions);

    if (updateTicketAssigneeResult.hasException) {
      Fluttertoast.showToast(
          msg: updateTicketAssigneeResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    Fluttertoast.showToast(
        msg: successMsg,
        toastLength: msgLength,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);

    Navigator.pop(context);
    isSaveDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return installForm(this.widget.viewDate, this.widget.installList);
  }
}
