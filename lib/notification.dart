


import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  
  static var shared = LocalNotification();

  FlutterLocalNotificationsPlugin fltrNotification = new FlutterLocalNotificationsPlugin();
  Function onSelectNotification;

  LocalNotification({Function onSelectNotification}) {
    this.onSelectNotification = onSelectNotification ?? ((String s) {
      print('notified...');
       return Future.value(s);
    });
    var androidInitialize = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSetings = new InitializationSettings(
      android: androidInitialize, 
      iOS: iOSInitialize
    );
   fltrNotification.initialize(initializationSetings, onSelectNotification: this.onSelectNotification);
  }
  

  Future showNotification({String title, String body}) async {
   var androidDetails = new AndroidNotificationDetails(
      "orderlivery_restaurant_channel_id", 
      "orderlivery_restaurant_channel_name", 
      "Orderlivery restaurant channel description", 
      importance: Importance.max,
      priority: Priority.high, 
    );
    var iOSDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(
      android: androidDetails, 
      iOS: iOSDetails
    );
    
    await fltrNotification.show(
      (new Random()).nextInt(1000), 
      title, body, generalNotificationDetails
    );
  }

}