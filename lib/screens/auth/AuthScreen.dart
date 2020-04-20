import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthScreen extends StatefulWidget {
  final UserService userService = new UserService();

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;

  TextEditingController _userHandleController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    _userHandleController.text = "jordan";
    _passwordController.text = "asdf";

    isLoading = false;
  }

  void handleLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      var succeeded = await this.widget.userService.signInWithGoogle(context);
      if (succeeded) {
        var resp = await this.widget.userService.linkGoogleAccount();
        if (resp.statusCode == 200) {
          var isAuthed =
              await this.widget.userService.authorizeEmployee(context);
          if (isAuthed) {
            Navigator.of(context).pushNamed("/dashboard");
          }
        } else {
          throw ('ERROR');
        }
      } else {
        throw ('ERROR');
      }
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Failed to connect!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen()
        : Scaffold(
            body: Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                      image: AssetImage("assets/a1logo_blk.png"), height: 80.0),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                  ),
                  Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(50, 25, 50, 25),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 25, 0, 50),
                              child: Text(
                                'Atlas CRM',
                                style: TextStyle(
                                    fontSize: 22, fontFamily: 'LatoLight'),
                              ),
                            ),
                            OutlineButton(
                              splashColor: Colors.green,
                              onPressed: handleLogin,
                              highlightElevation: 0,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                        image: AssetImage(
                                            "assets/google_logo.png"),
                                        height: 30.0),
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
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
