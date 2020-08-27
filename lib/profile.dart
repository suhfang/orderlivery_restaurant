

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

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

TextEditingController sundayFromController = TextEditingController();
TextEditingController sundayToController = TextEditingController();

  TextEditingController monFromController = TextEditingController();
  TextEditingController monToController = TextEditingController();

  TextEditingController tuesFromController = TextEditingController();
  TextEditingController tuesToController = TextEditingController();

  TextEditingController wedFromController = TextEditingController();
  TextEditingController wedToController = TextEditingController();

  TextEditingController thuFromController = TextEditingController();
  TextEditingController thuToController = TextEditingController();

  TextEditingController friFromController = TextEditingController();
  TextEditingController friToController = TextEditingController();

  TextEditingController satFromController = TextEditingController();
  TextEditingController satToController = TextEditingController();

  String dropdownValue = 'Choose restaurant type';
  final _signUpFormKey = GlobalKey<FormState>();
  final signUpFirstNameController = TextEditingController();
  FocusNode _focus = new FocusNode();
  TextEditingController textController = new TextEditingController();

  Widget build(BuildContext context) {
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
                  ],
                  hintText: 'Restaurant name',
                  onChanged:
                      (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: nameController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your restaurant\'s name';
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
                  ],
                  hintText: 'Description',
                  onChanged: (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: descriptionController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your restaurant\'s description or caption';
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
                  ],
                  hintText: 'Address',
                  onChanged: (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: addressController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your restaurant\'s address';
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
                  ],
                  hintText: 'Phone Number',
                  onChanged: (String value) {
                    _signUpFormKey
                        .currentState
                        .validate();
                  },
                  controller: phoneController,
                  validator:
                      (String value) {
                    if (value.length < 2) {
                      return 'Enter your phone';
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
//                  child: ButtonTheme(
//                    alignedDropdown: true,
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
                      items: <String>['Choose restaurant type', "Afghan", "African", "Albanian", "American", "Arabian", "Argentinian", "Armenian", "Asian Fusion", "Australian", "Austrian", "Bagels", "Bakery", "Bangladeshi", "Barbeque", "Belgian", "Brasseries", "Brazilian", "Breakfast", "British", "Brunch", "Buffets", "Burgers", "Burmese", "Cafes", "Cafeteria", "Cajun", "Californian", "Calzones", "Cambodian", "Cantonese", "Caribbean", "Catalan", "Cheesesteaks", "Chicken", "Chicken Wings", "Chili", "Chinese", "Classic", "Coffee and Tea", "Colombian", "Comfort Food", "Costa", "Rican", "Creole", "Crepes", "Cuban", "Czech", "Delis", "Dessert", "Dim Sum", "Diner", "Dominican", "Eclectic", "Ecuadorian", "Egyptian", "El Salvadoran", "Empanadas", "English", "Ethiopian", "Fast Food", "Filipino", "Fine Dining", "Fish & Chips", "Fondue", "Food Cart", "Food Court", "Food Stands", "French", "Fresh Fruits", "Frozen Yogurt", "Gastropubs", "German", "Gluten-Free", "Greek", "Grill", "Guatemalan", "Gyro", "Haitian", "Halal", "Hawaiian", "Himalayan", "Hoagies", "Hot Dogs", "Hot Pot", "Hungarian", "Iberian", "Ice Cream", "Indian", "Indonesian", "Irish", "Italian", "Jamaican", "Japanese", "Kids", "Korean", "Kosher", "Laotian", "Late Night", "Latin American", "Lebanese", "Live/Raw Food", "Low Carb", "Malaysian", "Mandarin", "Mediterranean", "Mexican", "Middle Eastern", "Modern European", "Mongolian", "Moroccan", "Nepalese", "Noodles", "Nouvelle Cuisine", "Nutritious", "Organic", "Pakistani", "Pancakes", "Pasta", "Persian", "Persian/Iranian", "Peruvian", "Pitas", "Pizza", "Polish", "Portuguese", "Potato", "Poutineries", "Pub Food", "Puerto Rican", "Ribs", "Russian", "Salad", "Sandwiches", "Scandinavian", "Scottish", "Seafood", "Senegalese", "Singaporean", "Slovakian", "Small", "Plates", "Smoothies and Juices", "Soul Food", "Soup", "South African", "South American", "Southern", "Southwestern", "Spanish", "Sri Lankan", "Steakhouses", "Subs", "Supper Clubs", "Sushi Bars", "Syrian", "Szechwan", "Taiwanese", "Tapas", "Tex-Mex", "Thai", "Tibetan", "Turkish", "Ukrainian", "Uzbek", "Vegan", "Vegetarian", "Vietnamese", "Wraps"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 19),),
                        );
                      }).toList(),
                    ),
