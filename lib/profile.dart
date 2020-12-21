

import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/location_profile.dart';
import 'package:Restaurant/users.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoder/geocoder.dart';

class RestaurantDetailPage extends StatefulWidget {
   bool showsNavBar = true;
  RestaurantDetailPage({this.showsNavBar});
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {

  TextEditingController restaurantNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController accessTokenController = TextEditingController();
  FToast fToast;

  var nameFocusNode = new FocusNode();
  var descriptionFocusNode = new FocusNode();
  var addressFocusNode = new FocusNode();
  var phoneFocusNode = new FocusNode();
  var accessTokenNode = new FocusNode();
  
  String dropdownValue = "Choose restaurant type";
  String _cover_image_url = 'http://via.placeholder.com/1000x800';
  String _logo_image_url = 'http://via.placeholder.com/640x360';

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final signUpFirstNameController = TextEditingController();
  FocusNode _focus = new FocusNode();
  TextEditingController textController = new TextEditingController();
  final coverImagePicker = ImagePicker();
  final logoImagePicker = ImagePicker();
  File coverImage;
  File logoImage;

  Future getLogoImage() async {
    final image = await coverImagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
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
      setState(() {
        logoImage = File(image.path);
      });
      if (image.path.split('.').isNotEmpty) {
        String extension = image.path.split('.').last;
        List<int> imageBytes = logoImage.readAsBytesSync();
        if (extension.isNotEmpty) {
          String base64Image = 'data:image/$extension;base64, ${base64Encode(imageBytes)}';
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String token = prefs.getString('token') ?? '';
          final response = await http.post('${Constants.apiBaseUrl}/restaurants/upload-logo',
              headers: {
                'token': token,
                'Content-Type': 'application/json'
              },
              body: json.encode({
                'base64': base64Image
              }));
          Navigator.pop(context);
          if (!response.body.contains('error')) {
            setState(() {
              _logo_image_url = json.decode(response.body)['message'] as String;
            });
            _showToast('Logo image updated');
          }
        }
      }
    }
  }
  Future getCoverImage() async {

    final image = await coverImagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
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
      setState(() {
        coverImage = File(image.path);
      });
      if (image.path.split('.').isNotEmpty) {
        String extension = image.path.split('.').last;
        List<int> imageBytes = coverImage.readAsBytesSync();
        if (extension.isNotEmpty) {
          String base64Image = 'data:image/$extension;base64, ${base64Encode(
              imageBytes)}';
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String token = prefs.getString('token') ?? '';
          final response = await http.post(
              '${Constants.apiBaseUrl}/restaurants/upload-cover',
              headers: {
                'token': token,
                'Content-Type': 'application/json'
              },
              body: json.encode({
                'base64': base64Image
              }));
          print(json.decode(response.body)['message']);
          print(response.body);
          Navigator.pop(context);
          if (!response.body.contains('error')) {
            setState(() {
              _cover_image_url = json.decode(response.body)['message'] as String;
            });
          }
          _showToast('Cover image updated');
        }

      }


    }
  }

  String _selectedValuesJson = 'No tags to show';
  TextEditingController tagController = TextEditingController();
  List<Tag> selectedTags = [

  ];

  Widget build(BuildContext context) {
    return DrawerScaffold(
      showsNavBar: widget.showsNavBar ?? true,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      title: 'RESTAURANT PROFILE',
      body: Builder(
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How do we call your restaurant?'),
                    SizedBox(height: 10),
                    Container(
                      alignment:
                      Alignment.topCenter,
                      width: MediaQuery.of(context).size.width,
                      child: _TextFormField(
                        focusNode: nameFocusNode,
                        inputFormatters: [
                        ],
                        hintText: 'RESTAURANT NAME',
                        onChanged:
                            (String value) {
                          _formKey
                              .currentState
                              .validate();
                        },
                        controller: restaurantNameController,
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
                    Text('Briefly describe your restaurant'),
                    SizedBox(height: 10),

                    Container(
                      alignment:
                      Alignment.topCenter,
                      width: MediaQuery.of(context).size.width,
                      child: _TextFormField(
                        focusNode: descriptionFocusNode,
                        inputFormatters: [
                        ],
                        hintText: 'DESCRIPTION',
                        onChanged: (String value) {
                          _formKey
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
                    Text('How would your classify your restaurant?'),
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
                          items: <String>[ "Choose restaurant type", "Sports Bar", "Shaved Ice", "Wings", "Donuts", "Pho", "Afghan", "African", "Albanian", "American", "Arabian", "Argentinian", "Armenian", "Asian Fusion", "Australian", "Austrian", "Bagels", "Bakery", "Bangladeshi", "Barbeque", "Belgian", "Brasseries", "Brazilian", "Breakfast", "British", "Brunch", "Buffets", "Burgers", "Burmese", "Cafes", "Cafeteria", "Cajun", "Californian", "Calzones", "Cambodian", "Cantonese", "Caribbean", "Catalan", "Cheesesteaks", "Chicken", "Chicken Wings", "Chili", "Chinese", "Classic", "Coffee and Tea", "Colombian", "Comfort Food", "Costa", "Rican", "Creole", "Crepes", "Cuban", "Czech", "Delis", "Dessert", "Dim Sum", "Diner", "Dominican", "Eclectic", "Ecuadorian", "Egyptian", "El Salvadoran", "Empanadas", "English", "Ethiopian", "Fast Food", "Filipino", "Fine Dining", "Fish & Chips", "Fondue", "Food Cart", "Food Court", "Food Stands", "French", "Fresh Fruits", "Frozen Yogurt", "Gastropubs", "German", "Gluten-Free", "Greek", "Grill", "Guatemalan", "Gyro", "Haitian", "Halal", "Hawaiian", "Himalayan", "Hoagies", "Hot Dogs", "Hot Pot", "Hungarian", "Iberian", "Ice Cream", "Indian", "Indonesian", "Irish", "Italian", "Jamaican", "Japanese", "Kids", "Korean", "Kosher", "Laotian", "Late Night", "Latin American", "Lebanese", "Live/Raw Food", "Low Carb", "Malaysian", "Mandarin", "Mediterranean", "Mexican", "Middle Eastern", "Modern European", "Mongolian", "Moroccan", "Nepalese", "Noodles", "Nouvelle Cuisine", "Nutritious", "Organic", "Pakistani", "Pancakes", "Pasta", "Persian", "Persian/Iranian", "Peruvian", "Pitas", "Pizza", "Polish", "Portuguese", "Potato", "Poutineries", "Pub Food", "Puerto Rican", "Ribs", "Russian", "Salad", "Sandwiches", "Scandinavian", "Scottish", "Seafood", "Senegalese", "Singaporean", "Slovakian", "Small", "Plates", "Smoothies and Juices", "Soul Food", "Soup", "South African", "South American", "Southern", "Southwestern", "Spanish", "Sri Lankan", "Steakhouses", "Subs", "Supper Clubs", "Sushi Bars", "Syrian", "Szechwan", "Taiwanese", "Tapas", "Tex-Mex", "Thai", "Tibetan", "Turkish", "Ukrainian", "Uzbek", "Vegan", "Vegetarian", "Vietnamese", "Wraps"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 19),),
                            );
                          }).toList(),
                        ),
//                  ), "
                      ),
                    ),


                   SingleChildScrollView(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           SizedBox(height: 10,),
                           Text('Add Tags'),
                           SizedBox(height: 10,),
                           FlutterTagging<Tag>(
                             initialItems: selectedTags,
                             textFieldConfiguration: TextFieldConfiguration(
                                 style: TextStyle(fontSize: 19),
                               textInputAction: TextInputAction.done,

                               controller: tagController,
                               decoration: InputDecoration(
                                 helperText: ' ',
                                 hintText: 'Add tags',

                                 hintStyle: TextStyle(fontSize: 19),
                                 contentPadding: EdgeInsets.only(left: 20),
                                 filled: true,
                                 // enabledBorder: UnderlineInputBorder(
                                 //     borderSide: BorderSide(width: 0.3, color: Colors.grey)),
                                 fillColor: Color(0xfff3f3f4),
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(30),
                                   borderSide: BorderSide(
                                     width: 0,
                                     style: BorderStyle.none,
                                   ),
                                 ),
                               ),
                               onSubmitted: ( name) {
                                print(selectedTags.map((e) => e.name).toList());
                               }
                             ),
                             findSuggestions: TagService.getTags,
                             additionCallback: (value) {
                               return Tag(
                                 name: value.trim(),
                                 position: 0,
                               );
                             },
                             onAdded: (tag) {
                               // api calls here, triggered when add to tag button is pressed
                               String name = tagController.text.trim();
                               tagController.clear();
                               return Tag(name: name, position: 0);
                             },
                             configureSuggestion: (lang) {

                               return SuggestionConfiguration(
                                 title: Text(lang.name),
                                 additionWidget: Chip(
                                   avatar: Icon(
                                     Icons.add_circle,
                                     color: Colors.white,
                                   ),
                                   label: Text('Add New Tag'),
                                   labelStyle: TextStyle(
                                     color: Colors.white,
                                     fontSize: 14.0,
                                     fontWeight: FontWeight.w300,
                                   ),
                                   backgroundColor: Colors.orange,
                                 ),
                               );

                             },
                             configureChip: (tag) {
                               return ChipConfiguration(
                                 label: Text(tag.name.trim()),
                                 backgroundColor: Colors.orange,
                                 labelStyle: TextStyle(color: Colors.white),
                                 deleteIconColor: Colors.white,
                               );
                             },
                             onChanged: () {
                               setState(() {
                                 print(selectedTags.map((e) => e.name).toList());
                               });
                             },
                           ),
                         ],
                       )
                   ),
                    SizedBox(height: 20,),
                    Text('Upload a bright and legible version of your restaurant\'s logo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                    Divider(),
                    SizedBox(height: 10,),
                    Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        child:  ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100.0)),
                          child: Image.network(_logo_image_url, fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: getLogoImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.orange),
                        ),
                        height: 45,
                        child: Center(
                          child: Text('Update Photo', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),
                    Text('Upload a bright and legible version of your restaurant\'s cover photo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                    Divider(),
                    SizedBox(height: 10,),
                    Center(
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width-50,
                        child:  ClipRRect(
                          child: Image.network(_cover_image_url, fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: getCoverImage,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          border: Border.all(color: Colors.orange),
                        ),
                        height: 45,
                        child: Center(
                          child: Text('Update Photo', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),
                    SizedBox(height: 100,),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.orange),
                        ),
                        height: 45,
                        child: Center(
                          child: Text('Save Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        ),
                      ),
                      onTap: saveprofile,
                    )

                  ],
                ),
              )
          );
       },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
    fToast = FToast();
  }

  _showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.orange,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.white,),
          SizedBox(
            width: 12.0,
          ),
          Text(message, style: TextStyle(color: Colors.white),),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

  }

  _showErrorToast(String message) {

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesomeIcons.surprise, color: Colors.white,),
          SizedBox(
            width: 12.0,
          ),
          Text(message, style: TextStyle(color: Colors.white),),
        ],
      ),
    );


    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    Navigator.pop(context);
  }


  void saveprofile() async {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');


    if (restaurantNameController.text.trim().isEmpty) {
      _showErrorToast('Please enter your restaurant\'s name');
      FocusScope.of(context).requestFocus(nameFocusNode);
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showErrorToast('Please enter your restaurant\'s name');
      FocusScope.of(context).requestFocus(descriptionFocusNode);
      return;
    }
//    if (addressController.text.trim().isEmpty) {
//      _showErrorToast('Please enter your restaurant\'s address');
//      FocusScope.of(context).requestFocus(addressFocusNode);
//      return;
//    }


    if (dropdownValue.toLowerCase().contains('type')) {
      _showErrorToast('Select a restaurant type');
      return;
    }


//    var addresses = await Geocoder.local.findAddressesFromQuery(addressController.text.trim());
//    var coordinates = addresses.first.coordinates;

    final body = json.encode({
      'name': restaurantNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'type': dropdownValue,
      'tags': selectedTags.map((e) => e.name as String).toList()
    });


    final response = await http.post('${Constants.apiBaseUrl}/restaurants/save-profile',
        headers: {
          'token': token,
          'Content-Type': 'application/json'
        },
      body: body);
  print(response.body);
    Navigator.pop(context);
    _showToast('Your profile was successfully updated');
    if (!widget.showsNavBar) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      });
    }
  }

  void getProfile() async  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    print(token);
    final response = await http.get('${Constants.apiBaseUrl}/restaurants/get-profile',
    headers: {
      'token': token,
      'Content-Type': 'application/json'
    });
    print(response.body);
    var profile = Profile.fromJson(json.decode(response.body));

    setState(() {
      print(profile.name);
      selectedTags = profile.tags.map((e) => Tag(name: e, position: 0)).toList();
      restaurantNameController.text = profile.name;
      descriptionController.text = profile.description;
//      addressController.text = profile.address;
      dropdownValue = profile.type;
      _cover_image_url = profile.cover_image_url;
      _logo_image_url = profile.logo_image_url;
    });
  }
}

