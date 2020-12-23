import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Restaurant/SignUpVerificationPage.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:Restaurant/forgot_password.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/init.dart';
import 'package:Restaurant/location_hub.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpModel {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  SignUpModel({this.firstName, this.lastName, this.email, this.phoneNumber});
}

class LoginpModel {
  String email;
  String password;
  LoginpModel({this.email, this.password});
}

class AuthPage extends StatefulWidget {
  AuthPage({Key key, this.loginTab}) : super(key: key);

  final bool loginTab;
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
//  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final _signUpFormKey = GlobalKey<FormState>();
  SignUpModel signUpModel = SignUpModel();

  final _loginFormKey = GlobalKey<FormState>();
  LoginpModel loginModel = LoginpModel();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final signUpLastNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  final loginEmailController = TextEditingController();
  final accessTokenController = TextEditingController();
  final loginPasswordController = TextEditingController();

  bool _pageLoaded = false;
  int _segmentedControlGroupValue;
  int _verificationCode;
  Widget _currentBody;

  int _numPages = 2;
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  String _signUpError = '';

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> _handleSignIn() async {
    _showMyDialog();
//    try {
//      await _googleSignIn.signIn();
//    } catch (error) {
//      print(error);
//    }
  }

  Future<void> _showMyDialog() async {
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

  Future<Null> _loginWithFacebook() async {
    _showMyDialog();
//    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
//
//    switch (result.status) {
//      case FacebookLoginStatus.loggedIn:
//        final FacebookAccessToken accessToken = result.accessToken;
//        print('''
//         Logged in!
//
//         Token: ${accessToken.token}
//         User id: ${accessToken.userId}
//         Expires: ${accessToken.expires}
//         Permissions: ${accessToken.permissions}
//         Declined permissions: ${accessToken.declinedPermissions}
//         ''');
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        print('Login cancelled by the user.');
//        break;
//      case FacebookLoginStatus.error:
//        print('Something went wrong with the login process.\n'
//            'Here\'s the error Facebook gave us: ${result.errorMessage}');
//        break;
//    }
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('token') ?? '').isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => InitPage()));
    }
  }
  @override
  Widget build(BuildContext context) {

    init();

    if (!_pageLoaded) _segmentedControlGroupValue = widget.loginTab ? 1 : 0;
    if (widget.loginTab && !_pageLoaded) {
      Future.delayed(Duration(milliseconds: 100), () {
        _pageController.nextPage(
          duration: Duration(milliseconds: 1000),
          curve: Curves.ease,
        );
        _pageLoaded = true;
      });
    } else {
      _pageLoaded = true;
    }
    final deviceWidth = MediaQuery.of(context).size.width - 50;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark
      ),
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Builder(
              builder: (BuildContext context) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 10, left: 0),
                            child: SingleChildScrollView(
                              child: Container(
                                height: 800,
                                child: PageView(
                                  physics: ClampingScrollPhysics(),
                                  controller: _pageController,
                                  onPageChanged: (int page) {
                                    print(page);
                                    setState(() {
                                      _currentPage = page;
                                      _segmentedControlGroupValue = _currentPage;
                                    });
                                  },
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              top: 0,
                                              bottom: 10,
                                              right: 10),
                                          child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Sign Up',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        fontWeight: FontWeight.bold),
                                                  ),
//                                                Padding(
//                                                  padding: EdgeInsets.only(right: 10),
//                                                  child: Image.asset(
//                                                    'assets/images/logo.png',
//                                                    height: 50,
//                                                    width: 50,
//                                                  ),
//                                                )
                                                ],
                                              )),
                                        ),
                                        Form(
                                          key: _signUpFormKey,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 40,
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        alignment:
                                                        Alignment.topCenter,
                                                        width: deviceWidth,
                                                        child: TTextFormField(
                                                          autofillHints: [
                                                            AutofillHints.givenName
                                                          ],
                                                          hintText: 'First Name',
                                                          onChanged:
                                                              (String value) {
                                                            _signUpFormKey
                                                                .currentState
                                                                .validate();
                                                          },
                                                          controller:
                                                          firstNameController,
                                                          validator:
                                                              (String value) {
                                                            if (value.length < 2) {
                                                              return 'Enter your first name';
                                                            }
                                                            return null;
                                                          },
                                                          onSaved: (String value) {
//                                                  model.lastName = value;
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                ],
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        alignment:
                                                        Alignment.topCenter,
                                                        width: deviceWidth,
                                                        child: TTextFormField(
                                                          autofillHints: [
                                                            AutofillHints.familyName
                                                          ],
                                                          hintText: 'Last Name',
                                                          onChanged:
                                                              (String value) {
                                                            _signUpFormKey
                                                                .currentState
                                                                .validate();
                                                          },
                                                          controller:
                                                          lastNameController,
                                                          validator:
                                                              (String value) {
                                                            if (value.length < 2) {
                                                              return 'Enter your last name';
                                                            }
                                                            return null;
                                                          },
                                                          onSaved: (String value) {
//                                                  model.lastName = value;
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                ],
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.topCenter,
                                                    width: deviceWidth,
                                                    child: TTextFormField(
                                                      hintText: 'Email',
                                                      onChanged: (String value) {
                                                        _signUpFormKey.currentState
                                                            .validate();
                                                      },
                                                      autofillHints: [
                                                        AutofillHints.email
                                                      ],
                                                      isEmail: true,
                                                      controller:
                                                      signUpEmailController,
                                                      validator: (String value) {
                                                        if (!EmailValidator
                                                            .validate(value.trim())) {
                                                          return 'Enter your email';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String value) {
//                                                  model.lastName = value;
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.topCenter,
                                                    width: deviceWidth,
                                                    child: TTextFormField(
                                                      hintText: 'Password',
                                                      onChanged: (String value) {
                                                        _signUpFormKey.currentState
                                                            .validate();
                                                      },
                                                      autofillHints: [
                                                        AutofillHints.password
                                                      ],
                                                      isPassword: true,
                                                      controller:
                                                      signUpPasswordController,
                                                      validator: (String value) {
                                                        if (value.length < 1) {
                                                          return 'Enter your password';
                                                        }
                                                        if (value.length < 8) {
                                                          return 'Password should be at least 8 characters';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String value) {
//                                                  model.lastName = value;
                                                      },

                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.topCenter,
                                                    width: deviceWidth,
                                                    child: TTextFormField(
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp("[0-9]"))
                                                      ],
                                                      hintText: 'Phone Number',
                                                      onChanged: (String value) {
                                                        _signUpFormKey.currentState
                                                            .validate();
                                                      },
                                                      autofillHints: [
                                                        AutofillHints
                                                            .telephoneNumber
                                                      ],
                                                      controller:
                                                      signUpPhoneController,
                                                      validator: (String value) {
                                                        if (value.length != 10) {
                                                          return 'Enter your phone number';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String value) {
//                                                  model.lastName = value;
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(20),
                                            child: RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        recognizer: TapGestureRecognizer()..onTap = () => _launchInWebViewWithJavaScript('http://orderlivery.com/terms'),
                                                        style: TextStyle(color: Colors.purple, fontSize: 15, ),
                                                        text: ' Terms and Conditions '
                                                    ),
                                                    TextSpan(
                                                        style: TextStyle(color: Colors.black, fontSize: 15),
                                                        text: 'and'
                                                    ),
                                                    TextSpan(
                                                        recognizer: TapGestureRecognizer()..onTap = () => _launchInWebViewWithJavaScript('http://orderlivery.com/privacy'),
                                                        style: TextStyle(color: Colors.purple, fontSize: 15,),
                                                        text: ' Privacy Policy '
                                                    ),
                                                  ],
                                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                  text: 'By signing up, you agree to our'
                                              ),
                                            )
                                        ),
                                        SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width-50,
                                            child: GestureDetector(
                                              onTap: () {
                                                signup(context);

                                              },
                                              child: Container(

                                                  width: MediaQuery.of(context).size.width-50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: Colors.orange,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Sign Up',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                  )),
                                            )),

                                        Padding(
                                            padding: EdgeInsets.only(right: 25),
                                            child: InkWell(
                                                highlightColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  _pageController.nextPage(
                                                    duration:
                                                    Duration(milliseconds: 500),
                                                    curve: Curves.ease,
                                                  );
                                                  print(_pageController.page);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    children: [
                                                      Icon(
                                                        LineIcons.arrow_right,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        'Log In',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20),
                                                      ),
                                                    ],
                                                  ),
                                                )))
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              top: 0,
                                              bottom: 10,
                                              right: 10),
                                          child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Log In',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black
                                                    ),
                                                  ),
