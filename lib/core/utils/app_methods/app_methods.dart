import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DMAppMethods {
  //To show snackbar , can do any modifications here
  static void showSnackBar(context, message, clr) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: clr,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: DMColors.darkTextColor, fontSize: 14),
      ),
      duration: const Duration(seconds: 2),
    ));
  }
}
