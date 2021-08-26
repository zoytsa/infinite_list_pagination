import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

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
        child: ListView.builder(
          itemBuilder: (context, index) {
            final document = documents[index];
            return documentInfoListTile3(document);
            // return ListTile(
            //   title: Text(document.number),
            //   subtitle: Text(document.date),
            //   trailing: Text(
            //     document.editedDate,
            //     style: TextStyle(color: Colors.green),
            //   ),
            // );
          },
          //  separatorBuilder: (context, index) => Divider(),
          itemCount: documents.length,
        ),
      ),
      floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          shape: CircleBorder(),
          //  childPadding: const EdgeInsets.symmetric(vertical: 5),
          overlayOpacity: 0,
          //childrenButtonSize: 60,
          spacing: 6,
          animationSpeed: 200, // openCloseDial: isDialOpen,
          childPadding: EdgeInsets.all(5),
          spaceBetweenChildren: 4,
          //  icon: Icons.share,
          backgroundColor: Colors.lightBlue[400],
          children: [
            SpeedDialChild(
              //child: Icon(Icons.arrow_downward_sharp,
              child: Icon(Icons.keyboard_arrow_down_outlined,
                  color: Colors.lightBlue[400]),
              // label: 'Social Network',
              backgroundColor: Colors.white,
              //  foregroundColor: Colors.white70,
              onTap: () {/* Do someting */},
            ),
            SpeedDialChild(
              child: Icon(Icons.keyboard_arrow_up_outlined,
                  color: Colors.lightBlue[400]),
              // label: 'Social Network',
              backgroundColor: Colors.white,
              onTap: () {/* Do something */},
            ),
            // SpeedDialChild(
            //   child: Icon(Icons.chat),
            //   label: 'Message',
            //   backgroundColor: Colors.amberAccent,
            //   onTap: () {/* Do something */},
            // ),
          ]),
    );
  }

  Widget documentInfoListTile(DocumentInfo document) {
    return ListTile(
      title: Text(document.number),
      subtitle: Text(document.date),
      trailing: Text(
        document.editedDate,
        style: TextStyle(color: Colors.green),
      ),
    );
    // return Container();
  }

  Widget documentInfoListTile3(DocumentInfo document) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Номер: ${document.number}'),
            subtitle: Text('Дата: ${document.date}'),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'open',
                    child: Text('Открыть'),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Редактировать'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить'),
                  )
                ];
              },
              onSelected: (String value) =>
                  actionPopUpItemSelected(value, document.number),
            ),
          ),
          // Divider(
          //   height: 1.0,
          // ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text(document.operationId.toString()),
            subtitle: Text('Товар 1: Кока-кола 1 л, 5 ед.'),
          )
        ],
      ),
    );
  }

  Widget documentInfoListTile2(DocumentInfo document) {
    return ListTile(
      title: Text('Номер: ${document.number}'),
      subtitle: Text('Дата: ${document.date}'),
      trailing: PopupMenuButton(
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 'open',
              child: Text('Открыть'),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Text('Редактировать'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Удалить'),
            )
          ];
        },
        onSelected: (String value) =>
            actionPopUpItemSelected(value, document.number),
      ),
    );
  }

  void actionPopUpItemSelected(String value, String name) {
    //_scaffoldkey.currentState.hideCurrentSnackBar();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    String message;
    if (value == 'edit') {
      message = 'You selected edit for $name';
    } else if (value == 'delete') {
      message = 'You selected delete for $name';
    } else {
      message = 'Not implemented';
    }
    // final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepOrange[100],
        content: Text(message),
      ),
    );
    // _scaffoldkey.currentState.showSnackBar(snackBar);
  }
}

// class FancyFab extends StatefulWidget {
//   final Function() onPressed;
//   final String tooltip;
//   final IconData icon;

//   FancyFab({required this.onPressed, required this.tooltip, required this.icon});

//   @override
//   _FancyFabState createState() => _FancyFabState();
// }

// class _FancyFabState extends State<FancyFab>
//     with SingleTickerProviderStateMixin {
//   bool isOpened = false;
//   AnimationController _animationController;
//  Animation<Color> _buttonColor;
//    Animation<double> _animateIcon;
//    Animation<double> _translateButton;
//   Curve _curve = Curves.easeOut;
//   double _fabHeight = 56.0;

//   @override
//   initState() {
//     _animationController =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 500))
//           ..addListener(() {
//             setState(() {});
//           });
//     _animateIcon =
//         Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
//      _buttonColor = ColorTween(
//       begin: Colors.blue,
//       end: Colors.red,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Interval(
//         0.00,
//         1.00,
//         curve: Curves.linear,
//       ),
//     ));
//     _translateButton = Tween<double>(
//       begin: _fabHeight,
//       end: -14.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Interval(
//         0.0,
//         0.75,
//         curve: _curve,
//       ),
//     ));
//     super.initState();
//   }

//   @override
//   dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   animate() {
//     if (!isOpened) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//     isOpened = !isOpened;
//   }

//   Widget add() {
//     return Container(
//       child: FloatingActionButton(
//         onPressed: null,
//         tooltip: 'Add',
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget image() {
//     return Container(
//       child: FloatingActionButton(
//         onPressed: null,
//         tooltip: 'Image',
//         child: Icon(Icons.image),
//       ),
//     );
//   }

//   Widget inbox() {
//     return Container(
//       child: FloatingActionButton(
//         onPressed: null,
//         tooltip: 'Inbox',
//         child: Icon(Icons.inbox),
//       ),
//     );
//   }

//   Widget toggle() {
//     return Container(
//       child: FloatingActionButton(
//         backgroundColor: _buttonColor.value,
//         onPressed: animate,
//         tooltip: 'Toggle',
//         child: AnimatedIcon(
//           icon: AnimatedIcons.menu_close,
//           progress: _animateIcon,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: <Widget>[
//         Transform(
//           transform: Matrix4.translationValues(
//             0.0,
//             _translateButton.value * 3.0,
//             0.0,
//           ),
//           child: add(),
//         ),
//         Transform(
//           transform: Matrix4.translationValues(
//             0.0,
//             _translateButton.value * 2.0,
//             0.0,
//           ),
//           child: image(),
//         ),
//         Transform(
//           transform: Matrix4.translationValues(
//             0.0,
//             _translateButton.value,
//             0.0,
//           ),
//           child: inbox(),
//         ),
//         toggle(),
//       ],
//     );
//   }
// }