//                                                Padding(
//                                                  padding: EdgeInsets.only(right: 10),
//                                                  child: Image.asset(
//                                                    'assets/images/logo.png',
//                                                    height: 50,
//                                                    width: 50,
//                                                  ),
//                                                )
                                                ],
                                              )),
                                        ),
                                        Form(
                                          key: _loginFormKey,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 40,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.topCenter,
                                                    width: deviceWidth,
                                                    child: TTextFormField(
                                                      hintText: 'Email',
                                                      onChanged: (String value) {
                                                        accessTokenController.text = '';
                                                        _loginFormKey.currentState
                                                            .validate();
                                                      },
                                                      autofillHints: [
                                                        AutofillHints.email
                                                      ],
                                                      controller:
                                                      loginEmailController,
                                                      validator: (String value) {
                                                        if (!EmailValidator
                                                            .validate(value.trim())) {
                                                          return 'Enter your email';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String value) {
//                                                  model.lastName = value;
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.topCenter,
                                                    width: deviceWidth,
                                                    child: TTextFormField(
                                                      hintText: 'Password',
                                                      onChanged: (String value) {
                                                        accessTokenController.text = '';
                                                        _loginFormKey.currentState
                                                            .validate();
                                                      },
                                                      autofillHints: [
                                                        AutofillHints.password
                                                      ],
                                                      isPassword: true,
                                                      controller:
                                                      loginPasswordController,
                                                      validator: (String value) {
                                                        if (value.length < 8) {
                                                          return 'Password should be at least 8 characters';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String value) {
//                                                  model.lastName = value;
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),

                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ForgotPasswordPage()));
                                          },
                                          child:  Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Text('Forgot password?', style: TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold,),),
                                          ),
                                        ),
                                        SizedBox(height: 20,),
                                        SizedBox(height: 50, child: Text('OR'),),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.topCenter,
                                              width: deviceWidth,
                                              child: TTextFormField(
                                                isPassword: true,
                                                hintText: 'Access Token',
                                                onChanged: (String value) {
                                                  loginEmailController.text = '';
                                                  loginPasswordController.text = '';
                                                  _loginFormKey.currentState
                                                      .validate();
                                                },
                                                autofillHints: [
                                                  AutofillHints.password
                                                ],
                                                controller:
                                                accessTokenController,
                                                validator: (String value) {
                                                  if (!EmailValidator
                                                      .validate(value)) {
                                                    return 'Enter your access token';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (String value) {
//                                                  model.lastName = value;
                                                },
                                              ),
                                            )
                                          ],
                                        ),

                                        SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width-50,
                                            child: InkWell(
                                              onTap: () {
                                                login(context);
                                              },
                                              child: Container(
                                                  width: MediaQuery.of(context).size.width-50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: Colors.orange,

                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Log In',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                  )),
                                            )),


                                        Padding(
                                            padding: EdgeInsets.only(left: 25),
                                            child: InkWell(
                                                highlightColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  _pageController.previousPage(
                                                    duration:
                                                    Duration(milliseconds: 500),
                                                    curve: Curves.ease,
                                                  );
                                                  print(_pageController.page);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        LineIcons.arrow_left,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        'Sign Up',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 19),
                                                      ),
                                                    ],
                                                  ),
                                                )))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  int generateRandom() {
    var rnd = new Random();
    var next = rnd.nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }
    return next.toInt();
  }

  void login(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   if (loginEmailController.text.isEmpty && loginPasswordController.text.isEmpty && accessTokenController.text.isNotEmpty) {
     prefs.setBool('is_location', true);
     loginWithAccessToken();
   } else if (loginEmailController.text.isNotEmpty && loginPasswordController.text.isNotEmpty && accessTokenController.text.isEmpty) {
     prefs.setBool('is_restaurant', true);
     loginWithEmailAndPassword();
   }
  }


  void signup(BuildContext context) async {
    if (!_signUpFormKey.currentState.validate()) {
      return;
    }



    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = signUpEmailController.text.trim().toLowerCase();
    final password = signUpPasswordController.text.trim();
    final phoneNumber = signUpPhoneController.text.trim();

    if (SignupverificationPage.code == 0) {
      SignupverificationPage.code = generateRandom();
    }
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SignupverificationPage(phoneNumber: phoneNumber, firstName: firstName, lastName: lastName, email: email, password: password)));


  }

  TabController _controller;

  ///<-- fixed here

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {

    if (await canLaunch(url)) {
      print(url);
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void loginWithEmailAndPassword() {
    if (!_loginFormKey.currentState.validate()) {
      return;
    }
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
                  SpinKitThreeBounce(
                      color: Colors.white,
                      size: 50.0,
                  )
                ]
              ));
        });

    Future.delayed(Duration(seconds: 1), () async {
      var url = Constants.apiBaseUrl + '/restaurants/login';

      final email = loginEmailController.text.trim().toLowerCase();
      final password = loginPasswordController.text.trim();

      Map jsonMap = {
        'email': email,
        'password': password,
      };


      var body = json.encode(jsonMap);
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        TokenResponse data = TokenResponse.fromJson(json.decode(response.body));
        if (data.token.isNotEmpty) {
          Navigator.pop(context);
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('token', data.token);
          await prefs.setBool('is_location', false);
          await prefs.setBool('is_restaurant', true);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => InitPage(),
              fullscreenDialog: true));
        }
      } else {
        Navigator.pop(context);
        if (response.body.toLowerCase().contains('or')) {
          final error = json.decode(response.body);
          Fluttertoast.showToast(msg: error['message'], backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
        } else if (response.body.toLowerCase().contains('could')) {
            final error = json.decode(response.body);
            Fluttertoast.showToast(msg: error['message'], backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
          }
        
      }
    });
  }

  void loginWithAccessToken() {
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
                  SpinKitThreeBounce(
                      color: Colors.white,
                      size: 50.0,
                  )
                ],
              ));
        });

    Future.delayed(Duration(seconds: 1), () async {
      var url = Constants.apiBaseUrl + '/restaurant_locations/login';

      print(accessTokenController.text);
      Map jsonMap = {
        'secret_access_token': accessTokenController.text.trim(),
      };


      var body = json.encode(jsonMap);
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        TokenResponse data = TokenResponse.fromJson(json.decode(response.body));

          Navigator.pop(context);
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('token', accessTokenController.text.trim());
           await prefs.setBool('is_location', true);
          await prefs.setBool('is_restaurant', false);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => LocationHubPage(),
              fullscreenDialog: true));

      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Invalid access token', backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
      }
    });
  }

}

