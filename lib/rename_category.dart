

import 'dart:convert';

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/categories.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as Constants;

class RenameCategoryPage extends StatefulWidget {
  final Category category;

  RenameCategoryPage({
    this.category
  });
_RenameCategoryPageState createState() => _RenameCategoryPageState();
}

class _RenameCategoryPageState extends State<RenameCategoryPage> {

  
  

  TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override 
  void initState() {
    super.initState();
    controller.text = widget.category.name;
  }
  @override
  Widget build(BuildContext context) {



    final formController = TextEditingController();
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('Renaming ${widget.category.name}'),
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

                  Text('Enter the new name of the ${widget.category.name} category', style: TextStyle(color: Colors.black),maxLines: 2, overflow: TextOverflow.clip,),

                 Padding(
                   padding: EdgeInsets.only(top: 20),
                   child:  Form(
                     key: formKey,
                     child: Column(
                       children: [
                         TTextFormField(

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
                                  renameCategory();
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
                                          child: Text('RENAME CATEGORY', style: TextStyle(

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

  Future<void> renameCategory() async {
    if (controller.text.trim().isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post('${Constants.apiBaseUrl}/restaurants/rename-category', headers: {
        'token': prefs.getString('token'),
        'Content-Type': 'application/json'
      },
          body: json.encode({
            'name': controller.text.trim(),
            'category_id': widget.category.id

          }));
      Navigator.pop(context, 'added');
    }
  }
}