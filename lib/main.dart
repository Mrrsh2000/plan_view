import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_view/api/request/weekly_request.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'varibles.dart';
import 'api/model/weekend_model.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter W',
      theme: ThemeData(
        fontFamily: "Vazir",
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  final columns = 11;
  final rows = 7;

  List<List<String>> _makeData() {
    final List<List<String>> output = [];
    for (int i = 0; i < columns; i++) {
      final List<String> row = [];
      for (int j = 0; j < rows; j++) {
        row.add(' ردیف ' + (j + 1).toString());
      }
      output.add(row);
    }
    return output;
  }

  List<List<TextEditingController>> _makeControllerData() {
    final List<List<TextEditingController>> output = [];
    for (int i = 0; i < columns; i++) {
      final List<TextEditingController> row = [];
      for (int j = 0; j < rows; j++) {
        row.add(TextEditingController());
      }
      output.add(row);
    }
    return output;
  }

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(data: _makeData(), controller: _makeControllerData());
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({required this.data, required this.controller});

  late List<List<String>> data;
  late List<List<TextEditingController>> controller;

  @override
  void initState() {
    loadWeekendDevice(11, 7, controller);
    getName(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داده پرداز تدبیر فردا'),
        actions: [
          TextButton(
            onPressed: () {
              getFile(context);
            },
            child: const Text(
              "نمایش وب",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              loadWeekendWeb(context, controller);
            },
            child: const Text(
              "بارگیری",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
              onPressed: () async {
                try {
                  final result =
                      await InternetAddress.lookup('weekly.kashandevops.ir');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await createMapData(11, 7, controller);
                    await saveWeekendWeb(11, 7, controller);
                    await sendFile(context);
                    await saveWeekendLocal(11, 7, controller);
                  }
                } on SocketException catch (_) {
                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: "اتصال ناموفق",
                    desc: "!لطفا اتصال اینترنتی خود را چک کنید",
                    buttons: [
                      DialogButton(
                        child: const Text(
                          "ذخیره در حافظه داخلی",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () async {
                          await saveWeekendLocal(11, 7, controller);
                          showToast("اطلاعات با موفقیت در حافظه ذخیره شدند",
                              Colors.green, Colors.black);
                          Navigator.pop(context);
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
              },
              child: const Text(
                "ذخیره",
                style: TextStyle(color: Colors.white),
              ))
        ],
        backgroundColor: Colors.indigo,
      ),
      body: StickyHeadersTable(
        columnsLength: 11,
        rowsLength: 7,
        columnsTitleBuilder: (i) => Text(timed[i]),
        rowsTitleBuilder: (i) => Text(weekend[i]),
        contentCellBuilder: (i, j) => Center(
          child: TextField(
            controller: controller[i][j],
            textAlign: TextAlign.center,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                border: OutlineInputBorder(),
                labelText: ""),
          ),
        ),
        legendCell: const Text('روز های هفته'),
      ),
    );
  }
}

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  return directory!.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dataCode = prefs.getInt('code')?.toString();
  return File('$path/plan$dataCode.html');
}

Future<File> writeCounter(String text) async {
  final file = await _localFile;
  final result = file.writeAsString(text);
  return result;
}

sendFile(context) async {
  final file = await _localFile;
  bool is_send = await WeekendServer.sendFileInWeekend(file.path);
  if (is_send) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "موفقیت آمیز",
      desc: "اطلاعات با موفقیت در سرور ذخیره شد",
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
  String? dataCode = prefs.getInt('code')?.toString();
  await launch("https://weekly.kashandevops.ir/media/media/plan$dataCode.html");
  // }
}


