
import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/add_list.dart';
import 'package:Restaurant/add_list_without_prices.dart';
import 'package:Restaurant/categories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'dart:math' as math;

import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComboItemPage extends StatefulWidget {
  _ComboItemPageState createState() => _ComboItemPageState();
}

Category chooseCategory = Category(name: 'Choose Category type');

class _ComboItemPageState extends State<ComboItemPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Category dropdownValue = chooseCategory;
  List<Category> items = [chooseCategory, Category(name: 'Two')];
  List<Item> menuItems = [];
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
  List<String> added_ids = [];
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
  bool isTreenuts = false;
  bool isWheatOrGluten = false;
  String imageUrl = 'assets/images/menu.png';
  File imageFile;

  Future<void> createFlatPriceMenu() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String price = flatPriceController.text.trim();
    String cookingTime = minutesController.text.trim();
    String category_id = dropdownValue.id;
    List _lists = lists.map((itemList) => {
      'name': itemList.name,
      'description': itemList.description,
      'is_required': itemList.is_required,
      'items': itemList.items.map((item) =>
      {
        'name': item.name,
        'price': item.price != null ? double.parse(item.price) : item.price
      }).toList()
    }).toList();
    List<String> labels = [];
    if (isVegan) {
      labels.add('Vegan');
    }
    if (isVegetarian) {
      labels.add('Vegetarian');
    }
    if (isGlutenFree) {
      labels.add('Gluten Free');
    }
    if (isHalal) {
      labels.add('Halal');
    }
    if (isKosher) {
      labels.add('Kosher');
    }
    if (isSugarFree) {
      labels.add('Sugar Free');
    }
    List<String> allergens = [];
    if (isEgg) {
      allergens.add('Egg');
    }
    if (isFish) {
      allergens.add('Fish');
    }
    if (isShellFish) {
      allergens.add('ShellFish');
    }
    if (isMilk) {
      allergens.add('Milk');
    }
    if (isPeanut) {
      allergens.add('Peanut');
    }
    if (isSoy) {
      allergens.add('Soy');
    }
    if (isTreenuts) {
      allergens.add('Treenuts');
    }
    if (isWheatOrGluten) {
      allergens.add('Wheat');
      allergens.add('Gluten');
    }
    var _json = {
      'name': name,
      'description': description,
      'flat_price': double.parse(price),
      'category_id': category_id,
      'lists': _lists,
      'health_labels': labels,
      'allergens': allergens,
      'individual_items': added_ids
    };
    if (imageFile != null) {
      _json['base64'] = base64Encode(imageFile.readAsBytesSync().cast<int>());
    }
    if (cookingTime.isNotEmpty) {
      _json['cooking_time'] = cookingTime;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/create-menu',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode(_json));
    print(response.body);
  }

  bool validatePricesAndQuantities() {
    String price_and_quantity_text = priceAndQuantityController.text.trim();
    List<String> pq = price_and_quantity_text.split(',');
    if (pq.isEmpty) return false;

    try {
      pq.map((e) {
        e = e.trim();
        double quantity = double.parse(e.split('/')[0].split(' ')[0]);
        String measurement_label = e.split('/')[0].split(' ')[1];
        String k = e.split('/')[1];
        String price = k.substring(1, k.length);
        return {
          'quantity': quantity,
          'measurement_label': measurement_label,
          'price': price
        };
      }).toList();
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<void> createPriceAndQuantityMenu() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    List pq = priceAndQuantityController.text.trim().split(', ');
    if (!validatePricesAndQuantities()) {
      setState(() {
        currentStep = 0;
        stepOneActive = true;
        stepOneState = StepState.editing;
        FocusScope.of(context).requestFocus(priceAndQuantityFocusNode);
      });
      return;
    }
    List prices_and_quantities = pq.map((e) {
      double quantity = double.parse(e.split('/')[0].split(' ')[0]);
      String measurement_label = e.split('/')[0].split(' ')[1];
      String k = e.split('/')[1];
      String price = k.substring(1, k.length);
      return {
        'quantity': quantity,
        'measurement_label': measurement_label,
        'price': price
      };
    }).toList();
    String cookingTime = minutesController.text.trim();
    String category_id = dropdownValue.id;
    List _lists = lists.map((itemList) => {
      'name': itemList.name,
      'description': itemList.description,
      'is_required': itemList.is_required,
      'items': itemList.items.map((item) =>
      {
        'name': item.name,
        'price': item.price != null ? double.parse(item.price) : item.price
      }).toList()
    }).toList();
    List<String> labels = [];
    if (isVegan) {
      labels.add('Vegan');
    }
    if (isVegetarian) {
      labels.add('Vegetarian');
    }
    if (isGlutenFree) {
      labels.add('Gluten Free');
    }
    if (isHalal) {
      labels.add('Halal');
    }
    if (isKosher) {
      labels.add('Kosher');
    }
    if (isSugarFree) {
      labels.add('Sugar Free');
    }
    List<String> allergens = [];
    if (isEgg) {
      allergens.add('Egg');
    }
    if (isFish) {
      allergens.add('Fish');
    }
    if (isShellFish) {
      allergens.add('ShellFish');
    }
    if (isMilk) {
      allergens.add('Milk');
    }
    if (isPeanut) {
      allergens.add('Peanut');
    }
    if (isSoy) {
      allergens.add('Soy');
    }
    if (isTreenuts) {
      allergens.add('Treenuts');
    }
    if (isWheatOrGluten) {
      allergens.add('Wheat');
      allergens.add('Gluten');
    }
    var _json = {
      'name': name,
      'description': description,
      'quantities_and_prices': prices_and_quantities,
      'category_id': category_id,
      'lists': _lists,
      'health_labels': labels,
      'allergens': allergens,
      'individual_items': added_ids
    };
    if (imageFile != null) {
      _json['base64'] = base64Encode(imageFile.readAsBytesSync().cast<int>());
    }
    if (cookingTime.isNotEmpty) {
      _json['cooking_time'] = cookingTime;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/create-menu',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode(_json));
    print(response.body);
  }

  Future<void> createStartingFromMenu() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String price = startingFromController.text.trim();
    String cookingTime = minutesController.text.trim();
    String category_id = dropdownValue.id;
    List _lists = lists.map((itemList) => {
      'name': itemList.name,
      'description': itemList.description,
      'is_required': itemList.is_required,
      'items': itemList.items.map((item) =>
      {
        'name': item.name,
        'price': item.price != null ? double.parse(item.price) : item.price
      }).toList()
    }).toList();
    List<String> labels = [];
    if (isVegan) {
      labels.add('Vegan');
    }
    if (isVegetarian) {
      labels.add('Vegetarian');
    }
    if (isGlutenFree) {
      labels.add('Gluten Free');
    }
    if (isHalal) {
      labels.add('Halal');
    }
    if (isKosher) {
      labels.add('Kosher');
    }
    if (isSugarFree) {
      labels.add('Sugar Free');
    }
    List<String> allergens = [];
    if (isEgg) {
      allergens.add('Egg');
    }
    if (isFish) {
      allergens.add('Fish');
    }
    if (isShellFish) {
      allergens.add('ShellFish');
    }
    if (isMilk) {
      allergens.add('Milk');
    }
    if (isPeanut) {
      allergens.add('Peanut');
    }
    if (isSoy) {
      allergens.add('Soy');
    }
    if (isTreenuts) {
      allergens.add('Treenuts');
    }
    if (isWheatOrGluten) {
      allergens.add('Wheat');
      allergens.add('Gluten');
    }
    var _json = {
      'name': name,
      'description': description,
      'starting_price': double.parse(price),
      'category_id': category_id,
      'lists': _lists,
      'health_labels': labels,
      'allergens': allergens,
      'individual_items': added_ids
    };

    if (imageFile != null) {
      _json['base64'] = base64Encode(imageFile.readAsBytesSync().cast<int>());
    }
    if (cookingTime.isNotEmpty) {
      _json['cooking_time'] = cookingTime;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/create-menu',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode(_json));
    print(response.body);
  }

  createMenuItem() async {
    if (_character == PricingType.flat_price) {
      print(added_ids);
      await createFlatPriceMenu();
    }
    if (_character == PricingType.price_and_quantity) {
      await createPriceAndQuantityMenu();
    }
    if (_character == PricingType.starting_from) {
      await createStartingFromMenu();
    }
  }

  next() async {
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(nameFocusNode);
        return;
      }
//      if (descriptionController.text.trim().isEmpty) {
//        FocusScope.of(context).requestFocus(descriptionNode);
//        return;
//      }
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
        if (!validatePricesAndQuantities()) {
          setState(() {
            currentStep = 0;
            stepOneActive = true;
            stepOneState = StepState.editing;
            FocusScope.of(context).requestFocus(priceAndQuantityFocusNode);
          });
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
      if (dropdownValue.name.toLowerCase().contains('type')) {
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
      if (added_ids.length < 2) {
        return;
      }
      setState(() {
        stepThreeActive = true;
        stepThreeState = StepState.complete;

        stepFourActive = true;
        stepFourState = StepState.editing;
      });
    }
    if (currentStep == 3) {
      setState(() {
        stepSixActive = true;
        stepSixState = StepState.complete;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
                backgroundColor: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ));
          });
      await createMenuItem();
      Navigator.pop(context);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context, 'created');
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
    getMenuItems();
  }


  @override
  Widget build(BuildContext context) {

    List<Step> steps = [
      Step(
          state: stepOneState,
          isActive: stepOneActive,
          title: Text('Item name, description and pricing'),
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
                    Text('How would you describe this item to customers?'),
                    SizedBox(height: 0,),
                    TextFormField(
                      onChanged: (String value) {
                      },
                      focusNode: descriptionNode,
                      controller: descriptionController,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          hintText: 'How would you describe this item to your customers? (Optional)',
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
                child: DropdownButton<Category>(
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
                  onChanged: (Category newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: items
                      .map<DropdownMenuItem<Category>>((Category value) {
                    return DropdownMenuItem<Category>(
                      value: value,
                      child: Text(value.name, style: TextStyle(fontSize: 19),),
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
        title: const Text('Add Existing Items'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Here, you can add individual items to your combo mea.  Simply tap to search, find it, and add it to the combo.'),
            SizedBox(height: 15,),
            Form(
              key: _formKey,
                autovalidate: true,
              child: MultiSelect(
                buttonBarColor: Colors.white,
                searchBoxHintText: 'Search',
                  autovalidate: false,
                  titleText: 'Add at least two items from the list',
                  validator: (value) {
                   _formKey.currentState.save();
                    if (value == null) {
                      return 'Please select two or more items';
                    }
                    return null;
                  },
                  errorText: 'Please select two or more items',
                  dataSource: menuItems.map((e) {
                    return {
                      'display': e.name,
                      'value': e.id,
                    };
                  }).toList(),
                  textField: 'display',
                  valueField: 'value',
                  filterable: true,
                  required: true,
                  onSaved: (value) {
                    if (value != null) {
                      List<String> ids = value.cast<String>();
                      Future.delayed(Duration(milliseconds: 100), () {
                        setState(() {
                          added_ids = ids;
                        });
                      });
                    } else {
                      Future.delayed(Duration(milliseconds: 100), () {
                        setState(() {
                          added_ids = [];
                        });
                      });
                    }
                  },
              ),
            ),
            SizedBox(height: 10,),
            Text('Added ${added_ids.length} items'),
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
              child:  Image.asset(imageUrl, fit: BoxFit.cover,),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () async {
                final image = await imagePicker.getImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    imageFile = File(image.path);
                  });
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
                    imageUrl = image.path;
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
          title: Text('New Combo Item', textAlign: TextAlign.center,),
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.only(left: 50),
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
                    hintText: '3 Pieces/\$5.75, 7.5 Pieces/\$10.75, 10 Pieces/\$15',
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

  void getMenuItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/get-menus',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        });
    Iterable menus = json.decode(response.body)['menus'];

    setState(() {
      menuItems = menus.map((e) =>  Item.fromJson(e)).toList().toList().where((element) => element.individual_items.length == 0).toList();
      print(menuItems);
    });
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
      items = [chooseCategory] + categories.map((e) =>  Category.fromJson(e)).toList().toList();
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

class Item {
  String id;
  String name;
  List<String> individual_items;
  Item({this.id, this.name, this.individual_items});
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['_id'] as String,
        name: json['name'] as String,
        individual_items: json['individual_items'].cast<String>()
    );
  }
}