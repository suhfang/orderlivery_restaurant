
import 'dart:convert';

import 'package:Restaurant/add_list.dart';
import 'package:Restaurant/create_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
  _CategoriesPageState createState() => _CategoriesPageState();
}

class Category {
  String name;

  String id;
  Category({this.name, this.id});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] as String, id: json['_id'] as String);
  }

}

class _CategoriesPageState extends State<CategoriesPage> {

  List<Category> _categories = [
  ];

  void submitMenuItem() {

  }
  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        LineIcons.trash,
        color: Colors.white,
      ),
    );
  }

  @override
  initState() {
    super.initState();
    getAppetizers();
  }

  Future<bool> deleteCategory(BuildContext context, Category category, int index) async {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return Container(
        color: Color(0xFF737373),
        height: 200,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(topRight: const Radius.circular(10), topLeft: const Radius.circular(10))
          ),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 15,),
              Text('CONFIRM!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 5,),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
                child: Text('Are you sure you want to delete this category?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
              ),
              SizedBox(
                height: 10,
              ),

              Container(
                  decoration: BoxDecoration(
                  ),
                  width: MediaQuery.of(context).size.width - 40,
                  height: 40,

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: () async  {
//                              if (_locations.length > 1) {
                              var url = Constants.apiBaseUrl + '/restaurants/remove-category';
                              print(url);
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              print(prefs.getString('token'));
                              Future.delayed(Duration(seconds: 0), () async {
                                var response = await http.post(
                                    url,
                                    headers: {
                                      "Content-Type": "application/json",
                                      'token': prefs.getString('token')
                                    },
                                    body: json.encode(
                                        {
                                          'category_id': category.id
                                        }
                                    )
                                );
                                Navigator.of(context).pop(true);
                                setState(() {
                                  getAppetizers();
                                });
                              });
                              return true;
//                              }
                            },
                            child:  Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: 50,
                              child: Center(child: Text('YES', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),),),

                            ),
                          )
                      ),
                      SizedBox(width: 10,),
                      Expanded(

                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(true);

                              setState(() {

                              });
                              return false;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange,
                              ),
                              height: 50,
                              child: Center(child: Text('NO', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),),

                            ),
                          )
                      ),
                    ],
                  )
              ),

            ],
          ),
        ),
      );
    });
  }

  void getAppetizers() async  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/get-categories',
    headers: {
      'token': prefs.getString('token'),
      'Content-Type': 'application/json'
    });
    Iterable categories = json.decode(response.body)['categories'];

    setState(() {
      _categories = categories.map((e) => Category.fromJson(e)).toList();

    });




  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Stack(
                children: [
                  Text('Please note: This will be the order the categories will appear in the app. We recommend starting with Appetizers at the top of the list, and desserts last. But it\'s up to you!',
                  style: TextStyle(fontWeight: FontWeight.bold),),
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 70,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ),
                    child:  ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final item = _categories[index];
                            return Dismissible(
                                background: stackBehindDismiss(),
                                direction: DismissDirection.endToStart,
                                key: Key(item.id),
                                onDismissed: (DismissDirection direction) {
                                  _categories.removeAt(index);
                                },
                                confirmDismiss: (DismissDirection direction) {
                                  return deleteCategory(context, _categories[index], index);
                                },
                                child: GestureDetector(
                                  onTap: () {
//                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LocationMenuPage(addressName: item.address.name, addressId: item.id,)));

                                  },
                                  child:  Column(
                                    children: [
                                      ListTile(
                                        title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                      Divider(color: Colors.black,)
                                    ],
                                  ),
                                )
                            );
                          }
                      )
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () async {
                          final result =  await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CreateCategoryPage()));
                          if (result == 'added') {
                            setState(() {
                              getAppetizers();
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: Center(
                            child: Text('Create New Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        ),
                      )
                  )
                ]
              ),
            )
          ),
        ),
      );
  }
}




