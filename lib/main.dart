import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'TwitterOAuth.dart';


void main() async{
  await dotenv.load(fileName: ".env");
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _musicTitle = "";

  static const MethodChannel _methodChannel = MethodChannel("com.example.methodchannel/interop");
  static const String startService = "startService";

  Future<void> _startService() async{
    await _methodChannel.invokeMethod(startService);
  }

  Future<String> _onUpdateMusic() async{
    return await _methodChannel.invokeMethod("onUpdateMusic");
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async{
    switch(call.method){
      case 'onUpdateMusic':
        print(call.arguments);
        setState((){
          _musicTitle = call.arguments;
        });
        return Future.value('ok');
      default:
        print('unknown method ${call.method}');
        throw MissingPluginException();
        break;
    }
  }

  @override
  initState(){
    super.initState();
    _methodChannel.setMethodCallHandler(_platformCallHandler);
    TwitterOAuth(context).initUniLinks();
  }

  void _none(){
    TwitterOAuth(context).requestToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Music : $_musicTitle',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(onPressed:_startService,
                child:const Text("Start Service")
            ),
            ElevatedButton(onPressed: _none,child: const Text("Twitter Login")),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
