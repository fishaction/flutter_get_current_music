import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:shared_preferences/shared_preferences.dart';


class TwitterOAuth{
  late BuildContext context;
  TwitterOAuth(BuildContext _context){
    context = _context;
    //_launchURL(context,'twitter url');
  }
  Future<int> requestToken() async{
    await dotenv.load(fileName: '.env');
    final platform = oauth1.Platform(
      'https://api.twitter.com/oauth/request_token',
      'https://api.twitter.com/oauth/authorize',
      'https://api.twitter.com/oauth/access_token',
      oauth1.SignatureMethods.hmacSha1,
    );
    String apikey = dotenv.env['TwitterAPIKey'] ?? "";
    String apisecretkey = dotenv.env['TwitterAPISecretKey'] ?? "";
    final clientCredentials = oauth1.ClientCredentials(
      apikey,apisecretkey
    );
    final auth = oauth1.Authorization(clientCredentials, platform);
    oauth1.Credentials? tokenCredentials;
    await auth.requestTemporaryCredentials('checkthisgroove://callback').then((value){
      tokenCredentials = value.credentials;
    });
    String authUri = auth.getResourceOwnerAuthorizationURI(tokenCredentials!.token);
    await _launchURL(context, authUri);
    return 0;
  }

  Future<void> _launchURL(BuildContext context,String _url) async {
    try {
      await launch(
        _url,
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
  Future<void> initUniLinks() async {
    print("test");
    String? oauth_token;
    String? oauth_verifier;
    await uriLinkStream.listen((event) {
      Map<String, List<String>>? params = event?.queryParametersAll;
      oauth_token = params?['oauth_token']?.first;
      oauth_verifier = params?['oauth_verifier']?.first;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("oauth_token", oauth_token!);
    prefs.setString("oauth_verifier",oauth_verifier!);
    
  }
}