class Period {
  String open;
  String close;
  Period({this.open, this.close});
}

class Hours {
  Period mon;
  Period tue;
  Period wed;
  Period thu;
  Period fri;
  Period sat;
  Period sun;
  Hours({this.mon, this.tue, this.wed, this.thu, this.fri, this.sat, this.sun});
}

class Profile {
  String name;
  String description;
//  String address;
//  String phone_number;
  String type;
//  Hours hours;
  String cover_image_url;
  String logo_image_url;
  List<String> tags;
//  Profile({this.name, this.description, this.address, this.phone_number, this.type, this.hours, this.cover_image_url, this.logo_image_url});
  Profile({this.name, this.description, this.type, this.cover_image_url, this.logo_image_url, this.tags});

  factory Profile.fromJson(Map<String, dynamic> json) {
    Iterable tags = json['tags'];
//    var hours = json['hours'];
//
//    var mon_period = Period(open: hours['mon']['open'] as String, close: hours['mon']['close'] as String);
//    var tue_period = Period(open: hours['tue']['open'] as String, close: hours['tue']['close'] as String);
//    var wed_period = Period(open: hours['wed']['open'] as String, close: hours['wed']['close'] as String);
//    var thu_period = Period(open: hours['thu']['open'] as String, close: hours['thu']['close'] as String);
//    var fri_period = Period(open: hours['fri']['open'] as String, close: hours['fri']['close'] as String);
//    var sat_period = Period(open: hours['sat']['open'] as String, close: hours['sat']['close'] as String);
//    var sun_period = Period(open: hours['sun']['open'] as String, close: hours['sun']['close'] as String);

    return Profile(
        name: json['name'] as String,
//        address: json['address'] as String,
        description: json['description'] as String,
//        phone_number: json['phone_number'] as String,
        type: json['type'] as String,
        cover_image_url: json['cover_image_url'] as String,
        logo_image_url: json['logo_image_url'] as String,
//        hours: Hours(
//            mon: mon_period,
//            tue: tue_period,
//            wed: wed_period,
//            thu: thu_period,
//            fri: fri_period,
//            sat: sat_period,
//            sun: sun_period
//        )
    tags: tags.map((e) => e as String).toList()
      
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
    this.focusNode
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
              contentPadding: EdgeInsets.only(left: 20),
              filled: true,
              // enabledBorder: UnderlineInputBorder(
              //     borderSide: BorderSide(width: 0.3, color: Colors.grey)),
              fillColor: Color(0xfff3f3f4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
            ),
            obscureText: isPassword ? true : false,
            keyboardType:
            isEmail ? TextInputType.emailAddress : TextInputType.text,
          ),
        ));
  }
}