import 'dart:convert';
import 'dart:math';

import 'package:Restaurant/constants.dart' as Constants;
import 'package:Restaurant/forgot_password_verifiy.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  int code;

  void initState() {
    super.initState();
    code = generateRandom();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(fontWeight: FontWeight.bold),),
        shadowColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'To reset your password, enter the account email and we will send a phone verification to the phone number associated with the account if it exists',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 65,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: TextFormField(

                controller: emailController,
                autofillHints: [AutofillHints.email],
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  helperText: ' ',
                  contentPadding: EdgeInsets.only(left: 20, right: 0, bottom: 5),
                  hintText: 'Email',
                  filled: true,
                  fillColor: Color(0xfff3f3f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                if (emailController.text.trim().isNotEmpty) {
                  sendCode(email: emailController.text.trim());
                }
              },
              child: Container(
                child: Center(
                  child: Text(
                    'Send',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                height: 45,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        ),
      )),
    );
  }

  int generateRandom() {
    var rnd = new Random();
    var next = rnd.nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }
    return next.toInt();
  }

  void sendCode({String email}) async {
   showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitThreeBounce(
                      color: Colors.white,
                      size: 50.0,
                  )
                  ],
                )
            );
          });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        '${Constants.apiBaseUrl}/restaurant_locations/find-restaurant-with-email',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode({'email': email, 'code': '$code'}));
    var data = json.decode(response.body);
    var phone_number = data['phone_number'] as String ?? null;
    if (phone_number != null) {
      Future.delayed(Duration(seconds: 1), () {
        if (phone_number != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ForgotPasswordVerifyPage(
                        email: email,
                        phoneNumber: phone_number,
                        verificationCode: '$code',
                      )));
        } else {
          Fluttertoast.showToast(msg: 'Could not find the email $email in our database', backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
        }
      });
    } else {
      Fluttertoast.showToast(msg: 'Could not find any account associated with the email $email', backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
    }
    Navigator.pop(context);
    var phoneNumber = '2149187649';
    var verificationCode = '$code';
  }
}
