

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/users.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class ProfilePage extends StatefulWidget {
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override

  String dropdownValue = 'Choose restaurant type';
  final _signUpFormKey = GlobalKey<FormState>();
  final signUpFirstNameController = TextEditingController();
  FocusNode _focus = new FocusNode();
  TextEditingController textController = new TextEditingController();

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('PROFILE'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Badge(
                badgeColor: Colors.orange,
                badgeContent: Text('3', style: TextStyle(color: Colors.white),),
                child:  Icon(LineIcons.bell),
              )
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment:
                Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                child: _TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(RegExp(
                        "[a-zA-Z]"))
                  ],
                  hintText: 'Restaurant name',
                  onChanged:
                      (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: signUpFirstNameController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your first name';
                    }
                    return null;
                  },
                  onSaved: (String value) {
//                                                  model.lastName = value;
                  },
                ),
              ),
              Container(
                alignment:
                Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                child: _TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(RegExp(
                        "[a-zA-Z]"))
                  ],
                  hintText: 'Description',
                  onChanged: (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: signUpFirstNameController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your first name';
                    }
                    return null;
                  },
                  onSaved: (String value) {
//                                                  model.lastName = value;
                  },
                ),
              ),
              Container(
                alignment:
                Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                child: _TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(RegExp(
                        "[a-zA-Z]"))
                  ],
                  hintText: 'Address',
                  onChanged: (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: signUpFirstNameController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your first name';
                    }
                    return null;
                  },
                  onSaved: (String value) {
//                                                  model.lastName = value;
                  },
                ),
              ),
              Container(
                alignment:
                Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                child: _TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(RegExp(
                        "[a-zA-Z]"))
                  ],
                  hintText: 'Phone Number',
                  onChanged: (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: signUpFirstNameController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your first name';
                    }
                    return null;
                  },
                  onSaved: (String value) {
//                                                  model.lastName = value;
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.black,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>['Choose restaurant type', 'One', 'Two', 'Free', 'Four']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 19),),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                color: Colors.white,
                child:  Text('ADD RESTAURANT TYPE', style: TextStyle(color: Colors.orange, fontSize: 19),),
                height: 50,
                width: MediaQuery.of(context).size.width,
              ),
              SizedBox(height: 20,),
              Text('HOURS', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  children: [
                    Text('MONDAY'),
                  ],
                ),
              )

            ],
          ),
        )
      ),
    );
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
//              border: InputBorder.none,
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