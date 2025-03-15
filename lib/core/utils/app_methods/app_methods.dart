import 'package:flutter/material.dart';

class DMAppMethods {
  //To show snackbar
  static void showSnackBar(context, message, clr) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      // margin: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      backgroundColor: clr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
        // side: const BorderSide(color: AppColors.kSnackBarBorderColor)
      ),
      // behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      content: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white)),
      duration: const Duration(seconds: 2),
    ));
  }
}
