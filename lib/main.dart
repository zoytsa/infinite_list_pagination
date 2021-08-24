import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_list_pagination/model/documents_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final String dct_username = 'weblink';
final String dct_password = 'weblinK312!';
final String dct_basicAuth =
    'Basic ' + base64Encode(utf8.encode('$dct_username:$dct_password'));

final Map<String, String> dct_headers = {
  'Content-Type': 'application/json; charset=UTF-8',
  // 'accept': 'application/json',
  'authorization': dct_basicAuth
};

void main() {
  //HttpOverrides.global = new MyHttpOverrides();

  runApp(MyApp());
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 1;
  String lastElementId = "";
  String maxElementId = "";

  late int totalPages;

  List<DocumentInfo> documents = [];

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<bool> getListOfDocuments({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      lastElementId = "";
    } else {
      if (currentPage >= totalPages ||
          lastElementId.compareTo(maxElementId) == 1) {
        // ???!!! str1.compareTo(str2) ==1
        refreshController.loadNoData();
        return false;
      }
    }

    // final Uri uri = Uri.parse(
    //     "https://api.instantwebtools.net/v1/passenger?page=$currentPage&size=10");

    final Uri uri = Uri.parse(
        "http://212.112.116.229:7788/weblink/hs/api/documents/1?last_element_id=$lastElementId&size=50");

    final response = await http.get(uri, headers: dct_headers);

    if (response.statusCode == 200) {
      final result = listOfDocumentsFromJson(response.body);

      if (isRefresh) {
        documents = result.data;
      } else {
        documents.addAll(result.data);
      }

      currentPage++;
      lastElementId = result.lastElementId;
      totalPages = result.totalPages;
      maxElementId = result.maxElementId;

      // print(response.body);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infinite List Pagination"),
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: () async {
          final result = await getListOfDocuments(isRefresh: true);
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await getListOfDocuments();
          if (result) {
            refreshController.loadComplete();
          } else {
            refreshController.loadFailed();
          }
        },
        child: ListView.separated(
          itemBuilder: (context, index) {
            final document = documents[index];

            return ListTile(
              title: Text(document.number),
              subtitle: Text(document.date),
              trailing: Text(
                document.editedDate,
                style: TextStyle(color: Colors.green),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: documents.length,
        ),
      ),
    );
  }
}
