
import 'dart:convert';

import 'package:Restaurant/add_list.dart';
import 'package:Restaurant/add_list_without_prices.dart';
import 'package:Restaurant/categories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'dart:math' as math;

import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComboItemPage extends StatefulWidget {
  _ComboItemPageState createState() => _ComboItemPageState();
}





//final _formKey = GlobalKey<FormState>();
class _ComboItemPageState extends State<ComboItemPage> {

  List<String> health_labels = [
    'Vegan', 'Vegetarian', 'Gluten Free', 'Halal', 'Kosher', 'Sugar-Free'
  ];
  List<String> items = [
    'Choose Category type',
    'Two'
  ];
  PricingType _character = PricingType.none;

  FocusNode descriptionNode = FocusNode();
  FocusNode flatPriceFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode cookingTimeFocusNode = FocusNode();
  FocusNode priceAndQuantityFocusNode = FocusNode();
  FocusNode startingFromFocusNode = FocusNode();
  FocusNode minutesFocusNode = FocusNode();


  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController flatPriceController = TextEditingController();
  TextEditingController priceAndQuantityController = TextEditingController();
  TextEditingController startingFromController = TextEditingController();
  TextEditingController cookingTimeController = TextEditingController();
  TextEditingController minutesController = TextEditingController();

  List<ItemList> lists = [];

  StepperType stepperType = StepperType.horizontal;
  int currentStep = 0;
  bool complete = false;

  StepState stepOneState = StepState.editing;
  bool stepOneActive = true;

  StepState stepTwoState = StepState.disabled;
  bool stepTwoActive = true;

  StepState stepThreeState = StepState.disabled;
  bool stepThreeActive = true;

  StepState stepFourState = StepState.disabled;
  bool stepFourActive = true;

  StepState stepFiveState = StepState.disabled;
  bool stepFiveActive = true;

  StepState stepSixState = StepState.disabled;
  bool stepSixActive = true;

  ImagePicker imagePicker = ImagePicker();

  bool isVegan = false;
  bool isVegetarian = false;
  bool isGlutenFree = false;
  bool isHalal = false;
  bool isKosher = false;
  bool isSugarFree = false;

  bool isEgg = false;
  bool isFish = false;
  bool isShellFish = false;
  bool isMilk = false;
  bool isPeanut = false;
  bool isSoy = false;
  bool isTreanut = false;
  bool isWheatOrGluten = false;


  String image_url = 'assets/images/menu.png';

  createMenuItem() {

  }

  next() {
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(nameFocusNode);
        return;
      }
      if (descriptionController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(descriptionNode);
        return;
      }
      if (_character == PricingType.none) {
        return;
      }
      if (_character == PricingType.flat_price) {
        if (flatPriceController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(flatPriceFocusNode);
          return;
        }
      }
      if (_character == PricingType.price_and_quantity) {
        if (priceAndQuantityController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(priceAndQuantityFocusNode);
          return;
        }
      }
      if (_character == PricingType.starting_from) {
        if (startingFromController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(startingFromFocusNode);
          return;
        }
      }
      setState(() {
        stepOneActive = true;
        stepOneState = StepState.complete;

        stepTwoActive = true;
        stepTwoState = StepState.editing;
      });
    }
    if (currentStep == 1) {
      if (dropdownValue.toLowerCase().contains('type')) {
        return;
      }
      if (minutesController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(minutesFocusNode);
        return;
      }
      setState(() {
        stepTwoActive = true;
        stepTwoState = StepState.complete;

        stepThreeActive = true;
        stepThreeState = StepState.editing;
        FocusScope.of(context).unfocus();
      });


    }
    if (currentStep == 2) {
      setState(() {
        stepThreeActive = true;
        stepThreeState = StepState.complete;

        stepFourActive = true;
        stepFourState = StepState.editing;
      });
    }
