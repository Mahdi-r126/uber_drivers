import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_drivers/models/driverModel.dart';

late FirebaseUser currentFirebaseUser;
late bool statusg;
late DatabaseReference tripRequestRef;
late StreamSubscription<Position> homeTabPositionStream;
late Position currentPosition;
late DatabaseReference acceptTripRef;
late DriverModels currentDriverInfo;
