import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContactPage extends StatefulWidget {
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  bool isLoading = true;
  final _key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            'Contact Us',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(LineIcons.close),
          )),
      body: Stack(
        children: <Widget>[
          WebView(
            key: _key,
            initialUrl: 'http://orderlivery.com/contact/',
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: SpinKitRing(
                    color: Colors.orange,
                    lineWidth: 2,
                    duration: Duration(milliseconds: 600),
                  ),
                )
              : Stack(),
        ],
      ),
    );
  }
}
