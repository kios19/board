import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:desktop_window_utils/desktop_window_utils.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  runApp(MyApp());

  doWhenWindowReady(() {
    final initialSize = Size(1920, 1080);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
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
      home: MyHomePage(title: 'Batch Board'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var logger = Logger();
  var items;
  ScrollController _scrollController = new ScrollController();
  Timer timer;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: items.length,
          itemBuilder: (context, int index) {
            return new Padding(
              padding: EdgeInsets.only(top: 0),
              child: Card(
                color: Colors.black,
                child: ListTile(
                  leading: Icon(Icons.badge),
                  title: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          children: [
                            items[index]["disabled"] == 1
                                ? Padding(
                                    padding: EdgeInsets.only(right: 80),
                                    child: AvatarGlow(
                                      glowColor: Colors.red[800],
                                      endRadius: 70,
                                      duration: Duration(milliseconds: 2000),
                                      repeat: true,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red[800],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(right: 80),
                                    child: AvatarGlow(
                                      glowColor: Colors.greenAccent[700],
                                      endRadius: 70,
                                      duration: Duration(milliseconds: 2000),
                                      repeat: true,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent[700],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                            Text(
                              items[index]["item_name"],
                              style: GoogleFonts.codystar(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60,
                                  color: Colors.greenAccent[700]),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(left: 240),
                    child: Row(
                      children: [
                        Text(
                          "Batch No: ",
                          style: GoogleFonts.codystar(
                              //fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white70),
                        ),
                        Text(
                          items[index]["batch_number_series"] == null
                              ? "Not Filled"
                              : items[index]["batch_number_series"],
                          style: GoogleFonts.codystar(
                              //fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: Colors.amber),
                        )
                      ],
                    ),
                  ),
                  trailing: Text(
                    items[index]["end_of_life"] == null
                        ? "Not Filled"
                        : items[index]["end_of_life"],
                    style: GoogleFonts.codystar(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 45), (Timer t) => _backtoTop());
    DesktopWindow.setFullScreen(true);
    DesktopWindowUtils.useToolbar(isUsingToolbar: false);

    _start();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _start() async {
    try {
      Dio dio = new Dio();
      var response = await dio.get(
          'http://ethios.space/api/resource/Item/?fields=["*"]&limit_page_length=10000000',
          options: Options(headers: {
            HttpHeaders.authorizationHeader:
                'token e81c31b240137c1:e3cbd0221c7c0e2',
            'Authorization': 'token e81c31b240137c1:e3cbd0221c7c0e2',
            'Cookie':
                'sid=Guest; full_name=Guest; system_user=yes; user_image=; user_id=Guest'
          }));
      logger.i(response.data["data"]);
      setState(() {
        items = response.data["data"];
      });
      _startscrolling();
      //logger.i(kitu);
    } on DioError catch (e) {
      logger.e(e.message);
      logger.e(e.error);
      logger.e(e.response);
    } catch (e) {
      logger.e(e);
    }
  }

  _startscrolling() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0.0);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 300), curve: Curves.fastOutSlowIn);
    });
  }

  _backtoTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
    //(context as Element).reassemble();
    _startscrolling();
  }
}
