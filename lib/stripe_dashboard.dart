
import 'dart:io';

import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeDashboardPage extends StatefulWidget {
  final String initialUrl;
  StripeDashboardPage({this.initialUrl});
  _StripeDashboardPageState createState() => _StripeDashboardPageState();
}

class _StripeDashboardPageState extends State<StripeDashboardPage> {

 bool isLoading=true;
  final _key = UniqueKey();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

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
      backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
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
      key: key,
        body: Stack(
        children: <Widget>[
          WebView(
            key: _key,
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
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading ? Center( child: SpinKitRing(color: Colors.orange, lineWidth: 2,),)
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