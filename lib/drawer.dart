import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/menu.dart';
import 'package:Restaurant/notifications.dart';
import 'package:Restaurant/orders.dart';
import 'package:Restaurant/payments.dart';
import 'package:Restaurant/profile.dart';
import 'package:Restaurant/ratings.dart';
import 'package:Restaurant/settings.dart';
import 'package:Restaurant/users.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerScaffold extends StatelessWidget {

  final Widget body;
  final bool showsNavBar;
  final AppBar appBar;
  final String title;
  final Color backgroundColor;
  final GlobalKey<ScaffoldState> key;

  DrawerScaffold({

    this.body,
    this.appBar,
    this.showsNavBar,
    @required this.title,
    this.backgroundColor,
    this.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          automaticallyImplyLeading: this.showsNavBar ?? true,
          shadowColor: Colors.transparent,
        centerTitle: true,
        title:   Text(this.title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        ),
      backgroundColor: backgroundColor,
      body: body,
      drawer: Drawer(
        child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ListTile(
                        title: Text('MY HUB'),
                        leading: Icon(FontAwesomeIcons.home, color: Colors.black,),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
                        }
                      ),
                      ListTile(
                        title: Text('RESTAURANT PROFILE'),
                        leading: Icon(CupertinoIcons.profile_circled, color: Colors.black,),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RestaurantDetailPage()));
                        }
                      ),
                      ListTile(
                        title: Text('FOOD MENU'),
                        leading: Icon(Icons.menu_book, color: Colors.black,),
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FoodMenuPage()));
                        }

                      ),
                      ListTile(
                        title: Text('RATINGS'),
                        leading: Icon(LineIcons.star, color: Colors.black,),
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RatingsPage()));
                        }
                      ),
                      ListTile(
                        title: Text('ORDERS'),
                        leading: Icon(LineIcons.newspaper_o, color: Colors.black,),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OrdersPage()));
                        }
                      ),
                      ListTile(
                          title: Text('PAYMENTS'),
                          leading: Icon(LineIcons.credit_card, color: Colors.black,),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PaymentsPage()));
                          }
                      ),
                      ListTile(
                          title: Text('ACCOUNT SETTINGS'),
                          leading: Icon(FontAwesomeIcons.cog, color: Colors.black,),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SettingsPage()));
                          }
                      ),
                      ListTile(
                        // tileColor: Colors.orange,
                          title: Text('LOG OUT',style: TextStyle(color: Colors.black),),
                          leading: Icon(LineIcons.sign_out, color: Colors.black,),
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('token', '');
                            await prefs.setBool('is_location', null);
                            await prefs.setBool('is_restaurant', null);
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
                          }
                      ),
                    ],
                  ),
//                  Padding(
//                    padding: EdgeInsets.all(10),
//                    child: Align(
//                      alignment: Alignment.bottomCenter,
//                      child: InkWell(
//                        onTap: () async {
//                          SharedPreferences prefs = await SharedPreferences.getInstance();
//                          await prefs.setString('token', '');
//                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
//                        },
//                        child: Container(
//                          height: 50,
//                          width: MediaQuery.of(context).size.width,
//                          child: Center(
//                            child: Text('SIGN OUT', style: TextStyle(color: Colors.white),),
//                          ),
//                          decoration: BoxDecoration(
//                              color: Colors.orange
//                          ),
//                        ),
//                      )
//                    ),
//                  )
                ],
              ),
            )
        ),
      ),
    );
  }


}