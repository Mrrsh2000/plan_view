import 'dart:io';

import 'package:expendable_fab/expendable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_view/api/request/weekly_request.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'varibles.dart';

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
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              String code = await prefs.get('code').toString();
              if (code == "null") {
                Alert(
                  context: context,
                  type: AlertType.error,
                  title: "خطا",
                  desc: "لطفا ابتدا فایل خود را ذخیره کنید",
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
                getFile(context);
              }
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
                    await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                          Future.delayed(const Duration(seconds: 2), () {}),
                          message: const Text('...لطفا منتظر بمانید')),
                    );
                    await sendFile(context);
                    await saveWeekendLocal(11, 7, controller);
                    await WeekendServer.getWeekendData();
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
      floatingActionButton: ExpendableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => getName(context, valid: true),
            icon: const Icon(Icons.create_rounded),
          ),
          ActionButton(
            onPressed: () => codeTextInputDialog(context, controller),
            icon: const Icon(Icons.code),
          ),
          ActionButton(
            onPressed: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              String name = prefs.get('name').toString();
              String code = prefs.get('code').toString();
              Alert(
                context: context,
                type: AlertType.info,
                title: "اطلاعات شما",
                desc: "نام شما : $name" +
                    "\n" +
                    "$code : کد یکتای شما",
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
            },
            icon: const Icon(Icons.article_rounded),
          ),
        ],
      ),
    );
  }
}
