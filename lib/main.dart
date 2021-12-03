import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import 'Varibles.dart';

void main() {
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
    _loadWeekend(11, 7, controller);
    _getName(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داده پرداز تدبیر فردا'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "وب",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              _loadWeekend(11, 7, controller);
            },
            child: const Text(
              "بارگزاری",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
              onPressed: () {
                _saveWeekend(11, 7, controller);
                ShowToast("اطلاعات با موفقیت ذخیره شدند", Colors.greenAccent,
                    Colors.green);
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

_saveWeekend(
    int value_i, int value_j, List<List<TextEditingController>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      await prefs.setString('counter$i$j', data[i][j].text);
    }
  }
}

_loadWeekend(
    int value_i, int value_j, List<List<TextEditingController>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      data[i][j].text = prefs.getString('counter$i$j')!;
    }
  }
}

_getName(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('is_name') == false || prefs.getBool('is_name') == null) {
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
        title: Text('نام خود را وارد کنید'),
        content: TextField(
          controller: _textFieldController,
          decoration: InputDecoration(hintText: "نام شما ..."),
        ),
        actions: [
          TextButton(
            child: Text('تایید'),
            onPressed: () async {
              if (_textFieldController!.text == "" ||
                  _textFieldController!.text == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "نام خود را وارد کنید!",
                    style: TextStyle(fontFamily: "Vazir"),
                    textAlign: TextAlign.end,
                  ),
                ));
              } else {
                await prefs.setBool('is_name', true);
                await prefs.setString('name', _textFieldController!.text);
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
