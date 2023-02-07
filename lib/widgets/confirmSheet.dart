import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uber_drivers/widgets/Text.dart';
import 'package:uber_drivers/widgets/taxiButton.dart';

import '../brand_colors.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final Function()? onPressed;
  bool isOn;
  ConfirmSheet({required this.title,required this.isOn, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            blurRadius: 15,
            spreadRadius: 5,
            color: Colors.black26,
            offset: Offset(0.7, 0.7))
      ]),
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            PersianTextField(
              text: title,
              textSize: 18,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Container(
                    child: TaxiButton(
                      title: "تایید",
                      color: (isOn==true)?BrandColors.colorGreen:Colors.red,
                      onPressed: onPressed,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    child: TaxiButton(
                      title: "بازگشت",
                      color: Colors.grey,
                      onPressed: () {
                        onPressed;
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
