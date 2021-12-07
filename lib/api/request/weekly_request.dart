import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeekendServer {
  static Future<bool> SendFileInWeekend(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.get('name').toString();
    final file = File(path);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://weekly.kashandevops.ir/api/vi/user-file/'),
    );
    request.fields.addAll({'title': name});
    request.files.add(await http.MultipartFile.fromPath(
      'html_file',
      file.path,
    ),);

    http.StreamedResponse response =
        await request.send().timeout(Duration(seconds: 20));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Weekend data = (jsonDecode(utf8.decode(response.)))
      //     .map((data) => Weekend.fromJson(data))
      //     .toList();
      // String url_file = prefs.setString('url_file',response.);
      return true;
    } else {
      return false;
    }
  }
}
