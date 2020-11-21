
import 'dart:io';

import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeDashboardPage extends StatefulWidget {
  final String initialUrl;
  StripeDashboardPage({this.initialUrl});
  _StripeDashboardPageState createState() => _StripeDashboardPageState();
}

class _StripeDashboardPageState extends State<StripeDashboardPage> {

  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
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
      key: key,
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
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Share.share(widget.initialUrl);

                    },
                    child: Icon(LineIcons.share),
                  ),
                  SizedBox(width: 10,),
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