
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SingleItemPage extends StatefulWidget {
  _SingleItemPageState createState() => _SingleItemPageState();
}



FocusNode descriptionNode = FocusNode();
FocusNode flatPriceFocusNode = FocusNode();
FocusNode nameFocusNode = FocusNode();
FocusNode cookingTimeFocusNode = FocusNode();


TextEditingController descriptionController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController flatPriceController = TextEditingController();
TextEditingController cookingTimeController = TextEditingController();

final _formKey = GlobalKey<FormState>();
class _SingleItemPageState extends State<SingleItemPage> {

  PricingType _character = PricingType.none;




  StepperType stepperType = StepperType.horizontal;
  int currentStep = 0;
  bool complete = false;

  next() {
    currentStep + 1 != createSteps().length
        ? goTo(currentStep + 1)
        : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  List<Step> createSteps() {
    List<Step> steps = [
      Step(
          isActive: true,
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
                        hintText: 'A La Cart name',
                        onChanged: (String value) {
                          _formKey.currentState.validate();
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
                    SizedBox(height: 20,),
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
        isActive: false,
        title: const Text('Address'),
        content: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Home Address'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Postcode'),
            ),
          ],
        ),
      )
    ];
    return steps;

  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('New A La Carte Item', textAlign: TextAlign.center,),
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(0),
                child: Stepper(
                  currentStep: currentStep,
                  onStepContinue: next,
                  steps: createSteps(),
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
              Text('USD \$ '),
              Expanded(
                child: _TextFormField(
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
      return Container(
        child: Text('Starting from'),
      );
    }
    if (type == PricingType.price_and_quantity) {
      return Container(
        child: Text('Price and Quantity'),
      );
    } else {
      return SizedBox();
    }
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