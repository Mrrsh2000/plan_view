import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_view/api/model/weekend_model.dart';
import 'package:plan_view/api/request/weekly_request.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

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

showToast(String msgText, Color back, Color text) {
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
String header =
    '<!DOCTYPE html> <html lang=\"en\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>داده پرداز تدبیر فردا</title><link type=\"text/css\" href=\"css/style.css\" rel=\"stylesheet\"/><style>table, th, td {border: 1px solid black;padding:4px}</style></head><body style=\"text-align:center\"><table style=\"margin-left: auto;margin-right: auto;\"><thead><div>' +
        name! +
        '</div><tr><th>روزهای هفته \=\></th><th>شنبه</th><th>یک شنبه</th><th>دو شنبه</th><th>سه شنبه</th><th>چهارشنبه</th><th>پنج شنبه</th><th>جمعه</th></tr></thead><tbody>';
String footer = '</tbody></table></body></html>';

createToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String code = prefs.get('code').toString();
  if (code == "null"){
    int code = Random().nextInt(10000000);
    await prefs.setString('code', code.toString());
  }
}

clearToken() {}

saveWeekendWeb(
  int value_i,
  int value_j,
  List<List<TextEditingController>> data,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await createToken();
  String html = "";
  name = await prefs.getString("name");
  html = header;
  for (int i = 0; i < value_i; i++) {
    html = html + "<tr>";
    html = html + ("<td>" + timed[i] + "</td>");
    for (int j = 0; j < value_j; j++) {
      html = html + ("<td>" + data[i][j].text + "</td>");
    }
    html = html + "/<tr>";
  }
  html = html + footer;
  await writeCounter(html);
}

saveWeekendLocal(
  int value_i,
  int value_j,
  List<List<TextEditingController>> data,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      await prefs.setString('counter$i$j', data[i][j].text);
    }
  }
}

loadWeekendWeb(context, List<List<TextEditingController>> controller) async {
  try {
    final result = await InternetAddress.lookup('weekly.kashandevops.ir');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      Alert(
        context: context,
        type: AlertType.none,
        title: "بارگیری دیتا",
        desc: "لطفا انتخاب کنید که از کجا دیتا بارگیری شود",
        buttons: [
          DialogButton(
            child: const Text(
              "سرور",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              Weekend response = await WeekendServer.getWeekendData();
              if (response.data != "False") {
                await loadMapData(response.data);
                await loadWeekendDevice(11, 7, controller);
                showToast("اطلاعات با موفقیت از سرور خوانده شد", Colors.green,
                    Colors.black);
              }
              Navigator.pop(context);
            },
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
          DialogButton(
            child: const Text(
              "حافظه داخلی",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              await loadWeekendDevice(11, 7, controller);
              Navigator.pop(context);
              showToast("اطلاعات با موفقیت از حافظه خوانده شد", Colors.green,
                  Colors.black);
            },
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(116, 116, 191, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0)
            ]),
          )
        ],
      ).show();
    }
  } on SocketException catch (_) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "اتصال ناموفق",
      desc: "!لطفا اتصال اینترنتی خود را چک کنید" +
          "\n" +
          "اگر میخواهید اطلاعات از حافظه گوشی بارگیری شود گزینه حافظه داخلی را بزنید",
      buttons: [
        DialogButton(
          child: const Center(
            child: Text(
              "حافظه داخلی",
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () async {
            await loadWeekendDevice(11, 7, controller);
            Navigator.pop(context);
            showToast("اطلاعات با موفقیت از حافظه ذخیره شدند", Colors.green,
                Colors.black);
          },
          color: const Color.fromRGBO(90, 116, 204, 1.0),
        ),
        DialogButton(
          child: const Text(
            "بازگشت",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        )
      ],
    ).show();
  }
}

loadWeekendDevice(
    int value_i, int value_j, List<List<TextEditingController>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      data[i][j].text = prefs.getString('counter$i$j')!;
    }
  }
}

createMapData(int value_i, int value_j,
    List<List<TextEditingController>> controller) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> key = [];
  List<String> value = [];
  String mapData = "";
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      key.add('$i$j');
    }
  }
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      value.add(controller[i][j].text);
    }
  }
  mapData += "{";
  for (int i = 0; i < key.length; i++) {
    mapData += "${key[i]}:${value[i]},";
  }
  mapData += "}";
  print(mapData);
  await prefs.setString('data', mapData);
}

