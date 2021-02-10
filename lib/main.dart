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
  // TODO load date from env
  final date = 'Feb 10, 2021';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Updated at $date'),
      ),
      body: _buildBody(),
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

  Widget _buildBody() {
    return FutureBuilder(
      future: _loadAssets(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<List<dynamic>> data = snapshot.data;
        return Column(
          children: [
            Text('Companies ${data.length}'),
            Expanded(
              child: _buildTable(data),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable(List<List> data) {
    return Scrollbar(
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Table(
          children: data.map((row) {
            return TableRow(
              children: row.map((e) => Text(e.toString())).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
