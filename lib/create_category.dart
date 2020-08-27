

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateCategoryPage extends StatefulWidget {
  _CreateCategoryPageState createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {


  @override
  Widget build(BuildContext context) {


    final formKey = GlobalKey<FormState>();
    final formController = TextEditingController();
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Category'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child:  Container(
          alignment:
          Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(RegExp(
                        "[a-zA-Z]"))
                  ],
                  hintText: 'Category name',
                  onChanged:
                      (String value) {
                    formKey
                        .currentState
                        .validate();
                  },
                  controller: formController,
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
              ],
            ),
          )
        ),
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