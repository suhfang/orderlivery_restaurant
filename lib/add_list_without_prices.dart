
import 'package:Restaurant/add_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:line_icons/line_icons.dart';

class AddListWithoutPricesPage extends StatefulWidget {

  _AddListWithoutPricesPageState createState() => _AddListWithoutPricesPageState();
}


class _AddListWithoutPricesPageState extends State<AddListWithoutPricesPage> {

  String _title;
  String _description;

  List<ListItem> list_items = [];

  bool is_required = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add List without Prices'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
            child: Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text('Lists with no prices are perfect for things like wings, ice cream, or drinks that have multiple options included in the price. You can always add a price to these items too'),
                  SizedBox(height: 20,),
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
                        _title = value.trim();
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
                      _description = value.trim();
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
                  SizedBox(height: 10,),
                  Text('You can create a list of items. Ex: Flavors of Wings, Sauce, Dressing, etc.'),
                  SizedBox(height: 10,),
                  Expanded(
                      child: Stack(
                        children: [

                          GestureDetector(
                            onTap: () {
                              final act = CupertinoActionSheet(
                                  title: Text('Add List Item'),
                                  actions: <Widget>[
                                    CupertinoActionSheetAction(
                                      child: Text('Add List Item with Price ', style: TextStyle(color: Colors.blue),),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showNameAndPriceDialog();
                                      },
                                    ),
                                    CupertinoActionSheetAction(
                                      child: Text('Add List Item with name only', style: TextStyle(color: Colors.blue),),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showNameDialog();
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.orange)
                              ),
                              child: Center(
                                child: Text('ADD ITEM', style: TextStyle(color: Colors.orange),),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: list_items.length,
                                itemBuilder: (context, index) {
                                  ListItem item = list_items[index];
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Container(
                                        height: 50,
                                        child: ListTile(
                                          title: Text(item.name),
                                          subtitle: Text(item.price != null ? ('\$' + item.price) : ''),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                list_items.removeAt(index);
                                              });
                                            },
                                            child: Icon(LineIcons.trash),
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.bottomCenter,
                            child:  GestureDetector(
                              onTap: () {
                                ItemList data = ItemList(
                                    name: _title,
                                    description: _description,
                                    items: list_items,
                                    is_required: is_required
                                );
                                if (list_items.isNotEmpty) {
                                  Navigator.pop(context, data);
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange)
                                ),
                                child: Center(
                                  child: Text('CREATE LIST', style: TextStyle(color: Colors.white),),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                  )
                ],
              ),
            )
        ),
      ),
    );
  }

  ListItem _currentItem = ListItem();
  _showNameAndPriceDialog() async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          height: 125,
          child: Column(
            children: [
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      onChanged: (String value) {
                        _currentItem.name = value;
                      },
                      autofocus: true,
                      decoration: new InputDecoration(
                          labelText: 'List item name', hintText: 'Ex: Mild, Medium, Hot, Mega Hot'),
                    ),
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      onChanged: (String value) {
                        _currentItem.price = value;
                      },
                      autofocus: true,
                      decoration: new InputDecoration(
                          labelText: 'List item price', hintText: 'Ex: \$5.00'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('ADD'),
              onPressed: () {
                if (_currentItem.name.trim().isNotEmpty && _currentItem.price.trim().isNotEmpty) {
                  List<String> names = list_items.map((e) => e.name).toList();
                  if (!names.contains(_currentItem.name.trim())) {
                    setState(() {
                      list_items.add(_currentItem);
                    });
                  }
                  _currentItem = ListItem();
                }
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
  _showNameDialog() async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                onChanged: (String value) {
                  _currentItem.name = value;
                },
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'List item name', hintText: 'eg. Mild, Medium, Hot, Mega Hot'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('ADD'),
              onPressed: () {
                if (_currentItem.name.trim().isNotEmpty) {
                  List<String> names = list_items.map((e) => e.name).toList();
                  if (!names.contains(_currentItem.name.trim())) {
                    setState(() {
                      list_items.add(_currentItem);
                    });
                  }
                  _currentItem = ListItem();
                }

                Navigator.pop(context);
              })
        ],
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