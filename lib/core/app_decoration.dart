


import 'package:flutter/material.dart';

class AppDecoration {
  static InputDecoration commonInputDecoration(
      {Widget? prefixIcon,
        Widget? suffixIcon,
        String? hintText,
        BuildContext? context,
        String? labelText,
        TextStyle? hintStyle,
        double horizontalPadding=16,
        double verticalPadding =15,
        Color  fillColor  = Colors.white,
        double? radiusBorder}) {
    return InputDecoration(
      fillColor: fillColor,
      filled: true,

      hintText: hintText,
      contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding ,vertical: verticalPadding),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusBorder ?? 10),
        borderSide: BorderSide(
          color: Colors.blueGrey,
          width: 1,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusBorder ?? 10),
        borderSide: BorderSide(
          color:Colors.grey,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusBorder ?? 10),
        borderSide: BorderSide(
          color: Colors.blueGrey,
          width: 1.5,
        ),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

    );
  }
}