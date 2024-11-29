// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

showMessage(message) {
  return Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    // timeInSecForIosWeb: 1,
    // backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0
  );
}