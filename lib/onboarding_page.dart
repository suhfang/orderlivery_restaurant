import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class OnBoardingPage extends StatefulWidget {
  final String initialUrl;
  OnBoardingPage({this.initialUrl});
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

 bool isLoading=true;
  final _key = UniqueKey();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    request();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Payments Onboarding', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,

      ),
      body:Stack(
        children: <Widget>[
          WebView(
            key: _key,
            initialUrl: widget.initialUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading ? Center( child: SpinKitRing(color: Colors.orange, lineWidth: 2,) ,)
              : Stack(),
        ],
      ),
    );
  }

  void request() async {
    bool storage = Platform.isAndroid ? await Permission.storage.isGranted : await Permission.photos.isGranted;
    if (!storage) {
      Platform.isAndroid? await Permission.storage.request() : await Permission.photos.request();
      await Permission.mediaLibrary.request();
    }
  }
}