//                  ),
                ),
              ),
              Divider(),
              SizedBox(height: 20,),
              Text('HOURS', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.all(10),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SUNDAY'),
                     Row(
                       children: [
                         InkWell(
                           onTap: () async  {
                             TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                             sundayFromController.text = '${time.hour}:${time.minute}';
                           },
                           splashColor: Colors.transparent,
                           highlightColor: Colors.transparent,
                           child: Container(
                             width: 100,
                             height: 50,
                             child: TextFormField(
                               enabled: false,
                               controller: sundayFromController,
                               decoration: InputDecoration(
                                   labelText: 'Start time'
                               ),
                             ),
                           ),
                         ),
                         SizedBox(
                           width: 10,
                         ),
                         InkWell(
                           onTap: () async  {
                             TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                             sundayToController.text = '${time.hour}:${time.minute}';
                           },
                           splashColor: Colors.transparent,
                           highlightColor: Colors.transparent,
                           child: Container(
                             width: 100,
                             height: 50,
                             child: TextFormField(
                               enabled: false,
                               controller: sundayToController,
                               decoration: InputDecoration(
                                   labelText: 'Closing time'
                               ),
                             ),
                           ),
                         ),
                         Icon(LineIcons.close)
                       ],
                     )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MONDAY'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            monFromController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: monFromController,
                              decoration: InputDecoration(
                                  labelText: 'Start time'
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            monToController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: monToController,
                              decoration: InputDecoration(
                                  labelText: 'Closing time'
                              ),
                            ),
                          ),
                        ),
                        Icon(LineIcons.close)
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TUESDAY'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            tuesFromController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: tuesFromController,
                              decoration: InputDecoration(
                                  labelText: 'Start time'
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            tuesToController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: tuesToController,
                              decoration: InputDecoration(
                                  labelText: 'Closing time'
                              ),
                            ),
                          ),
                        ),
                        Icon(LineIcons.close)
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('WEDNESDAY'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            wedFromController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: wedFromController,
                              decoration: InputDecoration(
                                  labelText: 'Start time'
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            wedToController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: wedToController,
                              decoration: InputDecoration(
                                  labelText: 'Closing time'
                              ),
                            ),
                          ),
                        ),
                        Icon(LineIcons.close)
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('THURSDAY'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            thuFromController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: thuFromController,
                              decoration: InputDecoration(
                                  labelText: 'Start time'
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            thuToController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: thuToController,
                              decoration: InputDecoration(
                                  labelText: 'Closing time'
                              ),
                            ),
                          ),
                        ),
                        Icon(LineIcons.close)
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('FRIDAY'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            friFromController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: friFromController,
                              decoration: InputDecoration(
                                  labelText: 'Start time'
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            friToController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: friToController,
                              decoration: InputDecoration(
                                  labelText: 'Closing time'
                              ),
                            ),
                          ),
                        ),
                        Icon(LineIcons.close)
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SATURDAY'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            satFromController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: satFromController,
                              decoration: InputDecoration(
                                  labelText: 'Start time'
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async  {
                            TimeOfDay time  = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            satToController.text = '${time.hour}:${time.minute}';
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: satToController,
                              decoration: InputDecoration(
                                  labelText: 'Closing time'
                              ),
                            ),
                          ),
                        ),
                        Icon(LineIcons.close)
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Text('LOGO', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Image.network('http://via.placeholder.com/640x360'),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange
                ),
                height: 50,
                child: Center(
                  child: Text('UPDATE PHOTO', style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(height: 40,),
              Text('COVER IMAGE', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Image.network('http://via.placeholder.com/1000x800'),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange
                ),
                height: 50,
                child: Center(
                  child: Text('UPDATE PHOTO', style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(height: 100,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.orange)
                ),
                height: 50,
                child: Center(
                  child: Text('SAVE PROFILE', style: TextStyle(color: Colors.orange),),
                ),
              ),

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

  _TextFormField({
    this.hintText,
    this.validator,
    this.onSaved,
    this.isPassword = false,
    this.isEmail = false,
    this.controller,
    this.autofillHints,
    this.onChanged,
    this.inputFormatters
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