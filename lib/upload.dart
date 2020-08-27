

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
    return DrawerScaffold(
      appBar: AppBar(
        title: Text('Menu Upload'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:  Container(
            child: Column(
                children: [
                  Text('Please upload your menu here as a .csv file the use that to recreate your menu in our app. Once it\'s uploaded, you can edit it in the future, either by reuploading a new .csv or by editing the item.'),
                  InkWell(
                    onTap: () async {
                      File file  = await FilePicker.getFile(allowedExtensions: ['csv']);
                      print(file);
                    },
                    child: Container(
                        child:
                        Padding(
                          padding: EdgeInsets.all(50),
                          child: Column(
                            children: [
                              Icon(FontAwesomeIcons.fileUpload, size: 50, color: Colors.orange,),
                              SizedBox(height: 15,),
                              Text('SELECT FILE', style: TextStyle(fontSize: 20, color: Colors.orange),)
                            ],
                          ),
                        )

                    ),
                  )
                ],
            ),
          ),
        )
      ),
    );
  }
}