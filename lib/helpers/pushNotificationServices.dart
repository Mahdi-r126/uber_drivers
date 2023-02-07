// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PushNotificationService {
//   final FirebaseMessaging fcm = FirebaseMessaging();
//   Future initialize() async {
//     fcm.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         print("onMessage: $message");
//       },
//       onLaunch: (Map<String, dynamic> message) async {
//         print("onLaunch: $message");
//       },
//       onResume: (Map<String, dynamic> message) async {
//         print("onResume: $message");
//       },
//     );
//   }

//   Future getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String id = prefs.getString('id');
//     String token = await fcm.getToken();
//     print("Token: $token");

//     DatabaseReference tokenRef =
//         FirebaseDatabase.instance.reference().child("/drivers/${id}/token");

//     fcm.subscribeToTopic('alldrivers');
//     fcm.subscribeToTopic("allusers");
//   }
// }
