import 'package:flutter/material.dart';

import 'airtable_read_screen.dart';
import 'airtable_write_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Airtable',

      home: AirtableReadScreen(),

    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/read');
              },
              child: Text('Read Records'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create');
              },
              child: Text('Create Record'),
            ),
          ],
        ),
      ),
    );
  }
}
