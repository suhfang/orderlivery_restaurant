import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/users.dart';
import 'package:badges/badges.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoder/geocoder.dart';

class LocationProfilePage extends StatefulWidget {
  String locationId;
  LocationProfilePage({@required this.locationId});
  _LocationProfilePageState createState() => _LocationProfilePageState();
}

class ScheduleTime {
  TimeOfDay timeOfDay;

  ScheduleTime({@required this.timeOfDay});

  int minutes() {
    return (this.timeOfDay.hour * 60) + (this.timeOfDay.minute);
  }

  String readableLocalTime() {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, this.timeOfDay.hour,
        this.timeOfDay.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return (format.format(dt)).toLowerCase();
  }
}

class _LocationProfilePageState extends State<LocationProfilePage> {
  bool _doesPickup = true;
//  TextEditingController nameController = TextEditingController();
//  TextEditingController descriptionController = TextEditingController();
//  TextEditingController addressController = TextEditingController();
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

  TextEditingController accessTokenController = TextEditingController();

  FToast fToast;

//  var nameFocusNode = new FocusNode();
//  var descriptionFocusNode = new FocusNode();
//  var addressFocusNode = new FocusNode();
  var phoneFocusNode = new FocusNode();
  var accessTokenNode = new FocusNode();
//  String dropdownValue = 'Choose restaurant type';

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final signUpFirstNameController = TextEditingController();
  FocusNode _focus = new FocusNode();
  TextEditingController textController = new TextEditingController();
  final coverImagePicker = ImagePicker();
  final logoImagePicker = ImagePicker();
  File coverImage;
  File logoImage;
  List<Slot> sundaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];
  List<Slot> mondaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];
  List<Slot> tuesdaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];
  List<Slot> wednesdaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];
  List<Slot> thursdaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];
  List<Slot> fridaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];
  List<Slot> saturdaySlots = [
    Slot(start: TimeOfDay.now(), end: TimeOfDay.now()),
  ];

  String _selectedValuesJson = 'Nothing tags to show';
  List<Tag> _selectedLanguages;

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Location Details'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text('Are you available for pickup?'),
                      value: _doesPickup,
                      onChanged: (newValue) {
                        setState(() {
                          _doesPickup = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    ),
                    SizedBox(
                      height: 10,
                    ),
//                    Text('What\'s the full main US address of your restaurant?'),
//                    Container(
//                      alignment:
//                      Alignment.topCenter,
//                      width: MediaQuery.of(context).size.width,
//                      child: _TextFormField(
//                        focusNode: addressFocusNode,
//                        inputFormatters: [
//                        ],
//                        hintText: 'Main address',
//                        onChanged: (String value) {
//                          _formKey
//                              .currentState
//                              .validate();
//                        },
//                        controller: addressController,
//                        validator:
//                            (String value) {
//                          if (value.length < 2) {
//                            return 'Enter your restaurant\'s address';
//                          }
//                          return null;
//                        },
//                        onSaved: (String value) {
////                                                  model.lastName = value;
//                        },
//                      ),
//                    ),
                    Text(
                        'What phone number can we use to reach this location?'),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.width,
                      child: _TextFormField(
                        focusNode: phoneFocusNode,
                        inputFormatters: [],
                        hintText: 'Phone number',
                        onChanged: (String value) {
                          _formKey.currentState.validate();
                        },
                        controller: phoneController,
                        validator: (String value) {
                          if (value.length < 1) {
                            return 'Enter your phone';
                          }
                          if (value.length != 10) {
                            return 'Enter a valid US phone number';
                          }
                          return null;
                        },
                        onSaved: (String value) {
//                                                  model.lastName = value;
                        },
                      ),
                    ),

                    Text('Generate an access token for this location'),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            copyAccessToken(accessTokenController.text);
                          },
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.bottomCenter,
                                width: 200,
                                child: _TextFormField(
                                  isPassword: true,
                                  enabled: false,
                                  focusNode: accessTokenNode,
                                  inputFormatters: [],
                                  hintText: 'Access token',
                                  onChanged: (String value) {
                                    _formKey.currentState.validate();
                                  },
                                  controller: accessTokenController,
                                  validator: (String value) {
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
                              Icon(LineIcons.copy),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: generateAccessToken,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(30)),
                              height: 45,
                              child: Center(
                                child: Text(
                                  'Generate',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                        ))
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Let\'s know your restaurant schedule',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(LineIcons.info_circle),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 70,
                          child: Text(
                            'Please note that days left without both opening and closing times are considered non-working days',
                            style: TextStyle(fontSize: 17),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sunday'),
                          ScheduleSlotsWidget(
                            slots: sundaySlots,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monday'),
                          ScheduleSlotsWidget(
                            slots: mondaySlots,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tuesday'),
                          ScheduleSlotsWidget(
                            slots: tuesdaySlots,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Wednesday'),
                          ScheduleSlotsWidget(
                            slots: wednesdaySlots,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thursday'),
                          ScheduleSlotsWidget(
                            slots: thursdaySlots,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Friday'),
                          ScheduleSlotsWidget(
                            slots: fridaySlots,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saturday'),
                          ScheduleSlotsWidget(slots: saturdaySlots)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
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
                          child: Text(
                            'Save Details',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onTap: saveProfile,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ));
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
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
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
          Icon(
            FontAwesomeIcons.surprise,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
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

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  void saveProfile() async {
    var _sundaySlots = sundaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();
    var _mondaySlots = mondaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();
    var _tuesdaySlots = tuesdaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();
    var _wednesdaySlots = wednesdaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();
    var _thursdaySlots = thursdaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();
    var _fridaySlots = fridaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();
    var _saturdaySlots = saturdaySlots
        .where((element) => element.start.hour < element.end.hour)
        .toList();

    print(_sundaySlots.length);
    return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitRing(
                    color: Colors.white,
                    size: 50.0,
                    lineWidth: 2,
                  )
                ],
              ));
        });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');

//    if (nameController.text.trim().isEmpty) {
//      _showErrorToast('Please enter your restaurant\'s name');
//      FocusScope.of(context).requestFocus(nameFocusNode);
//      return;
//    }
//    if (descriptionController.text.trim().isEmpty) {
//      _showErrorToast('Please enter your restaurant\'s name');
//      FocusScope.of(context).requestFocus(descriptionFocusNode);
//      return;
//    }
//    if (addressController.text.trim().isEmpty) {
//      _showErrorToast('Please enter your restaurant\'s address');
//      FocusScope.of(context).requestFocus(addressFocusNode);
//      return;
//    }

//    if ((await Geocoder.local.findAddressesFromQuery(addressController.text.trim())).first.countryName != 'United States') {
//      _showErrorToast('Enter a valid US address');
//      FocusScope.of(context).requestFocus(addressFocusNode);
//      return;
//    }
    if (phoneController.text.length != 10) {
      _showErrorToast('Please enter your locations\'s phone number');
      FocusScope.of(context).requestFocus(phoneFocusNode);
      return;
    }

//    var addresses = await Geocoder.local.findAddressesFromQuery(addressController.text.trim());
//    var coordinates = addresses.first.coordinates;

    final body = json.encode({
      'does_pickup': _doesPickup,
      'location_id': widget.locationId,
      'phone_number': phoneController.text.trim(),
      'hours': {
        "mon": {
          "open": monFromController.text.trim(),
          "close": monToController.text.trim()
        },
        "tue": {
          "open": tuesFromController.text.trim(),
          "close": tuesToController.text.trim()
        },
        "wed": {
          "open": wedFromController.text.trim(),
          "close": wedToController.text.trim()
        },
        "thu": {
          "open": thuFromController.text.trim(),
          "close": thuToController.text.trim()
        },
        "fri": {
          "open": friFromController.text.trim(),
          "close": friToController.text.trim()
        },
        "sat": {
          "open": satFromController.text.trim(),
          "close": satToController.text.trim()
        },
        "sun": {
          "open": sundayFromController.text.trim(),
          "close": sundayToController.text.trim()
        },
      }
    });

    final response = await http.post(
        '${Constants.apiBaseUrl}/restaurants/save-location-profile',
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: body);
    print(response.body);
    Navigator.pop(context);
    _showToast('Your profile was successfully updated');
//    Navigator.pop(context);
  }

  void getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    print(token);
    print(widget.locationId);
    final response = await http.post(
      '${Constants.apiBaseUrl}/restaurants/get-location-profile',
      body: json.encode({'location_id': widget.locationId}),
      headers: {'token': token, 'Content-Type': 'application/json'},
    );
    print(response.body);
    var profile = Profile.fromJson(json.decode(response.body));

    setState(() {
      phoneController.text = profile.phone_number;
      _doesPickup = profile.does_pickup;
      sundayFromController.text = profile.hours.sun.open;
      sundayToController.text = profile.hours.sun.close;

      monFromController.text = profile.hours.mon.open;
      monToController.text = profile.hours.tue.close;

      tuesFromController.text = profile.hours.tue.open;
      tuesToController.text = profile.hours.tue.close;

      wedFromController.text = profile.hours.wed.open;
      wedToController.text = profile.hours.wed.close;

      thuFromController.text = profile.hours.thu.open;
      thuToController.text = profile.hours.thu.close;

      friFromController.text = profile.hours.fri.open;
      friToController.text = profile.hours.fri.close;

      satFromController.text = profile.hours.sat.open;
      satToController.text = profile.hours.sat.close;

      accessTokenController.text = profile.access_token;
    });
  }

  void copyAccessToken(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      _showToast('Copied access token');
    }
  }

  void generateAccessToken() async {
    if (accessTokenController.text.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');

      final response = await http.post(
        '${Constants.apiBaseUrl}/restaurants/generate-access-token',
        body: json.encode({'location_id': widget.locationId}),
        headers: {'token': token, 'Content-Type': 'application/json'},
      );
      accessTokenController.text =
          json.decode(response.body)['token'] as String;
      _showToast('Token was generated');
    } else {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Color(0xFF737373),
              height: 230,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(10),
                        topLeft: const Radius.circular(10))),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'WARNING!',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 0, left: 15, right: 15, bottom: 15),
                      child: Text(
                        'Generating another access token may prevent this location from access. Are you sure you want to continue?',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        decoration: BoxDecoration(),
                        width: MediaQuery.of(context).size.width - 40,
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String token = prefs.getString('token');

                                final response = await http.post(
                                  '${Constants.apiBaseUrl}/restaurants/generate-access-token',
                                  body: json.encode(
                                      {'location_id': widget.locationId}),
                                  headers: {
                                    'token': token,
                                    'Content-Type': 'application/json'
                                  },
                                );
                                accessTokenController.text = json
                                    .decode(response.body)['token'] as String;
                                Navigator.pop(context);
                                _showToast('Token was generated');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                height: 50,
                                child: Center(
                                  child: Text(
                                    'YES',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.orange,
                                ),
                                height: 50,
                                child: Center(
                                  child: Text(
                                    'NO',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        )),
                  ],
                ),
              ),
            );
          });
    }
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
//  String name;
//  String description;
//  String address;
  String phone_number;
  String access_token;
  Hours hours;
  bool does_pickup;
  Profile({this.access_token, this.phone_number, this.hours, this.does_pickup});

  factory Profile.fromJson(Map<String, dynamic> json) {
    var hours = json['hours'];

    var mon_period = Period(
        open: hours['mon']['open'] as String,
        close: hours['mon']['close'] as String);
    var tue_period = Period(
        open: hours['tue']['open'] as String,
        close: hours['tue']['close'] as String);
    var wed_period = Period(
        open: hours['wed']['open'] as String,
        close: hours['wed']['close'] as String);
    var thu_period = Period(
        open: hours['thu']['open'] as String,
        close: hours['thu']['close'] as String);
    var fri_period = Period(
        open: hours['fri']['open'] as String,
        close: hours['fri']['close'] as String);
    var sat_period = Period(
        open: hours['sat']['open'] as String,
        close: hours['sat']['close'] as String);
    var sun_period = Period(
        open: hours['sun']['open'] as String,
        close: hours['sun']['close'] as String);

    return Profile(
//        name: json['name'] as String,
//        address: json['address'] as String,
//        description: json['description'] as String,
        phone_number: json['phone_number'] as String,
        access_token: json['access_token'] as String,
        does_pickup: json['does_pickup'] as bool,
//        type: json['type'] as String,
//        cover_image_url: json['cover_image_url'] as String,
//        logo_image_url: json['logo_image_url'] as String,
        hours: Hours(
            mon: mon_period,
            tue: tue_period,
            wed: wed_period,
            thu: thu_period,
            fri: fri_period,
            sat: sat_period,
            sun: sun_period));
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
      this.inputFormatters,
      this.focusNode,
      this.enabled});

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
                    borderSide: BorderSide(width: 0.3, color: Colors.grey))),
            obscureText: isPassword ? true : false,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
          ),
        ));
  }
}

