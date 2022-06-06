import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'TwitterOAuth.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
import 'package:shared_preferences/shared_preferences.dart';



late v2.TwitterApi twitterApi;

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

  Future<void> _doHelloWorld() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bearer = dotenv.env['TwitterBearer']!;
    String consumerKey = dotenv.env['TwitterAPIKey']!;
    String consumerSecret = dotenv.env['TwitterAPISecretKey']!;
    String accessToken = prefs.getString('oauth_token')!;
    String accessTokenSecret = prefs.getString('oauth_secret')!;
    print(accessTokenSecret);
    twitterApi = v2.TwitterApi(
        bearerToken: bearer,
        oauthTokens: v2.OAuthTokens(
          consumerKey: consumerKey,
          consumerSecret: consumerSecret,
          accessToken: accessToken,
          accessTokenSecret: accessTokenSecret,
        )
    );
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
            ElevatedButton(onPressed: _doHelloWorld, child: const Text('do Hello,World')),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
