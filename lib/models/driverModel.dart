import 'package:firebase_database/firebase_database.dart';

class DriverModels {
  String? fullName;
  String? email;
  String? phone;
  String? id;
  String? carModel;
  String? carColor;
  String? vehicleNumber;

  DriverModels({
    this.fullName,
    this.email,
    this.phone,
    this.id,
    this.carModel,
    this.carColor,
    this.vehicleNumber,
  });

  DriverModels.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullname'];
    carColor = snapshot.value['car_color'];
    carModel = snapshot.value['car_model'];
    vehicleNumber = snapshot.value['carModel'];
    
    
  }
}