class TTextFormField extends StatefulWidget {

  final String hintText;
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;
  final TextEditingController controller;
  final Function onChanged;
  final Iterable<TextInputFormatter> inputFormatters;
  final Iterable<String> autofillHints;

  TTextFormField(
      {this.hintText,
        this.validator,
        this.onSaved,
        this.isPassword = false,
        this.isEmail = false,
        this.controller,
        this.onChanged,
        this.inputFormatters,
        this.autofillHints,});

  TextFormFieldState createState() => TextFormFieldState();
}

class TextFormFieldState extends State<TTextFormField> {

  bool passwordVisible = false;

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
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            autofillHints: widget.autofillHints,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            controller: widget.controller,
            validator: widget.validator,
            decoration: InputDecoration(
              suffixIcon: widget.isPassword ? GestureDetector(
                onTap: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
                child: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
              ): SizedBox(),
              helperText: ' ',
              hintText: widget.hintText,
              contentPadding: EdgeInsets.only(left: 20, right: 0, bottom: 5),
              filled: true,
              fillColor: Color(0xfff3f3f4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
            ),
            obscureText: !passwordVisible && widget.isPassword,
            keyboardType:
            widget.isEmail ? TextInputType.emailAddress : TextInputType.text,

          ),
        ));
  }
}


class TokenResponse {
  final String token;

  TokenResponse({this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(token: json['token']);
  }
}
