

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantLocationProfilePage extends StatefulWidget {
  _RestaurantLocationProfilePageState createState() => _RestaurantLocationProfilePageState();

}

class _RestaurantLocationProfilePageState extends State<RestaurantLocationProfilePage> {


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

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Divider(),
            SizedBox(height: 20,),
            Text('Let\'s know your restaurant schedule', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(LineIcons.info),
                Container(
                  width: MediaQuery.of(context).size.width-70,
                  child: Text('Please note that days left without both opening and closing times are considered non-working days', style: TextStyle(fontSize: 19),),
                )
              ],
            ),
            Divider(),
            SizedBox(height: 10,),
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
                                labelText: 'Opening time'
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
                                labelText: 'Opening time'
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
                                labelText: 'Opening time'
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
                                labelText: 'Opening time'
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
                                labelText: 'Opening time'
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
                                labelText: 'Opening time'
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
                                labelText: 'Opening time'
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
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      )
    );
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


//
//
//
//    if ((await Geocoder.local.findAddressesFromQuery(addressController.text.trim())).first.countryName != 'United States') {
//      _showErrorToast('Enter a valid US address');
//      FocusScope.of(context).requestFocus(addressFocusNode);
//      return;
//    }
//    if (phoneController.text.length != 10) {
//      _showErrorToast('Please enter your restaurant\'s name');
//      FocusScope.of(context).requestFocus(phoneFocusNode);
//      return;
//    }
//
//
//
//    var addresses = await Geocoder.local.findAddressesFromQuery(addressController.text.trim());
//    var coordinates = addresses.first.coordinates;
//
//    final body = json.encode({
//      'name': nameController.text.trim(),
//      'description': descriptionController.text.trim(),
//      'primary_address': {
//        'name': addressController.text.trim(),
//        'lon': '${coordinates.longitude}',
//        'lat': '${coordinates.latitude}'
//      },
//      'logo_image_url': _logo_image_url,
//      'cover_image_url': _cover_image_url,
//      'phone_number': phoneController.text.trim(),
//      'type': dropdownValue,
//      'hours': {
//        "mon": {
//          "open": monFromController.text.trim(),
//          "close": monToController.text.trim()
//        },
//        "tue": {
//          "open": tuesFromController.text.trim(),
//          "close": tuesToController.text.trim()
//        },
//        "wed": {
//          "open": wedFromController.text.trim(),
//          "close": wedToController.text.trim()
//        },
//        "thu": {
//          "open": thuFromController.text.trim(),
//          "close": thuToController.text.trim()
//        },
//        "fri": {
//          "open": friFromController.text.trim(),
//          "close": friToController.text.trim()
//        },
//        "sat": {
//          "open": satFromController.text.trim(),
//          "close": satToController.text.trim()
//        },
//        "sun": {
//          "open": sundayFromController.text.trim(),
//          "close": sundayToController.text.trim()
//        },
//      }});
//
//    print(body);
//    final response = await http.post('${Constants.apiBaseUrl}/restaurants/save-profile',
//        headers: {
//          'token': token,
//          'Content-Type': 'application/json'
//        },
//        body: body);
//    print(response.body);
//    Navigator.pop(context);
//    _showToast('Your profile was successfully updated');
////    Navigator.pop(context);
  }

//  void getProfile() async  {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String token = prefs.getString('token');
//    print(token);
//    final response = await http.get('${Constants.apiBaseUrl}/restaurants/get-profile',
//        headers: {
//          'token': token,
//          'Content-Type': 'application/json'
//        });
//    var profile = Profile.fromJson(json.decode(response.body));
//
//    setState(() {
//      print(profile.name);
//      nameController.text = profile.name;
//      descriptionController.text = profile.description;
//      addressController.text = profile.address;
//      phoneController.text = profile.phone_number;
//      dropdownValue = profile.type;
//
//      sundayFromController.text = profile.hours.sun.open;
//      sundayToController.text = profile.hours.sun.close;
//
//      monFromController.text = profile.hours.mon.open;
//      monToController.text = profile.hours.tue.close;
//
//      tuesFromController.text = profile.hours.tue.open;
//      tuesToController.text = profile.hours.tue.close;
//
//      wedFromController.text = profile.hours.wed.open;
//      wedToController.text = profile.hours.wed.close;
//
//      thuFromController.text = profile.hours.thu.open;
//      thuToController.text = profile.hours.thu.close;
//
//      friFromController.text = profile.hours.fri.open;
//      friToController.text = profile.hours.fri.close;
//
//      satFromController.text = profile.hours.sat.open;
//      satToController.text = profile.hours.sat.close;
//
//      _cover_image_url = profile.cover_image_url;
//      _logo_image_url = profile.logo_image_url;
//    });
//  }
}