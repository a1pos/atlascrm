import 'dart:developer';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MileageScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();
  final StorageService storageService = new StorageService();

  @override
  _MileageScreenState createState() => _MileageScreenState();
}

class _MileageScreenState extends State<MileageScreen> {
  var isLoading = true;
  var isRunning = false;

  @override
  void initState() {
    super.initState();

    getInitialTripStatus();
  }

  Future<void> getInitialTripStatus() async {
    try {
      var storedStatus =
          await this.widget.storageService.read("isTechTripRunning");
      setState(() {
        isRunning = storedStatus.toLowerCase() == 'true';
      });
    } catch (err) {
      setState(() {
        isRunning = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> toggleTripStatus() async {
    try {
      setState(() {
        isLoading = true;
      });
      var status = !isRunning;

      if (status) {
        var resp = await this.widget.apiService.authPost(
            context, "/employee/${UserService.employee.employee}/trip", {});
        if (resp.statusCode == 200) {
          await this
              .widget
              .storageService
              .save("techTripId", resp.data.toString());
          setState(() {
            isRunning = status;
          });
        } else {
          Fluttertoast.showToast(
              msg: "Failed to set status!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
      } else {
        var trip = await this.widget.storageService.read("techTripId");
        if (trip != "") {
          var resp = await this
              .widget
              .apiService
              .authPost(context, "/employee/trip/$trip", {});
          if (resp.statusCode == 200) {
            setState(() {
              isRunning = status;
            });
          } else {
            Fluttertoast.showToast(
                msg: "Failed to set status!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }
        } else {
          Fluttertoast.showToast(
              msg: "Failed to set status!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
      }

      await this
          .widget
          .storageService
          .save("isTechTripRunning", status.toString());

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      await this.widget.storageService.delete("isTechTripRunning");
      await this.widget.storageService.delete("techTripId");
      setState(() {
        isLoading = false;
        isRunning = false;
      });
      log(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("mileageCustomAppBar"),
        title: Text("Mileage"),
      ),
      body: isLoading
          ? LoadingScreen()
          : Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  isRunning
                      ? Expanded(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Image(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      "https://media.giphy.com/media/l378BzHA5FwWFXVSg/giphy.gif"),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Image(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      "https://media.giphy.com/media/brHaCdJqCXijm/source.gif"),
                                ),
                              ),
                            ],
                          ),
                        ),
                  Expanded(
                    child: isRunning
                        ? MaterialButton(
                            height: MediaQuery.of(context).size.height / 2,
                            color: Colors.red[300],
                            onPressed: toggleTripStatus,
                            child: Text(
                              'STOP',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 10,
                              ),
                            ),
                          )
                        : MaterialButton(
                            height: MediaQuery.of(context).size.height / 2,
                            color: Colors.green[200],
                            onPressed: toggleTripStatus,
                            child: Text(
                              'START',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 10,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
