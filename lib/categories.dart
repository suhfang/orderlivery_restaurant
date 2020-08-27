
import 'package:Restaurant/create_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Stack(
              children: [
                Text('Please note: This will be the order the categories will appear in the app. We recommend starting with Appetizers at the top of the list, and desserts last. But it\'s up to you!'),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CreateCategoryPage()));
                    },
                    child: Container(
                      height: 50,
                      color: Colors.orange,
                      child: Center(
                        child: Text('CREATE NEW CATEGORY', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}