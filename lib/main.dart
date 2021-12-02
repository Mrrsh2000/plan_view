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
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Table'),
        actions: [
          TextButton(
            onPressed: () {
              _loadWeekend(11, 7, controller);
            },
            child: Text(
              "بارگزاری",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
              onPressed: () {
                _saveWeekend(11, 7, controller);
              },
              child: Text(
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
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: controller[i][j].text.toString().isEmpty
                    ? ""
                    : controller[i][j].text.toString()),
          ),
        ),
        legendCell: Text('روز های هفته'),
      ),
    );
  }
}

_saveWeekend(
    int value_i, int value_j, List<List<TextEditingController>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      print('counter$i$j');
      print('data => ' + data[i][j].text.toString());
      await prefs.setString('counter$i$j', data[i][j].text);
    }
  }
}

_loadWeekend(
    int value_i, int value_j, List<List<TextEditingController>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < value_i; i++) {
    for (int j = 0; j < value_j; j++) {
      print('counter$i$j');
      print('data => ' + data[i][j].text.toString());
      data[i][j].text = prefs.getString('counter$i$j')!;
    }
  }
}