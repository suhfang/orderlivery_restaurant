import 'dart:async';
import 'dart:convert';
import 'dart:math';


import 'package:Restaurant/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart' as Constants;

// to get places detail (lat/lng)
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Constants.kGoogleApiKey);

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [CustomSearchScaffold()],
      ),
    );
  }
}

final customTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  accentColor: Colors.redAccent,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.00)),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 12.50,
      horizontal: 10.00,
    ),
  ),
);

class RoutesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "My App",
    theme: customTheme,
    routes: {
      "/": (_) => MyApp(),
      "/search": (_) => CustomSearchScaffold(),
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class _MyAppState extends State<MyApp> {
  Mode _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("My App"),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildDropdownMenu(),
              RaisedButton(
                onPressed: _handlePressButton,
                child: Text("Search places"),
              ),
              RaisedButton(
                child: Text("Custom"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/search");
                },
              ),
            ],
          )),
    );
  }

  Widget _buildDropdownMenu() => DropdownButton(
    value: _mode,
    items: <DropdownMenuItem<Mode>>[
      DropdownMenuItem<Mode>(
        child: Text("Overlay"),
        value: Mode.overlay,
      ),
      DropdownMenuItem<Mode>(
        child: Text("Fullscreen"),
        value: Mode.fullscreen,
      ),
    ],
    onChanged: (m) {
      setState(() {
        _mode = m;
      });
    },
  );

  void onError(PlacesAutocompleteResponse response) {
    Fluttertoast.showToast(msg: response.errorMessage, backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
  }

  Future<void> _handlePressButton() async {}
}

Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/set-primary-address',
    headers: {
      'token': token,
      'Content-Type': 'application/json'
    },
    body: json.encode({
      'name': detail.result.formattedAddress,
      'lat': '${lat}',
      'lon': '${lng}'
    }));

    print(response.body);
    Navigator.push(scaffold.context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));

  }
}

Future<void> _showMyDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Feature not released yet'),
        content:  SizedBox(),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// custom scaffold that handle search
// basically your widget need to extends [GooglePlacesAutocompleteWidget]
// and your state [GooglePlacesAutocompleteState]
class CustomSearchScaffold extends PlacesAutocompleteWidget {
  CustomSearchScaffold()
      : super(
    apiKey: Constants.kGoogleApiKey,
    sessionToken: Uuid().generateV4(),
    language: "en",
    components: [Component(Component.country, "us")],
  );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text('ADD ADDRESS'),
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
    );
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, searchScaffoldKey.currentState);
      },
      logo: Row(
        children: [],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );

    return Scaffold(
        key: searchScaffoldKey,
        body: Container(
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: AppBarPlacesAutoCompleteTextField(
                  textDecoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 19),
                    hintText: 'What\'s the main address of your restaurant?',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                    EdgeInsets.only(left: 15, bottom: 20, top: 11, right: 0),
                  )),
            ),
            SizedBox(height: 104, child: Divider()),
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: body,
            ),
          ]),
        ));
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
