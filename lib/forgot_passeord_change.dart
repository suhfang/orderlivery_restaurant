import 'dart:convert';

import 'package:Restaurant/constants.dart' as Constants;
import 'package:Restaurant/home.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordChangePage extends StatefulWidget {
  final String email;

  ForgotPasswordChangePage({this.email});

  _ForgotPasswordChangePageState createState() =>
      _ForgotPasswordChangePageState();
}

class _ForgotPasswordChangePageState extends State<ForgotPasswordChangePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(

                    onChanged: (String value) {
                      formKey.currentState.validate();
                    },
                    validator: (String value) {
                      if (value.length < 8) {
                        return 'Password should be at least 8 characters';
                      } else {
                        return null;
                      }
                    },
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      helperText: ' ',
                      contentPadding: EdgeInsets.only(left: 20, right: 0, bottom: 5),
                      hintText: 'Enter new password',
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

                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (String value) {
                      formKey.currentState.validate();
                    },
                    validator: (String value) {
                      if (value.length < 8) {
                        return 'Password should be at least 8 characters';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      } else {
                        return null;
                      }
                    },
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: confirmPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      helperText: ' ',
                      contentPadding: EdgeInsets.only(left: 20, right: 0, bottom: 5),
                      hintText: 'Confirm password',
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
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                if (formKey.currentState.validate()) {
                  changePassword();
                }
              },
              child: Container(
                child: Center(
                  child: Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                height: 50,
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

  void changePassword() async {
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
                    SpinKitRing(
                      color: Colors.white,
                      size: 50.0,
                      lineWidth: 2,
                  )
                  ],
                )
            );
          });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    if (password == confirmPassword) {
      final response = await http.post(
          '${Constants.apiBaseUrl}/restaurant_locations/change-password',
          headers: {
            'Content-Type': 'application/json',
            'token': prefs.getString('token')
          },
          body: json.encode({'email': widget.email, 'password': password}));
      Navigator.pop(context);
      String token = json.decode(response.body)['token'] as String ?? null;
      if (token != null) {
        await prefs.setString('token', token);
        Fluttertoast.showToast(msg: 'Password was changed successfully', backgroundColor: Colors.orange, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });
      } else {
        Fluttertoast.showToast(msg: 'An error occurred changing your password', backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Fluttertoast.showToast(msg: 'Passwords do not match', backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
    }
  }
}
