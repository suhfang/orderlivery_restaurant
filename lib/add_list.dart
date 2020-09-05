
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AddListWithPricePage extends StatefulWidget {

  _AddListWithPricePageState createState() => _AddListWithPricePageState();
}

class _AddListWithPricePageState extends State<AddListWithPricePage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add List with Prices'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You can create a list of items. Ex: Flavors of Wings, Sauce, Dressing, etc.'),
                  SizedBox(height: 20,),
                  Text('List name', style: TextStyle(fontSize: 19),),
                  SizedBox(height: 10,),
                  Container(
                    alignment:
                    Alignment.topCenter,
                    child: _TextFormField(
//                    focusNode: nameFocusNode,
                      inputFormatters: [],
                      hintText: 'Ex: Choose your Flavor, Pick a Topping, Choose Drink, etc.',
                      onChanged: (String value) {
//                          _formKey.currentState.validate();
                      },
//                    controller: nameController,
                      validator:
                          (String value) {
                        if (value.length < 1) {
                          return 'Enter the name of your menu';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text('Description', style: TextStyle(fontSize: 19),),
                  SizedBox(height: 10,),
                  TextFormField(
                    onChanged: (String value) {
                    },
//                  focusNode: descriptionNode,
//                  controller: descriptionController,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        hintText: 'Ex: Please choose at least one flavor in order to proceed',
                        hintMaxLines: 200, border: InputBorder.none,
                        disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(width: 0.3, color: Colors.orange)
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(width: 0.3, color: Colors.grey)
                        )),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  SizedBox(height: 30,),
                  GestureDetector(
                    onTap: () {
                      final act = CupertinoActionSheet(
                          title: Text('Add Item'),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text('Add Item with Price', style: TextStyle(color: Colors.blue),),
                              onPressed: () {
                                Navigator.pop(context);
//                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddListWithPricePage()));
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Add Item without Price', style: TextStyle(color: Colors.blue),),
                              onPressed: () {
                                Navigator.pop(context);
//                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddListWithoutPricesPage()));
                              },
                            )
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ));
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => act);

                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(
                        child: Text('ADD ITEM', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
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
  final FocusNode focusNode;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final Iterable<TextInputFormatter> inputFormatters;

  _TextFormField({
    this.hintText,
    this.validator,
    this.onSaved,
    this.isPassword = false,
    this.isEmail = false,
    this.controller,
    this.autofillHints,
    this.onChanged,
    this.inputFormatters,
    this.focusNode,
    this.enabled,
    this.keyboardType,
    this.textInputAction
  });


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
              enabled: enabled,
              textInputAction: textInputAction,
              focusNode: focusNode,
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
                  contentPadding: EdgeInsets.only(left: 10, right: 0, bottom: 5),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.3, color: Colors.grey)
                  )
              ),
              obscureText: isPassword ? true : false,
              keyboardType: keyboardType
          ),
        ));
  }
}
enum PricingType { flat_price, price_and_quantity, starting_from, none }

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue,
      ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}