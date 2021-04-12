import 'package:Restaurant/contact.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  String appName;
  String packageName;
  String version;
  String buildNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateNumbers());
    updateNumbers();
  }

  void updateNumbers() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        packageName = packageInfo.packageName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'If you need to contact us for any reason, we\'d be glad to talk. You can reach us below through the following means:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: () {
                  launch('tel://+18174054865'); 
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+1 (817) 405 - 4865',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ContactPage()));
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(0xF1F1F1F1),
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                      child: Text(
                    '24/7 Live Chat',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  )),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  launch('tel://+18174054865');
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(0xF1F1F1F1),
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                      child: Text(
                    'Call Center',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  )),
                ),
              ),
              // SizedBox(
              //   height: 10,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     openMail();
              //   },
              //   child: Container(
              //     height: 40,
              //     decoration: BoxDecoration(
              //         color: Color(0xF1F1F1F1),
              //         borderRadius: BorderRadius.circular(30)),
              //     child: Center(
              //         child: Text(
              //       'Email Us',
              //       style: TextStyle(
              //           fontWeight: FontWeight.bold, color: Colors.black),
              //     )),
              //   ),
              // ),
              Expanded(
                  child: Container(
                      child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: Text(
                      'v$version ($buildNumber)',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )))
            ],
          ),
        ),
      )),
    );
  }
}

// void openMail() async {
//   final Email email = Email(
//     recipients: ['support@orderlivery.com'],
//     isHTML: false,
//   );
//   await FlutterEmailSender.send(email);
// }
