import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final List weekend = [
  'شنبه',
  'یکشنبه',
  'دوشنبه',
  'سهشنبه',
  'چهار شنبه',
  'پنج شنبه',
  'جمعه'
];
final List timed = [
  '8-9',
  '9-10',
  '10-11',
  '11-12',
  '12-13',
  '13-14',
  '14-15',
  '15-16',
  '16-17',
  '17-18',
  '18-19'
];

ShowToast(String msgText, Color back, Color text) {
  return Fluttertoast.showToast(
      msg: msgText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: back,
      textColor: text,
      fontSize: 16.0);
}
