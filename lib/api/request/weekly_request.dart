import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:plan_view/api/model/Weekend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekendServer {
  static Future<Weekend> GetWeekendData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.get('code').toString();
    final response = await http
        .get(
          Uri.parse('http://127.0.0.1:8000/api/vi/user-file/$code'),
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      Weekend data = (jsonDecode(utf8.decode(response.bodyBytes)))
          .map((data) => Weekend.fromJson(data))
          .toList();

      return data;
    } else {
      Weekend data = (jsonDecode(utf8.decode(response.bodyBytes)))
          .map((data) => Weekend.fromJson(data))
          .toList();

      return data;
    }
  }

  static Future<bool> SendFileInWeekend(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.get('name').toString();
    String code = prefs.get('code').toString();
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/vi/user-file/'));
    request.fields.addAll({'title': name, 'code': code});
    var multipartFile = http.MultipartFile.fromBytes(
      'html_file',
      File(path).readAsBytesSync(),
    );

    request.files.add(multipartFile);

    http.StreamedResponse response =
        await request.send().timeout(Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
