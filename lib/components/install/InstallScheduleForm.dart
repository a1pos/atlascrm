import 'dart:ui';
import 'package:logger/logger.dart';
import 'package:round2crm/components/install/InstallItem.dart';
import 'package:round2crm/components/shared/EmployeeDropDown.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:round2crm/services/UserService.dart';
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

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output: CustomOuput(),
  );

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
        if (installList["merchantbusinessname"] == "" ||
            installList["merchant"] == "") {
          logger.e("No merchant name or id");
          debugPrint("No merchant name or id");

          Fluttertoast.showToast(
            msg: "No merchant name or id!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          setState(() {
            installDateController.text = viewDate;
            employeeDropdownValue = UserService.isTech
                ? UserService.employee.employee
                : installList['employee'];
          });
          logger.i("Install schedule form opened for: " +
              installList["merchantbusinessname"] +
              " (" +
              installList["merchant"] +
              ")");

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  actions: <Widget>[
                    MaterialButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        logger.i("Install schedule form closed");
                        Navigator.pop(context);
                      },
                    ),
                    !isSaveDisabled
                        ? MaterialButton(
                            child: installList['date'] != null
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
                                await changeInstall(installList);
                              }
                            },
                          )
                        : Container(),
                  ],
                  title: Text(
                    installList["merchantbusinessname"],
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
                                    UserService.isSalesManager ||
                                    UserService.isCorporateTech
                                ? EmployeeDropDown(
                                    value: installList['employee'] ?? "",
                                    callback: (val) {
                                      setState(() {
                                        employeeDropdownValue = val;
                                      });
                                    },
                                    roles: ["tech", "corporate_tech"],
                                  )
                                : Container(),
                          ),
                          DateTimeField(
                            onEditingComplete: () =>
                                FocusScope.of(context).nextFocus(),
                            validator: (DateTime dateTime) {
                              if (dateTime == null) {
                                logger.i(
                                    "Attempted to schedule install without a date and time");
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
                                logger.i("Date selected for:install: " +
                                    DateTimeField.combine(date, time)
                                        .toString());
                                return DateTimeField.combine(date, time);
                              } else {
                                logger.i("Date selected for:install: " +
                                    currentValue.toString());
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
        }
      },
      child: InstallItem(
        merchant: installList["merchantbusinessname"],
        dateTime: this.widget.iDate ?? "TBD",
        merchantDevice: installList["merchantdevice"] ?? "No Terminal",
        employeeFullName: installList["employeefullname"] ?? "",
        location: installList["location"],
      ),
    );
  }

  Future<void> changeInstall(install) async {
    var installEmployee = employeeDropdownValue;
    var merchantName = install['merchantbusinessname'];
    var merchant = install['merchant'];
    var installID = install['install'];
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
        debugPrint("Loaded ticket status: " + ticketStatus.toString());
        logger.i("Loaded ticket status: " + ticketStatus.toString());
      } else {
        debugPrint("Error getting ticket status: " +
            ticketStatusResult.exception.toString());
        logger.e("Error getting ticket status: " +
            ticketStatusResult.exception.toString());
        Fluttertoast.showToast(
          msg: "Error getting ticket status: " +
              ticketStatusResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
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

        debugPrint("Ticket category loaded: " + ticketCategory.toString());
        logger.i("Ticket category loaded: " + ticketCategory.toString());
      } else {
        debugPrint("Error getting ticket category: " +
            ticketCategoryResult.exception.toString());
        logger.e("Error getting ticket category: " +
            ticketCategoryResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error getting ticket category: " +
              ticketCategoryResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
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
        "install": installID,
      },
    );

    final QueryResult installDocumentResult =
        await GqlClientFactory().authGqlquery(installDocumentOptions);

    if (installDocumentResult != null) {
      if (installDocumentResult.hasException == false) {
        install["document"] =
            installDocumentResult.data["install"][0]["document"];
        debugPrint("Install document loaded for: " + installID.toString());
        logger.i("Install document loaded for: " + installID.toString());

        if (installDocumentResult.data["install"][0]["ticket"] != null) {
          ticket = installDocumentResult.data["install"][0]["ticket"];
          debugPrint("Ticket previously created: " + ticket.toString());
          logger.i("Ticket previously created: " + ticket.toString());
        }
      } else {
        debugPrint("Error getting install document: " +
            installDocumentResult.exception.toString());
        logger.e("Error getting install document: " +
            installDocumentResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error getting install document: " +
              installDocumentResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    if (install["date"] == null || install['employee'] == null) {
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
        "install": installID,
      };

      confirmInstall(data, install);
    } else {
      data = {
        "install": installID,
        "employee": employeeDropdownValue,
        "date": installDateFormat,
        "ticket": ticket
      };
      updateInstall(data);
    }
  }

  void confirmInstall(data, install) async {
    var successMsg = "Install claimed and ticket created!";
    var msgLength = Toast.LENGTH_SHORT;
    var ticket;

    Map ticketComment = install["document"];

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

    if (updateInstallEmployeeByPKResult != null) {
      if (updateInstallEmployeeByPKResult.hasException == false) {
        debugPrint("Updated install employee by pk: " +
            data['employee'].toString() +
            " for: " +
            data['install']);
        logger.i("Updated install employee by pk: " +
            data['employee'].toString() +
            " for: " +
            data['install']);
      } else {
        debugPrint("Error updating install employee by pk: " +
            updateInstallEmployeeByPKResult.exception.toString());
        logger.e("Error updating install by pk: " +
            updateInstallEmployeeByPKResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating install by pk: " +
              updateInstallEmployeeByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (updateInstallDateByPKResult != null) {
      if (updateInstallDateByPKResult.hasException == false) {
        debugPrint("Updated install date by pk: " +
            data['date'].toString() +
            " for: " +
            data['install'].toString());
        logger.i("Updated install date by pk: " +
            data['date'].toString() +
            " for: " +
            data['install'].toString());
      } else {
        debugPrint("Error updating install date by pk: " +
            updateInstallDateByPKResult.exception.toString());
        logger.e("Error updating install by pk: " +
            updateInstallDateByPKResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating install by pk: " +
              updateInstallDateByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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
              is_active: \$is_active
              ticket_status: \$ticket_status
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

    if (insertTicketResult != null) {
      if (insertTicketResult.hasException == false) {
        debugPrint("Created new ticket: " +
            insertTicketResult.data["insert_ticket"]["returning"][0]["ticket"]
                .toString());
        logger.i("Created new ticket: " +
            insertTicketResult.data["insert_ticket"]["returning"][0]["ticket"]
                .toString());
      } else {
        debugPrint("Error creating new ticket: " +
            insertTicketResult.exception.toString());
        logger.e("Error creating new ticket: " +
            insertTicketResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error creating new ticket: " +
              insertTicketResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (insertAssigneeResult != null) {
      if (insertAssigneeResult.hasException == false) {
        debugPrint("Inserted ticket assignee: " +
            data['employee'].toString() +
            " for: " +
            ticket.toString());
        logger.i("Inserted ticket assignee: " +
            data['employee'].toString() +
            " for: " +
            ticket.toString());
      } else {
        debugPrint("Error inserting ticket assignee: " +
            insertAssigneeResult.exception.toString() +
            " for: " +
            ticket.toString());
        logger.e("Error inserting ticket assignee: " +
            insertAssigneeResult.exception.toString() +
            " for: " +
            ticket.toString());

        Fluttertoast.showToast(
          msg: "Error inserting ticket assignee: " +
              insertAssigneeResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (insertTicketMerchantResult != null) {
      if (insertTicketMerchantResult.hasException == false) {
        debugPrint("Inserted ticket merchant: " +
            data['merchant'].toString() +
            " for: " +
            ticket.toString());
        logger.i("Inserted ticket merchant: " +
            data['merchant'].toString() +
            " for: " +
            ticket.toString());
      } else {
        debugPrint("Error inserting ticket merchant: " +
            insertTicketMerchantResult.exception.toString() +
            " for: " +
            ticket.toString());
        logger.e("Error inserting ticket merchant: " +
            insertTicketMerchantResult.exception.toString() +
            " for: " +
            ticket.toString());

        Fluttertoast.showToast(
          msg: "Error inserting ticket merchant: " +
              insertTicketMerchantResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (insertTicketLabelResult != null) {
      if (insertTicketLabelResult.hasException == false) {
        debugPrint("Inserted ticket label: " +
            data['ticket_category'].toString() +
            " for: " +
            ticket.toString());
        logger.i("Inserted ticket label: " +
            data['ticket_category'].toString() +
            " for: " +
            ticket.toString());
      } else {
        debugPrint("Error inserting ticket label: " +
            insertTicketLabelResult.exception.toString() +
            " for: " +
            ticket.toString());
        logger.e("Error inserting ticket label: " +
            insertTicketLabelResult.exception.toString() +
            " for: " +
            ticket.toString());

        Fluttertoast.showToast(
          msg: "Error inserting ticket label: " +
              insertTicketLabelResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (updateInstallResult != null) {
      if (updateInstallResult.hasException == false) {
        debugPrint("Inserted ticket into install record: " +
            ticket.toString() +
            " for: " +
            data['install']);
        logger.i("Inserted ticket into install record: " +
            ticket.toString() +
            " for: " +
            data['install']);
      } else {
        debugPrint("Error inserting ticket into install record: " +
            updateInstallResult.exception.toString());
        logger.e("Error inserting ticket into install record: " +
            updateInstallResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error inserting ticket into install record: " +
              updateInstallResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    if (install['document'] != null) {
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
          "document": ticketComment,
          "ticket": ticket,
          "initial_comment": true,
        },
      );

      final QueryResult insertTicketCommentResult =
          await GqlClientFactory().authGqlmutate(insertTicketCommentOptions);

      if (insertTicketCommentResult != null) {
        if (insertTicketCommentResult.hasException == false) {
          debugPrint("Inserted initial ticket comment: " +
              ticketComment.toString() +
              " for: " +
              ticket.toString());
          logger.i("Inserted initial ticket comment: " +
              ticketComment.toString() +
              " for: " +
              ticket.toString());
        } else {
          debugPrint("Error inserting initial ticket comment: " +
              insertTicketCommentResult.exception.toString() +
              " for: " +
              ticket.toString());
          logger.e("Error inserting initial ticket comment: " +
              insertTicketCommentResult.exception.toString() +
              " for: " +
              ticket.toString());

          Fluttertoast.showToast(
            msg: "Error inserting initial ticket comment: " +
                insertTicketCommentResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
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

      if (updateInstallByPKResult != null) {
        if (updateInstallByPKResult.hasException == false) {
          debugPrint("Updated install to set ticket created to true for: " +
              data['install'].toString());
          logger.i("Updated install to set ticket created to true for: " +
              data['install'].toString());
        } else {
          debugPrint("Error updating install to set ticket to true: " +
              updateInstallByPKResult.exception.toString());
          logger.e("Error updating install to set ticket to true: " +
              updateInstallByPKResult.exception.toString());

          Fluttertoast.showToast(
            msg: "Error updating install to set ticket to true: " +
                updateInstallByPKResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
    debugPrint(successMsg);
    logger.i(successMsg);
    Fluttertoast.showToast(
      msg: successMsg,
      toastLength: msgLength,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );

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

    if (updateInstallDateByPKResult != null) {
      if (updateInstallDateByPKResult.hasException == false) {
        debugPrint("Updated install date to " +
            data['date'].toString() +
            " for: " +
            data['install']);
        logger.i("Updated install date to " +
            data['date'].toString() +
            " for: " +
            data['install']);
      } else {
        debugPrint("Error updating install date: " +
            updateInstallDateByPKResult.exception.toString());
        logger.e("Error updating install date: " +
            updateInstallDateByPKResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating install date: " +
              updateInstallDateByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (updateInstallEmployeeByPKResult != null) {
      if (updateInstallEmployeeByPKResult.hasException == false) {
        debugPrint("Updated install employee: " +
            data['employee'].toString() +
            " for: " +
            data['install'].toString());
        logger.i("Updated install employee: " +
            data['employee'].toString() +
            " for: " +
            data['install'].toString());
      } else {
        debugPrint("Error updating install employee: " +
            updateInstallEmployeeByPKResult.exception.toString());
        logger.e("Error updating install employee: " +
            updateInstallEmployeeByPKResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating install employee: " +
              updateInstallEmployeeByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (updateTicketDateByPKResult != null) {
      if (updateTicketDateByPKResult.hasException == false) {
        debugPrint("Updated ticket date: " +
            data['date'].toString() +
            " for: " +
            data['ticket'].toString());
        logger.i("Updated ticket date: " +
            data['date'].toString() +
            " for: " +
            data['ticket'].toString());
      } else {
        debugPrint("Error updating ticket date: " +
            updateTicketDateByPKResult.exception.toString());
        logger.e("Error updating ticket date: " +
            updateTicketDateByPKResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating ticket date: " +
              updateTicketDateByPKResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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

    if (updateTicketAssigneeResult != null) {
      if (updateTicketAssigneeResult.hasException == false) {
        debugPrint("Updated ticket assignee: " +
            data['employee'].toString() +
            " for: " +
            data['ticket'].toString());
        logger.i("Updated ticket assignee: " +
            data['employee'].toString() +
            " for: " +
            data['ticket'].toString());
      } else {
        debugPrint("Error updating ticket assignee: " +
            updateTicketAssigneeResult.exception.toString());
        logger.e("Error updating ticket assignee: " +
            updateTicketAssigneeResult.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating ticket assignee: " +
              updateTicketAssigneeResult.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    debugPrint(successMsg);
    logger.i(successMsg);
    Fluttertoast.showToast(
      msg: successMsg,
      toastLength: msgLength,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );

    isSaveDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return installForm(this.widget.viewDate, this.widget.installList);
  }
}
