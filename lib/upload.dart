

import 'dart:io';

import 'package:Restaurant/drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class UploadPage extends StatefulWidget {
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('MENU UPLOAD'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),

            child: Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                height: 300,
                child: Column(
                  children: [
                    Text('Please upload your menu here as a .csv file the use that to recreate your menu in our app. Once it\'s uploaded, you can edit it in the future, either by reuploading a new .csv or by editing the item.',
                      style: TextStyle(fontSize: 15),),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        FilePickerResult result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['csv']
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child:  Container(
                            child:
                            Padding(
                              padding: EdgeInsets.all(30),
                              child: Column(
                                children: [
                                  Icon(FontAwesomeIcons.fileUpload, size: 50, color: Colors.orange,),
                                  SizedBox(height: 15,),
                                  Text('SELECT FILE', style: TextStyle(fontSize: 17, color: Colors.orange),)
                                ],
                              ),
                            )
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      );
  }
}