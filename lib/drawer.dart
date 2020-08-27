import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/menu.dart';
import 'package:Restaurant/profile.dart';
import 'package:Restaurant/ratings.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerScaffold extends StatelessWidget {

  final Widget body;
  final AppBar appBar;
  final Color backgroundColor;
  DrawerScaffold({

    this.body,
    this.appBar,
    this.backgroundColor});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
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
                        leading: Icon(LineIcons.home),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
                        }
                      ),
                      ListTile(
                        title: Text('RESTAURANT PROFILE'),
                        leading: Icon(Icons.food_bank),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfilePage()));
                        }
                      ),
                      ListTile(
                        title: Text('MENU'),
                        leading: Icon(Icons.menu_book),
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MenuPage()));
                        }

                      ),
                      ListTile(
                        title: Text('RATINGS'),
                        leading: Icon(LineIcons.star),
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RatingsPage()));
                        }
                      ),
                      ListTile(
                        title: Text('USERS'),
                        leading: Icon(LineIcons.users),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UsersPage()));
                        }
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', '');
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text('SIGN OUT', style: TextStyle(color: Colors.white),),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.orange
                          ),
                        ),
                      )
                    ),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}