import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String? destinationAddress;
  String? pickupAddress;
  LatLng? destination;
  LatLng? pickup;
  String? rideId;
  String? paymentMethod;
  String? riderName;
  String? riderPhone;
  String? tripId;

  TripDetails({
    this.destinationAddress,
    this.pickupAddress,
    this.destination,
    this.pickup,
    this.rideId,
    this.paymentMethod,
    this.riderName,
    this.riderPhone,
    this.tripId
  });

  // TripDetails.fromJson(Map<String, dynamic> json) {
  //   destinationAddress = json["destination_address"];
  //   pickupAddress = json["pickup_address"];
  //   destination = LatLng(json["destination"]["lat"], json["destination"]["long"]);
  //   pickup = LatLng(json["location"]["lat"], json["location"]["long"]);
  //   rideId =
  // }
}
