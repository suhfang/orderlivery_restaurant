

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class EditListPage extends StatefulWidget {
  final String list_id;
  final bool first_required;
  int minimum_length;
  int maximum_length;
  EditListPage({this.list_id, this.first_required, this.maximum_length, this.minimum_length});
  _EditListPageState createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {

  int minimum_length;
  int maximum_length;
  TextEditingController minItemsController = TextEditingController();
  TextEditingController maxItemsController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    is_required = widget.first_required;
    minimum_length = widget.minimum_length;
    maximum_length = widget.maximum_length;
    minItemsController.text = '${widget.minimum_length}';
    maxItemsController.text = '${widget.maximum_length != null ? widget.maximum_length : ''}';
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
        child:  Form(
          key: _formKey,
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
                  is_required ? Container(
                    height: 70,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Minimum number of items',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            if (is_required && value.isNotEmpty && int.parse(value) < 1) {
                              return 'Minimum number of items should be greater than zero';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (String value) {
                            setState(() {
                              if (is_required) {
                                if (value.isEmpty) {
                                  minimum_length = 1;
                                } else {
                                  minimum_length = int.parse(value);
                                }
                              } else {
                                minimum_length = 0;
                              }
                            });
                          },
                          controller: minItemsController,
                        )
                      ],
                    ),
                  ) : SizedBox(),
                  is_required ? Container(
                    height: 70,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Maximum number of items',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            if (is_required && value.isNotEmpty && int.parse(value) < 1) {
                              return 'Maximum number of items should be greater than zero';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (String value) {
                            setState(() {
                              if (is_required) {
                                if (value.isEmpty) {
                                  maximum_length = 1;
                                } else {
                                  maximum_length = int.parse(value);
                                }
                              } else {
                                maximum_length = null;
                              }
                            });
                          },
                          controller: maxItemsController,
                        )
                      ],
                    ),
                  ) : SizedBox(),
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
          ),
        )
      ),
    );
  }

  void saveList()  {
    // if (_formKey.currentState.validate()) {
      Navigator.pop(context, {
        'is_required': is_required,
        'minimum_length': minimum_length,
        'maximum_length': maximum_length,
      });
    // }
  }
}

