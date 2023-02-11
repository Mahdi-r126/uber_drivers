import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

late FirebaseUser currentFirebaseUser;
late bool statusg;
late DatabaseReference tripRequestRef;
late StreamSubscription<Position> homeTabPositionStream;

