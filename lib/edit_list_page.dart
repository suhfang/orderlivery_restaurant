

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class EditListPage extends StatefulWidget {
  final String list_id;
  final bool first_required;
  EditListPage({this.list_id, this.first_required});
  _EditListPageState createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {


  @override
  void initState() {
    is_required = widget.first_required;
    print(is_required);
    print(widget.list_id);
  }
  bool is_required;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('EDIT LIST'),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                value: is_required,
                onChanged: (bool value) {
                  setState(() {
                    is_required = value;
                  });
                },
                title: Text('Required', style: TextStyle(fontSize: 19),),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  saveList();
                },
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text('SAVE LIST', style: TextStyle(color: Colors.white),),
                  ),
                ),
              )
            ],

          )
        )
      ),
    );
  }

  void saveList()  {
    Navigator.pop(context, is_required);
  }
}

