import 'package:round2crm/components/shared/LoadingScreen.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class AuthScreen extends StatefulWidget {
  final UserService userService = new UserService();

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();

    isLoading = false;
  }

  void handleLogin() async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("User attempting to login");
    });

    setState(() {
      isLoading = true;
    });

    try {
      var succeeded = await this.widget.userService.signInWithGoogle();
      if (succeeded) {
        setState(() {
          isLoading = false;
          UserService.isAuthenticated = true;
        });
        Future.delayed(Duration(seconds: 1), () {
          logger.i("User successfully logged in using Google");
        });

        Navigator.of(context).pushReplacementNamed("/dashboard");
      } else {
        Future.delayed(Duration(seconds: 1), () {
          logger.e("ERROR: ERROR on handleLogin");
        });

        throw ('ERROR');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });

      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Failed to connect: " + err.toString());
      });

      Fluttertoast.showToast(
        msg: "Failed to connect!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen()
        : WillPopScope(
            onWillPop: () {
              return Future(() => false);
            },
            child: Scaffold(
              body: Container(
                color: UniversalStyles.themeColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          style: TextStyle(fontSize: 38),
                          children: <TextSpan>[
                            TextSpan(
                              text: "ROUND2",
                              style: TextStyle(fontFamily: "InterBold"),
                            ),
                            TextSpan(
                              text: "CRM",
                              style: TextStyle(fontFamily: "InterLight"),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                    ),
                    Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(50, 25, 50, 25),
                          child: Column(
                            children: <Widget>[
                              Image(
                                  image: AssetImage("assets/r2logo_blk.png"),
                                  height: 80.0),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 40, 0, 20),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.green,
                                  ),
                                  onPressed: handleLogin,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image(
                                            image: AssetImage(
                                              "assets/google_logo.png",
                                            ),
                                            height: 30.0),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            'Sign in with Google',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
