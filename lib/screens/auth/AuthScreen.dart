import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

class AuthScreen extends StatefulWidget {
  final UserService userService = new UserService();

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output:
  );

  @override
  void initState() {
    super.initState();

    isLoading = false;
  }

  void handleLogin() async {
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
        Navigator.of(context).pushReplacementNamed("/dashboard");
      } else {
        logger.e("ERROR on handleLogin");
        throw ('ERROR');
      }
    } catch (err) {
      logger.e(err);
      setState(() {
        isLoading = false;
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
                              text: "ATLAS",
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
                                  image: AssetImage("assets/a1logo_blk.png"),
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