/// Language Class
class Tag extends Taggable {
  ///
  final String name;

  ///
  final int position;

  /// Creates Language
  Tag({
    this.name,
    this.position,
  });

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
    "position": $position\n
  }''';
}

/// LanguageService
class TagService {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Tag>> getTags(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    return <Tag>[
      Tag(name: 'Fast Food', position: 1),
      Tag(name: 'Healthy', position: 2),
      Tag(name: 'Pizza', position: 3),
      Tag(name: 'Chicken', position: 4),
      Tag(name: 'Burgers', position: 5),
      Tag(name: 'Tacos', position: 6),
      Tag(name: 'Asian', position: 7),
      Tag(name: 'Sushi', position: 8),
      Tag(name: 'Pho', position: 9),
      Tag(name: 'Italian', position: 10),
      Tag(name: 'Donuts', position: 11),
      Tag(name: 'Seafood', position: 12),
      Tag(name: 'Salad', position: 13),
      Tag(name: 'Steak', position: 10),
    ]
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class Slot {
  TimeOfDay start;
  TimeOfDay end;

  Slot({this.start, this.end});
}

class ScheduleSlotWidget extends StatefulWidget {
  final Function(TextEditingController) onTapOpening;
  final Function(TextEditingController) onTapClosing;
  final Function onTapRemove;
  final List<Slot> slots;
  final int index;

  ScheduleSlotWidget(
      {this.onTapOpening,
      this.onTapClosing,
      this.slots,
      this.onTapRemove,
      this.index});

  _ScheduleSlotWidgetState createState() => _ScheduleSlotWidgetState();
}

class _ScheduleSlotWidgetState extends State<ScheduleSlotWidget> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: 200,
        child: Row(
          children: [
            widget.index != 0 && widget.index > widget.slots.length - 2
                ? GestureDetector(
                    onTap: () {
                      widget.onTapRemove();
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.brown,
                      ),
                      child: Icon(
                        LineIcons.minus,
                        color: Colors.white,
                        size: 15,
                      ),
                    ))
                : SizedBox(),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                widget.onTapOpening(fromController);
              },
              child: Container(
                width: 100,
                height: 50,
                child: TextFormField(
                  enabled: false,
                  controller: fromController,
                  decoration: InputDecoration(
                    labelText: 'Start time',
                    labelStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                widget.onTapClosing(toController);
              },
              child: Container(
                width: 100,
                height: 50,
                child: TextFormField(
                  enabled: false,
                  controller: toController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Stop time',
                      labelStyle: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ));
  }
}

class ScheduleDay {
  List<Slot> slots;
  String name;
  ScheduleDay({this.name, this.slots});
}

class ScheduleSlotsWidget extends StatefulWidget {
  List<Slot> slots;

  ScheduleSlotsWidget({this.slots});

  _ScheduleSlotsWidgetState createState() => _ScheduleSlotsWidgetState();
}

class _ScheduleSlotsWidgetState extends State<ScheduleSlotsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xF1F1F1F1),
        ),
        height: widget.slots.length * 60.0,
        width: 280,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // GestureDetector(
            //         onTap: () {
            //           if (widget.slots.length > 1) {
            //             setState(() {
            //               widget.slots.length -= 1;
            //             });
            //           }
            //         },
            //         child: Container(
            //           height: 20,
            //           width: 20,

            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(20),
            //             color: Colors.brown,
            //           ),

            //           child: Icon(LineIcons.minus, color: Colors.white, size: 15,),

            //       )
            //     )
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              height: widget.slots.length * 50.0,
              width: 260,
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 5,
                      color: Colors.transparent,
                    );
                  },
                  itemCount: widget.slots.length,
                  itemBuilder: (context, index) {
                    var slot = widget.slots[index];
                    return ScheduleSlotWidget(
                      index: index,
                      slots: widget.slots,
                      onTapRemove: () {
                        setState(() {
                          widget.slots.removeAt(index);
                        });
                      },
                      onTapClosing: (controller) async {
                        TimeOfDay time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          var scheduledTime = ScheduleTime(timeOfDay: time);
                          setState(() {
                            slot.end = time;
                          });
                          controller.text = scheduledTime.readableLocalTime();
                        }
                      },
                      onTapOpening: (controller) async {
                        TimeOfDay time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          var scheduledTime = ScheduleTime(timeOfDay: time);
                          setState(() {
                            slot.start = time;
                          });
                          controller.text = scheduledTime.readableLocalTime();
                        }
                      },
                    );
                  }),
            ),

            Column(children: [
              GestureDetector(
                  onTap: () {
                    var array = widget.slots;
                    array = array
                        .where(
                            (element) => element.start.hour >= element.end.hour)
                        .toList();
                    if (array.isEmpty) {
                      setState(() {
                        widget.slots.add(
                            Slot(start: TimeOfDay.now(), end: TimeOfDay.now()));
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              'Insert a start and end time to create a new slot');
                    }
                  },
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.brown,
                    ),
                    child: Icon(
                      LineIcons.plus,
                      color: Colors.white,
                      size: 15,
                    ),
                  ))
            ])
          ],
        ));
  }
}
