import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnBoardingPage extends StatefulWidget {
  final String initialUrl;
  OnBoardingPage({this.initialUrl});
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: Colors.orange, size: 15,),
              SizedBox(width: 10,),
              Expanded(
                child: Text(widget.initialUrl.split('/express')[0] + '...', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
              )
            ],
          ),
        )
      ),
      body: WebView(
        initialUrl: widget.initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          if (request.url.contains('orderlivery.com')) {
            Navigator.pop(context);
            Navigator.pop(context);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      )
    );
  }
}