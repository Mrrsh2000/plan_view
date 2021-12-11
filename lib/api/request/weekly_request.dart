import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:plan_view/api/model/weekend_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekendServer {
  static Future<Weekend> getWeekendData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.get('code').toString();
    final response = await http
        .get(
          Uri.parse('https://weekly.kashandevops.ir/api/vi/user-file/$code'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      Map<String, dynamic> dataMap = Map<String, dynamic>.from(
          jsonDecode(utf8.decode(response.bodyBytes)));
      Weekend data = Weekend(
          title: dataMap['title'],
          html_file: dataMap['html_file'],
          success: dataMap['success'],
          data: dataMap['data'],
          code: dataMap['code']);
      // .map((data) => Weekend.fromJson(data))
      // .toList();

      return data;
    } else {
      Map<String, dynamic> dataMap = Map<String, dynamic>.from(
          jsonDecode(utf8.decode(response.bodyBytes)));
      Weekend data = Weekend(
          title: dataMap['title'],
          html_file: dataMap['html_file'],
          success: dataMap['success'],
          data: dataMap['data'],
          code: dataMap['code']);

      return data;
    }
  }

  static Future<bool> sendFileInWeekend(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = await prefs.get('name').toString();
    String code = await prefs.get('code').toString();
    String data = await prefs.get('data').toString();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://weekly.kashandevops.ir/api/vi/user-file/'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'html_file',
        File(path).path,
      ),
    );

    request.fields.addAll({'title': name, 'code': code, 'data': data});

    http.StreamedResponse response = await request.send().timeout(Duration(seconds: 20));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