loadMapData(String? data) async {
  List<String> str = data!.replaceAll("{", "").replaceAll("}", "").split(",");
  Map<String, dynamic> result = {};
  for (int i = 0; i < str.length - 1; i++) {
    List<String> s = str[i].split(":");
    result.putIfAbsent(s[0].trim(), () => s[1].trim());
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var reversed =
      Map.fromEntries(result.entries.map((e) => MapEntry(e.value, e.key)));
  for (var kv in reversed.entries) {
    await prefs.setString('counter${kv.value}', kv.key ?? "");
  }
}

getName(context, {bool? valid}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('is_name') == false || prefs.getBool('is_name') == null) {
    _displayTextInputDialog(context, prefs);
  }
  if (valid!) {
    _displayTextInputDialog(context, prefs);
  }
}

Future<void> _displayTextInputDialog(
    BuildContext context, SharedPreferences prefs) async {
  TextEditingController _textFieldController = new TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('نام خود را وارد کنید'),
        content: TextField(
          controller: _textFieldController,
          decoration: const InputDecoration(hintText: "نام شما ..."),
        ),
        actions: [
          TextButton(
            child: const Text('تایید'),
            onPressed: () async {
              if (_textFieldController.text == "" ||
                  _textFieldController.text == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "نام خود را وارد کنید!",
                    style: TextStyle(fontFamily: "Vazir"),
                    textAlign: TextAlign.end,
                  ),
                ));
              } else {
                await prefs.setBool('is_name', true);
                await prefs.setString('name', _textFieldController.text);
                _textFieldController.text = "";
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "نام شما با موفقیت ذخیره شد!",
                    style: TextStyle(fontFamily: "Vazir"),
                    textAlign: TextAlign.end,
                  ),
                ));
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> codeTextInputDialog(BuildContext context, List<List<TextEditingController>> controller) async {
  TextEditingController _textFieldController = TextEditingController();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(': کد یکتای مورد نظر خود را وارد کنید'),
        content: TextField(
          controller: _textFieldController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: const InputDecoration(hintText: "... کد شما"),
        ),
        actions: [
          TextButton(
            child: const Text('تایید'),
            onPressed: () async {
              if (_textFieldController.text == "" ||
                  _textFieldController.text.length != 7) {
                showToast(
                    "کد وارد شده صحیح نمی باشد", Colors.red, Colors.black);
              } else {
                Weekend response = await WeekendServer.getWeekendData(code: _textFieldController.text);
                if(response.success ?? false){
                  await loadMapData(response.data);
                  await loadWeekendDevice(11, 7, controller);
                  showToast("اطلاعات با موفقیت از سرور خوانده شد", Colors.green,
                      Colors.black);
                  _textFieldController.text = "";
                  Navigator.pop(context);
                }else{
                  showToast(
                      "کد وارد شده در سرور موجود نیست", Colors.red, Colors.black);
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  return directory!.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dataCode = prefs.getString('code')?.toString();
  return File('$path/plan$dataCode.html');
}

Future<File> writeCounter(String text) async {
  final file = await _localFile;
  final result = file.writeAsString(text);
  return result;
}

sendFile(context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String code = prefs.get('code').toString();
  final file = await _localFile;
  bool is_send = await WeekendServer.sendFileInWeekend(file.path);
  if (is_send) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "موفقیت آمیز",
      desc: "اطلاعات با موفقیت در سرور ذخیره شد" +
      "\n" + "$code : کد یکتای شما",
      buttons: [
        DialogButton(
          child: const Center(
            child: Text(
              "کپی کردن کد",
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () {
            showToast(
                "کد یکتا کپی شد", Colors.green, Colors.black);
            Clipboard.setData(ClipboardData(text: code));
          },
          color: const Color.fromRGBO(90, 116, 204, 1.0),
        ),
        DialogButton(
          child: const Text(
            "بازگشت",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        )
      ],
    ).show();
  } else {
    Alert(
      context: context,
      type: AlertType.error,
      title: "خطا در ارسال",
      desc: "!ارسال اطلاعات سمت سرور با خطا مواجه شد",
      buttons: [
        DialogButton(
          child: const Text(
            "بازگشت",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        )
      ],
    ).show();
  }
}

getFile(context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? html_file = "https://weekly.kashandevops.ir" + prefs.getString('html_file').toString();
  await launch(html_file);
  // }
}