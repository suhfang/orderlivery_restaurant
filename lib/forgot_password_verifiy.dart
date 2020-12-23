


import 'package:Restaurant/forgot_passeord_change.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordVerifyPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationCode;
  final String email;

  ForgotPasswordVerifyPage(
      {this.phoneNumber, this.verificationCode, this.email});

  _ForgotPasswordVerifyPageState createState() =>
      _ForgotPasswordVerifyPageState();
}

class _ForgotPasswordVerifyPageState extends State<ForgotPasswordVerifyPage> {
  TextEditingController codeController = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter the verification code sent to the phone number ending in ${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              style: TextStyle(fontWeight: FontWeight.bold),
              controller: codeController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                helperText: ' ',
                contentPadding: EdgeInsets.only(left: 20, right: 0, bottom: 5),
                hintText: 'Enter code',
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
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Verification codes may take up to 10 minutes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                verifyCode(inputtedCode: codeController.text.trim());
              },
              child: Container(
                child: Center(
                  child: Text(
                    'Send',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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

  void verifyCode({String inputtedCode}) {
    if (inputtedCode == widget.verificationCode) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ForgotPasswordChangePage(
                    email: widget.email,
                  )));
    } else {
      Fluttertoast.showToast(msg: 'Incorrect verification code', backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
    }
  }
}