//    if (currentStep == 3) {
//      if (image_url == 'assets/images/menu.png') {
//        return;
//      }
//      setState(() {
//        stepFourActive = true;
//        stepFourState = StepState.complete;
//
//        stepFiveActive = true;
//        stepFiveState = StepState.editing;
//      });
//    }

    if (currentStep == 3) {
      setState(() {
        stepSixActive = true;
        stepSixState = StepState.complete;
      });
      createMenuItem();
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
      return;
    }
    currentStep + 1 !=  6 ? goTo(currentStep + 1) : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  @override
  initState() {
    super.initState();
    getCategories();
  }

  String dropdownValue = 'Choose Category type';
  @override
  Widget build(BuildContext context) {

    List<Step> steps = [
      Step(
          state: stepOneState,
          isActive: stepOneActive,
          title: Text('Item name, description and pricing type'),
          content:  Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What\'s the name of the item?'),
                    SizedBox(height: 5,),
                    Container(
                      alignment:
                      Alignment.topCenter,
                      child: _TextFormField(
                        focusNode: nameFocusNode,
                        inputFormatters: [],
                        hintText: 'Item name',
                        onChanged: (String value) {
//                          _formKey.currentState.validate();
                        },
                        controller: nameController,
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
                    SizedBox(height: 5,),
                    Text('How would you describe your item to customers?'),
                    SizedBox(height: 0,),
                    TextFormField(
                      onChanged: (String value) {
                      },
                      focusNode: descriptionNode,
                      controller: descriptionController,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          hintText: 'How would your describe this item to your customers?',
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
                    Text('Select a pricing type'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 40,
                          child:  ListTile(
                            title: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _character = PricingType.flat_price;
                                });
                              },
                              child: const Text('Flat Price'),
                            ),
                            leading: Radio(
                              value: PricingType.flat_price,
                              groupValue: _character,
                              onChanged: (PricingType value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          child: ListTile(
                            title: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _character = PricingType.price_and_quantity;
                                });
                              },
                              child: const Text('Price and Quantity'),
                            ),
                            leading: Radio(
                              value: PricingType.price_and_quantity,
                              groupValue: _character,
                              onChanged: (PricingType value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                            height: 40,
                            child: Center(
                              child: ListTile(
                                title: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _character = PricingType.starting_from;
                                    });
                                  },
                                  child: const Text('Starting from'),
                                ),
                                leading: Radio(
                                  value: PricingType.starting_from,
                                  groupValue: _character,
                                  onChanged: (PricingType value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )
                        ),
                        toggledPriceWidget(_character)
                      ],
                    ),
                  ]
              )
          )
      ),
      Step(
        state: stepTwoState,
        isActive: stepTwoActive,
        title: const Text('Category and Cooking Time'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(

                  value: dropdownValue,
                  icon: Icon(LineIcons.angle_down),
                  iconSize: 15,
                  elevation: 16,
                  style: TextStyle(color: Colors.black),
                  underline: Padding(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: Container(
                      height: 1,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: items
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 19),),
                    );
                  }).toList(),
                ),
              ),
              width: MediaQuery.of(context).size.width,
            ),
            SizedBox(height: 20,),
            Text('What\'s the average cooking time of this item?'),
            Row(
              children: [
                Text('Minutes: '),
                Expanded(
                  child:  _TextFormField(
                    focusNode: minutesFocusNode,
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    hintText: 'Average cooking time',
                  ),
                )
              ],
            )
          ],
        ),
      ),
      Step(
        state: stepThreeState,
        isActive: stepThreeActive,
        title: const Text('Add Menu Items'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('You can create of options. Ex: Flavors of Wings, Sauce, Dressings, etc.'),
            SizedBox(height: 15,),
            GestureDetector(
              onTap: () {
                final act = CupertinoActionSheet(
                    title: Text('What type of list do you want to create?'),
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        child: Text('List with Prices', style: TextStyle(color: Colors.blue),),
                        onPressed: () async {
                          Navigator.pop(context);
                          ItemList list = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddListWithPricePage()));
                          setState(() {
                            if (list != null) {
                              lists.add(list);
                            }
                          });
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: Text('List without Prices', style: TextStyle(color: Colors.blue),),
                        onPressed: () async {
                          Navigator.pop(context);
                          ItemList list = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddListWithoutPricesPage()));
                          setState(() {
                            if (list != null) {
                              lists.add(list);
                            }
                          });
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
                  child: Text('ADD LIST', style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text('Added ${lists.length} lists'),
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  ItemList item = lists[index];
                  return ListTile(
                    title: Text(item.name),
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() {
                          lists.removeAt(index);
                        });
                      },
                      child: Icon(LineIcons.trash),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      Step(
        state: stepFourState,
        isActive: stepFourActive,
        title: const Text('Upload a bright image of the menu item'),
        content: Column(
          children: <Widget>[
            Container(
              height: 200,
              child:  Image.asset(image_url, fit: BoxFit.cover,),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () async {
                final image = await imagePicker.getImage(source: ImageSource.gallery);
                if (image != null) {
//                  showDialog(
//                      context: context,
//                      barrierDismissible: false,
//                      builder: (BuildContext context) {
//                        return Dialog(
//                            backgroundColor: Colors.transparent,
//                            child: Column(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: [CircularProgressIndicator()],
//                            ));
//                      });
                  setState(() {
                    image_url = image.path;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                height: 50,
                child: Center(
                  child: Text('UPDATE PHOTO', style: TextStyle(color: Colors.orange),),
                ),
              ),
            ),
          ],
        ),
      ),
    ];



    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text('New Combo Menu Item', textAlign: TextAlign.center,),
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(0),
                child: Stepper(
                  currentStep: currentStep,
                  onStepContinue: next,
                  steps: steps,
                  onStepTapped: (step) => goTo(step),
                  onStepCancel: cancel,
                )
            )
        )
    );

  }

  switchStepType() {
    setState(() => stepperType == StepperType.horizontal  ? stepperType = StepperType.vertical  : stepperType = StepperType.horizontal);
  }

  Widget toggledPriceWidget(PricingType type) {
    if (type == PricingType.flat_price) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Text('Flat Price'),
          SizedBox(height: 10,),
          Row(
            children: [
              Text('\$ '),
              Expanded(
                child: _TextFormField(
                  hintText: 'Enter the price in USD',
                  controller: flatPriceController,
                  focusNode: flatPriceFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }
    if (type == PricingType.starting_from) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Text('Starting from Price'),
          SizedBox(height: 10,),
          Row(
            children: [
              Text('\$ '),
              Expanded(
                child: _TextFormField(
                  hintText: 'Enter the starting price',
                  controller: startingFromController,
                  focusNode: startingFromFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }
    if (type == PricingType.price_and_quantity) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Text('Enter quantities and prices separated by commas'),
          SizedBox(height: 10,),
          Container(
            height: 60,
            width: 250,
            child: Row(
              children: [
                Expanded(
                  child: _TextFormField(
                    hintText: '3 Pieces/\$5.00, 7 Pieces for \$10.00, 10 Pieces for \$15',
                    controller: priceAndQuantityController,
                    focusNode: priceAndQuantityFocusNode,
                    textInputAction: TextInputAction.done,
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox();
    }
  }

  void getCategories() async  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/get-categories',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        });
    Iterable categories = json.decode(response.body)['categories'];
    setState(() {
      items = ['Choose Category type'] + categories.map((e) =>  Category.fromJson(e)).toList().map((e) => e.name).toList();
    });
  }
}

List<String> titleList = ['Flat Price', 'Price and Quantity', 'Starting From'];
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


enum Healh_and_Safety_Labels {
  vegan, vegetarian, gluten_free, halal, kosher, sugar_free,
}


enum Allergens {
  egg, fish, shellfish, milk, peanut, soy, treenuts, wheat_or_gluten
}
