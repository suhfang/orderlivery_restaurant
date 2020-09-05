

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class CreateCategoryPage extends StatefulWidget {
  _CreateCategoryPageState createState() => _CreateCategoryPageState();
}

class Category {
  String name;
  String id;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      id: json['_id'] as String
    );
  }
  Category({this.name, this.id});
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {

  TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {



    final formController = TextEditingController();
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('ADD CATEGORY'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child:  Container(
              height: MediaQuery.of(context).size.height-20,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [

                  Text('Enter the name of the category', style: TextStyle(color: Colors.black),),

                 Padding(
                   padding: EdgeInsets.only(top: 20),
                   child:  Form(
                     key: formKey,
                     child: Column(
                       children: [
                         _TextFormField(

                           hintText: 'For example Appetizers, or Entrees',
                           onChanged:
                               (String value) {
                             formKey
                                 .currentState
                                 .validate();
                           },
                           controller: controller,
                           validator:
                               (String value) {
                             if (value.length < 2) {
                               return 'Enter category name';
                             }
                             return null;
                           },
                           onSaved: (String value) {
//                                                  model.lastName = value;
                           },
                         ),
                       ],
                     ),
                   ),
                 ),

                  Stack(
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child:  GestureDetector(
                                onTap: () async {
                                  createCategory();
//                        String added = await Navigator.push(context, MaterialPageRoute(
//                            builder: (BuildContext context) =>
////                                AddLocationPage()));
//                        print(added);
//                        if (added == 'added') {
//                          setState(() {
////                            getLocations();
//                          });
//                        }
                                },

                                child: Container(
                                  height: 70,
                                  child: Column(
                                    children: [

                                      SizedBox(height: 10,),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        height: 50,

                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width - 50,
                                        child: Center(
                                          child: Text('SAVE CATEGORY', style: TextStyle(

//                                        fontWeight: FontWeight.bold,
                                              color: Colors.white),),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              )
          ),
        ),
      )
    );
  }

  void createCategory() async {
    if (controller.text.trim().isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post('${Constants.apiBaseUrl}/restaurants/add-category', headers: {
        'token': prefs.getString('token'),
        'Content-Type': 'application/json'
      },
          body: json.encode({
            'name': controller.text.trim(),

          }));
      Navigator.pop(context, 'added');
    }
  }
}

class _TextFormField extends StatelessWidget {

  final String hintText;
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;
  final Iterable<String> autofillHints;
  final TextEditingController controller;
  final Function onChanged;
  final Iterable<TextInputFormatter> inputFormatters;

  _TextFormField(
      {this.hintText,
        this.validator,
        this.onSaved,
        this.isPassword = false,
        this.isEmail = false,
        this.controller,
        this.autofillHints,
        this.onChanged,
        this.inputFormatters});


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
          ),
          child: TextFormField(
            textCapitalization: TextCapitalization.none,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            autofillHints: autofillHints,
            style: TextStyle(fontSize: 20),
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              helperText: ' ',
              hintText: hintText,
              contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 5),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 0.3, color: Colors.grey)
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: isPassword ? true : false,
            keyboardType:
            isEmail ? TextInputType.emailAddress : TextInputType.text,
          ),
        ));
  }
}