

import 'dart:async';
import 'dart:convert';

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/init.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class SignupverificationPage extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String password;


  static int code = 0;
  static bool sentVerificationCode = false;
  SignupverificationPage({this.phoneNumber, this.firstName, this.lastName, this.email, this.password});
  _SignupverificationPageState createState() => _SignupverificationPageState();
}

class _SignupverificationPageState extends State<SignupverificationPage> {

  var onTapRecognizer;
  bool sentVerificationCode = false;
  final key = GlobalKey<ScaffoldState>();
  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        textEditingController.text = '';

        sendVerificationCode();
      };
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
    if (!SignupverificationPage.sentVerificationCode) {
      sendVerificationCode();
      SignupverificationPage.sentVerificationCode = true;
    }
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('PHONE VERIFICATION'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: GestureDetector(
        onTap: () {},
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30),
              // Container(
              //   height: MediaQuery.of(context).size.height / 3,
              //   child: FlareActor(
              //     "assets/otp.flr",
              //     animation: "otp",
              //     fit: BoxFit.fitHeight,
              //     alignment: Alignment.center,
              //   ),
              // ),
              SizedBox(height: 8),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //   child: Text(
              //     'Phone Number Verification',
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                      text: "Enter the code sent to ",
                      children: [
                        TextSpan(
                            text: widget.phoneNumber,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                      style: TextStyle(color: Colors.black54, fontSize: 15)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 30),
                    child: PinCodeTextField(
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obsecureText: false,
                      animationType: AnimationType.fade,
                      validator: (v) {
                        if (v != '${SignupverificationPage.code}') {
                          return "Incorrect verification code";
                        } else if (v.isEmpty) {
                          return "Enter the verification code";
                        } else {
                          return null;
                        }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor:
                        hasError ? Colors.orange : Colors.white,
                      ),
                      animationDuration: Duration(milliseconds: 300),
                      backgroundColor: Colors.white,
                      enableActiveFill: false,
                      errorAnimationController: errorController,
                      controller: textEditingController,
                      onCompleted: (v) {
                        print("Completed");
                      },
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? "*Please fill up all the cells properly" : "",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "Didn't receive the code? ",
                    style: TextStyle(color: Colors.purple, fontSize: 15),
                    children: [
                      TextSpan(
                          text: " RESEND",
                          recognizer: onTapRecognizer,
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))
                    ]),
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                margin:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      if(formKey.currentState.validate())
                        signup(context);
                    },
                    child: Center(
                        child: Text(
                          "VERIFY".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendVerificationCode() async {
    print('${SignupverificationPage.code}');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ));
        });
    final response = await http.post('${Constants.apiBaseUrl}/customers/send-sms', headers: {
      'Content-Type': 'application/json'
    },
        body: json.encode({
          'phone_number': widget.phoneNumber,
          'code': '${SignupverificationPage.code}'
        }));
    Navigator.pop(context);
    print(response.body);


  }

  void signup(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ));
        });
    const url = '${Constants.apiBaseUrl}/restaurants/signup';
    Map jsonMap = {
      'first_name': widget.firstName,
      'last_name': widget.lastName,
      'email': widget.email,
      'password': widget.password,
      'phone_number': widget.phoneNumber,
    };

    var body = json.encode(jsonMap);
    Future.delayed(Duration(seconds: 1), () async {
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        TokenResponse data = TokenResponse.fromJson(json.decode(response.body));
        if (data.token.isNotEmpty) {
          Navigator.pop(context);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data.token);
          prefs.setBool('is_restaurant', true);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => InitPage(),
              fullscreenDialog: true));
        }
      } else {
        Navigator.pop(context);
        if (response.body.contains('exists')) {
          final error = json.decode(response.body);
          scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              error['message'],
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ));
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(context);
          });
        }
      }
    });
  }
}