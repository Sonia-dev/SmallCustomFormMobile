import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import 'airtable_write_screen.dart';

class AirtableReadScreen extends StatefulWidget {
  @override
  _AirtableReadScreenState createState() => _AirtableReadScreenState();
}

class _AirtableReadScreenState extends State<AirtableReadScreen> {
  List<dynamic> records = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.airtable.com/v0/appBUGxMnsQXrWaoB/employee'),
      headers: {
        'Authorization': 'Bearer patpiEEEbvzq8LTGd.ea3a6e2ecf358577515b6b7fc3d9a52ea26e26ac09d5a22f30cb222038a22a69',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        records = json.decode(response.body)['records'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data';
      });
    }
  }

  void navigateToAddEmployeeScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AirtableCreateScreen()),
    );

    if (result == true) {
      fetchRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Employees'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: SpinKitDoubleBounce(color: Colors.yellow))
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : records.isEmpty
            ? Center(child: Text('No Data'))
            : ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index]['fields'];
            final attachment = record['attachment'] != null && record['attachment'].isNotEmpty
                ? record['attachment'][0]['url']
                : null;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: ListTile(
                leading: attachment != null
                    ? ShimmerImage(url: attachment)
                    : Icon(Icons.person, size: 80, color: Colors.grey),
                title: Text(record['firstName'] ?? 'No Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record['name'] ?? 'No Description'),
                    if (record['bio'] != null) Text(record['bio']),
                    if (record['department'] != null) Text('Department: ${record['department']}'),
                    if (record['skills'] != null) Text('Skills: ${record['skills'].join(', ')}'),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: navigateToAddEmployeeScreen,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ShimmerImage extends StatelessWidget {
  final String url;

  ShimmerImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: precacheImage(NetworkImage(url), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Image.network(url, width: 80, height: 80, fit: BoxFit.cover);
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 50,
              height: 50,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
