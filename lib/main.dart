import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: _buildTable(),
      ),
    );
  }

  Future<List<List<dynamic>>> _loadAssets() async {
    var snapshot = await rootBundle.loadString("assets/usbids.snapshot");
    const paragraphDelimiter = '# Syntax:\n';
    const eol = '\n';
    const fieldDelimiter = '  ';

    var paragraphs = snapshot.split(paragraphDelimiter);
    var simplifiedParagraphs = paragraphs.map((paragraph) {
      return paragraph.split(eol)
        ..removeWhere((line) => line.startsWith('#'))
        ..removeWhere((line) => line.trim().isEmpty);
    }).toList();
    var mainParagraph = simplifiedParagraphs[1];

    var ignoreTab = mainParagraph
      ..removeWhere((element) => element.startsWith('\t'));
    var companies = ignoreTab.map((e) => e
        .replaceFirst(fieldDelimiter, '&&')
        .replaceAll(fieldDelimiter, ' ')
        .replaceAll('&&', fieldDelimiter));
    return companies.map((e) => e.split(fieldDelimiter)).toList();
  }

  Widget _buildTable() {
    return FutureBuilder(
      future: _loadAssets(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) return Container();

        List<List<dynamic>> data = snapshot.data;
        return Table(
          children: data.map((row) {
            return TableRow(
              children: row.map((e) => Text(e.toString())).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}
