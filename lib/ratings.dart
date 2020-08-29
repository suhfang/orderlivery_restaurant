

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class RatingsPage extends StatefulWidget {
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  @override

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('RATINGS'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(LineIcons.bell),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:  Stack(
            children: [
             Container(
               height: 150,
               width: MediaQuery.of(context).size.width-50,
               child:  Column(
                 children: [
                   Card(
                     child: Container(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           SizedBox(height: 10,),
                           Text('Overall in 491 ratings - Customers', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                           SizedBox(height: 10,),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.starHalf, size: 10, color: Colors.yellow,),
                             ],
                           ),
                           SizedBox(height: 15,),
                         ],
                       ),
                     ),
                   ),
                   Card(
                     child: Container(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           SizedBox(height: 10,),
                           Text('Overall in 491 ratings - Drivers', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                           SizedBox(height: 10,),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                               SizedBox(width: 5,),
                               Icon(FontAwesomeIcons.starHalf, size: 10, color: Colors.yellow,),
                             ],
                           ),
                           SizedBox(height: 15,),
                         ],
                       ),
                     ),
                   ),
                 ],
               )
             ),
              Padding(
                padding: EdgeInsets.only(top: 160),
                child: ListView(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Text('John Doe'),
                                SizedBox(width: 20,),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Text('Food was no what I ordered. Food was no what I ordered. Food was no what I ordered. Food was no what I ordered. '),
                          ),
                          Divider()
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Text('John Doe'),
                                SizedBox(width: 20,),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                    SizedBox(width: 5,),
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.yellow,),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Text('Food was no what I ordered. Food was no what I ordered. Food was no what I ordered. Food was no what I ordered. '),
                          ),
                          Divider()
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}