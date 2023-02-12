import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers/globalVar.dart';
import 'package:uber_drivers/helpers/requestHelper.dart';

import '../models/directionDetails.dart';

class HelperMethods {
  static Future<DirectionDetails?> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248c4e8a8c9e2954ec8914d787627b2cdef&start=${startPosition.longitude},${startPosition.latitude}&end=${endPosition.longitude},${endPosition.latitude}";
    var response = await RequestHelper.getRequset(url);

    if (response == 'failed') {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.distance =
        response['features'][0]['properties']['segments'][0]['distance'];
    directionDetails.duration =
        response['features'][0]['properties']['segments'][0]['duration'];
    directionDetails.points =
        response['features'][0]['geometry']['coordinates'];

    return directionDetails;
  }

  static int calculateMoney(DirectionDetails details) {
    double baseMoney = 4;
    double distance = (details.distance! / 1000) * 0.7;
    double duration = (details.duration! / 60) * 0.3;
    double totalMoney = baseMoney + distance + duration;
    return totalMoney.round();
  }

  static int calculateDistance(DirectionDetails details) {
    double distance = details.distance! / 1000;
    return distance.round();
  }

  static int calculateDuration(String duration) {
    if (duration == "") {
      return 0;
    }
    int minute = (double.parse(duration) / 60).round();
    return minute;
  }

  static String splitDisplayName(String name) {
    if (name != null) {
      final split = name.split(',');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };

      return "${values[0]},،${values[1]}";
    } else {
      return "";
    }
  }

  static String replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    return input;
  }

  static void disableHomeTabLocationUpdates() {
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void enableHomeTabLocationUpdates() {
    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);
  }
}
