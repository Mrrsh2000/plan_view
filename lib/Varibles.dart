import 'dart:io';

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

String? name;
String header = '<!DOCTYPE html> <html lang=\"en\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>داده پرداز تدبیر فردا</title><link type=\"text/css\" href=\"css/style.css\" rel=\"stylesheet\"/><style>table, th, td {border: 1px solid black;padding:4px}</style></head><body style=\"text-align:center\"><table style=\"margin-left: auto;margin-right: auto;\"><thead><div>' +
    name! +
    '</div><tr><th>روزهای هفته \=\></th><th>شنبه</th><th>یک شنبه</th><th>دو شنبه</th><th>سه شنبه</th><th>چهارشنبه</th><th>پنج شنبه</th><th>جمعه</th></tr></thead><tbody>';
String footer = '</tbody></table></body></html>';