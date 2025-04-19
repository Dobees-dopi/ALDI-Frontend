import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _printFCMToken();
    _loadUsername();

    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (Globals.userName.isEmpty) {
          Get.offAllNamed('firststep');
        } else {
          print(Globals.userName);
          Get.offAllNamed('diary');
        }
      }
    });

    _loadAnimation();

    // 페이지 로딩 직후 키보드를 숨깁니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> updateFCMToken() async {
    const String url = 'https://mvp-iot.cahlp.kr/fcm/update/';
    const Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final prefs = await SharedPreferences.getInstance();
    int pkId = prefs.getInt('FcmToken_id') ?? 0;

    Map<String, String> body = {
      'pk_id': pkId.toString(),
      'username': Globals.userName,
      'token': Globals.fcmurl,
    };

    try {
      print(pkId.toString());
      print(Globals.userName);
      print(Globals.fcmurl);

      http.Response response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        String decodedResponseBody = utf8.decode(response.bodyBytes);
        print('Data updated successfully: $decodedResponseBody');
      } else {
        String decodedErrorBody = utf8.decode(response.bodyBytes);
        print('Failed to update data. Status code: $decodedErrorBody');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    if (storedUsername != null) {
      Globals.userName = storedUsername;
      print("dkfmsfkdmfkffdf");
      print(Globals.userName);
    }
  }

  Future<void> _loadAnimation() async {
    var composition = await LottieComposition.fromByteData(
      await rootBundle.load('assets/animations/white_txt.json'),
    );
    _controller.duration = composition.duration;
    _controller.forward();
  }

  void _printFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      Globals.fcmurl = fcmToken;
    } else {
      // Handle the error case, like logging an error or setting a default value
    }

    print('FCM Token: $fcmToken');
    updateFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 86, 120, 255),
                  Colors.lightBlueAccent
                ],
              ),
            ),
            child:  Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, // ← 이걸 없애라는 의미
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
