

import 'dart:convert';

//import 'package:Restaurant/categories.dart';
import 'package:Restaurant/add_list.dart';
import 'package:Restaurant/categories.dart';
import 'package:Restaurant/edit_combo_item.dart';
import 'package:Restaurant/edit_single_item.dart';
import 'package:Restaurant/single_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';



class QuantityAndPrice {
  int quantity;
  double price;
  String measurementLabel;
  QuantityAndPrice({this.quantity, this.price, this.measurementLabel});
}

class Category {
  String name;
  String id;
  List<Item> items;
  Category({this.name, this.id});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] as String, id: json['_id'] as String);
  }

}
class Item {

  String id;
  String name;
  String description;
  int flatPrice;
  List<QuantityAndPrice> quantitiesAndPrices;
  List<String> healthLabels;
  List<String> allergens;
  int startingPrice;
  String imageUrl;
  int cookingTime;
  List<ItemList> lists;
  List<String> individualItemIds;

  Item({
    this.id,
    this.name,
    this.description,
    this.flatPrice,
    this.quantitiesAndPrices,
    this.healthLabels,
    this.allergens,
    this.startingPrice,
    this.imageUrl,
    this.cookingTime,
    this.lists,
    this.individualItemIds
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    var qp_map_list = json['quantities_and_prices'] as List;
    List<QuantityAndPrice> qps = [];

//    if (qp_map_list.isNotEmpty) {
//        qp_map_list.forEach((element) {
//
//          qps.add(
//              QuantityAndPrice(
//                  quantity: element['quantity'] as int,
//                  price: element['price'] as double
//              )
//          );
//        });
//    }



    return Item(
        id: json['_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        individualItemIds: json['individual_items'].cast<String>(),
        flatPrice: json['flat_price'] as int,
//        quantitiesAndPrices: qps
    );
  }
}


class MenuItemsPage extends StatefulWidget {
  _MenuItemsPageState createState() => _MenuItemsPageState();
}

class _MenuItemsPageState extends State<MenuItemsPage> with TickerProviderStateMixin{
  TabController _controller;
  AnimationController _animationControllerOn;
  AnimationController _animationControllerOff;
  Animation _colorTweenBackgroundOn;
  Animation _colorTweenBackgroundOff;
  Animation _colorTweenForegroundOn;
  Animation _colorTweenForegroundOff;
  int _currentIndex = 0;
  int _prevControllerIndex = 0;
  double _aniValue = 0.0;
  double _prevAniValue = 0.0;
  List<Category> _titles = [];
  Color _foregroundOn = Colors.white;
  Color _foregroundOff = Colors.black;
  Color _backgroundOn = Colors.orange;
  Color _backgroundOff = Colors.grey[300];
  ScrollController _scrollController = new ScrollController();
  List _keys = [];
  bool _buttonTap = false;




  Future<List<Item>> getMenusForCategory(String category_id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/get-items-by-category',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'category_id': category_id
        }));
    Iterable items = json .decode(response.body)['menus'];
    return items.map((e) => Item.fromJson(e)).toList();
  }

  Future<void> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/get-categories',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        });
    Iterable categories = json.decode(response.body)['categories'];

    setState(() {
      _categories = categories.map((e) => Category.fromJson(e)).toList();
      _categories.forEach((element) async {
        var items = await getMenusForCategory(element.id);
        setState(() {
          element.items = items;
        });

      });
    });
    setState(() {
      for (int index = 0; index < _categories.length; index++) {
        _keys.add(new GlobalKey());
      }
      _controller = TabController(vsync: this, length: _categories.length);
      _controller.animation.addListener(_handleTabAnimation);
      _controller.addListener(_handleTabChange);

      _animationControllerOff =
          AnimationController(vsync: this, duration: Duration(milliseconds: 75));
      _animationControllerOff.value = 1.0;
      _colorTweenBackgroundOff =
          ColorTween(begin: _backgroundOn, end: _backgroundOff)
              .animate(_animationControllerOff);
      _colorTweenForegroundOff =
          ColorTween(begin: _foregroundOn, end: _foregroundOff)
              .animate(_animationControllerOff);

      _animationControllerOn =
          AnimationController(vsync: this, duration: Duration(milliseconds: 150));
      _animationControllerOn.value = 1.0;
      _colorTweenBackgroundOn =
          ColorTween(begin: _backgroundOff, end: _backgroundOn)
              .animate(_animationControllerOn);
      _colorTweenForegroundOn =
          ColorTween(begin: _foregroundOff, end: _foregroundOn)
              .animate(_animationControllerOn);
    });



  }


  List<Category> _categories = [];

  @override
  void initState() {
    _controller = TabController(vsync: this, length: _categories.length);
    getCategories();
    super.initState();


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('MENU ITEMS'),
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: Colors.white,
        body: Column(children: <Widget>[
          // this is the TabBar
          Container(
              height: 49.0,
              // this generates our tabs buttons
              child: ListView.builder(
                // this gives the TabBar a bounce effect when scrolling farther than it's size
                  physics: BouncingScrollPhysics(),
                  controller: _scrollController,
                  // make the list horizontal
                  scrollDirection: Axis.horizontal,
                  // number of tabs
                  itemCount: _categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      // each button's key
                        key: _keys[index],
                        // padding for the buttons
                        padding: EdgeInsets.all(6.0),
                        child: ButtonTheme(
                            child: AnimatedBuilder(
                              animation: _colorTweenBackgroundOn,
                              builder: (context, child) => FlatButton(
                                // get the color of the button's background (dependent of its state)
                                  color: _getBackgroundColor(index),
                                  // make the button a rectangle with round corners
                                  shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(7.0)),
                                  onPressed: () {
                                    setState(() {
                                      _buttonTap = true;
                                      // trigger the controller to change between Tab Views
                                      _controller.animateTo(index);
                                      // set the current index
                                      _setCurrentIndex(index);
                                      // scroll to the tapped button (needed if we tap the active button and it's not on its position)
                                      _scrollTo(index);
                                    });
                                  },
                                  child: Text(
                                    // get the icon
                                    _categories[index].name,
                                    // get the color of the icon (dependent of its state)
//                                    color: _getForegroundColor(index),
                                  )),
                            )));
                  })),
          Flexible(
            // this will host our Tab Views
              child: TabBarView(
                // and it is controlled by the controller
                controller: _controller,
                children: <Widget>[
                  // our Tab Views
                  ...(_categories
                  .map((category) {
                    if (category.items != null) {
                      return ListView(
                        children: [
                          ...category.items.map((item) {
                            return GestureDetector(
                              onTap: () {
                                if (item.individualItemIds.isEmpty) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) => EditSingleItemPage(id: item.id)
                                  ));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) => ComboItemPage(id: item.id)
                                  ));
                                }
                              },
                              child: Column(
                                children: [
                                  ListTile(
                                    trailing: Icon(LineIcons.edit),
                                    title: Text(item.name),
                                    subtitle: Text(item.description),
                                  ),
                                  Divider()
                                ],
                              ),
                            );
                          })
                        ],
                      );
                    } else {
                      return SizedBox();
                    }
                  })).toList()

                ],
              )),
        Padding(
          padding: EdgeInsets.only(bottom: 40),
          child:   Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  GestureDetector(
                      onTap: askMenuType,

                      child: Container(
                        height: 70,
                        child: Column(
                          children: [

                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              height: 50,

                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width - 50,
                              child: Center(
                                child: Text('CREATE NEW MENU ITEM', style: TextStyle(

//                                        fontWeight: FontWeight.bold,
                                    color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              )
          ),
        )
        ],
        ));
  }

  // runs during the switching tabs animation
  _handleTabAnimation() {
    // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
    _aniValue = _controller.animation.value;

    // if the button wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      // set the current tab index
      _setCurrentIndex(_aniValue.round());
    }

    // save the previous Animation Value
    _prevAniValue = _aniValue;
  }

  // runs when the displayed tab changes
  _handleTabChange() {
    // if a button was tapped, change the current index
    if (_buttonTap) _setCurrentIndex(_controller.index);

    // this resets the button tap
    if ((_controller.index == _prevControllerIndex) ||
        (_controller.index == _aniValue.round())) _buttonTap = false;

    // save the previous controller index
    _prevControllerIndex = _controller.index;
  }

  _setCurrentIndex(int index) {
    // if we're actually changing the index
    if (index != _currentIndex) {
      setState(() {
        // change the index
        _currentIndex = index;
      });

      // trigger the button animation
      _triggerAnimation();
      // scroll the TabBar to the correct position (if we have a scrollable bar)
      _scrollTo(index);
    }
  }

  _triggerAnimation() {
    // reset the animations so they're ready to go
    _animationControllerOn.reset();
    _animationControllerOff.reset();

    // run the animations!
    _animationControllerOn.forward();
    _animationControllerOff.forward();
  }

  _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the button we want to scroll to
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = _keys[0].currentContext.findRenderObject();
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = _keys[_categories.length - 1].currentContext.findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    // scroll the calculated ammount
    _scrollController.animateTo(offset + _scrollController.offset,
        duration: new Duration(milliseconds: 150), curve: Curves.easeInOut);
  }

  _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      // if it's active button
      return _colorTweenBackgroundOn.value;
    } else if (index == _prevControllerIndex) {
      // if it's the previous active button
      return _colorTweenBackgroundOff.value;
    } else {
      // if the button is inactive
      return _backgroundOff;
    }
  }

  _getForegroundColor(int index) {
    // the same as the above
    if (index == _currentIndex) {
      return _colorTweenForegroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenForegroundOff.value;
    } else {
      return _foregroundOff;
    }
  }

  void askMenuType() {
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
              Text('CHOOSE TYPE', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 5,),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
                child: Text('What type of menu do you want to create?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
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
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ComboItemPage()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange,
                              ),
                              height: 50,
                              child: Center(child: Text('Combo', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),),
                            ),
                          )
                      ),
                      SizedBox(width: 10,),
                      Expanded(

                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SingleItemPage()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange,
                              ),
                              height: 50,
                              child: Center(child: Text('A La Carte', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),),
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
}