import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:umi/theme.dart';

class HarwareLoginPage extends StatefulWidget {
  const HarwareLoginPage({Key? key}) : super(key: key);

  @override
  _HarwareLoginPageState createState() => _HarwareLoginPageState();
}

class _HarwareLoginPageState extends State<HarwareLoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false; // 비밀번호 숨김/표시 상태

  Future<void> _login(String username, String password) async {
    final url = "https://${Globals.baseUrl}/login/";

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? csrfToken = prefs.getString('csrftoken'); // Retrieve stored token

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "username": username,
        "password": password,
      }),
    );

    final responseData = json.decode(response.body);

    if (responseData['ret'] == 'success') {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    //  Get.snackbar("로그인 성공", "로그인에 성공하셨습니다");

      print("Login successful");

      print(response.body);

      // Extract token and username from the response
      final String token = responseData['token'];
      final String userName = responseData['username'];

      // Overwrite the userName in Globals with the new one from the response
      Globals.userName = userName;
      postFCMToken();
      await prefs.setString('token', token);
      await prefs.setString('username', userName);
      Get.offAllNamed('/home');
      // Cookie parsing and storage
      if (response.headers['set-cookie'] != null) {
        final cookie = response.headers['set-cookie']!;
        await prefs.setString('cookie', cookie);
        print("Cookie saved: $cookie");

        // Parsing and storing CSRFTOKEN
        final csrfToken = RegExp('csrftoken=([^;]+)').firstMatch(cookie)?.group(1);
        if (csrfToken != null) {
          await prefs.setString('csrftoken', csrfToken);
          print("CSRFTOKEN saved: $csrfToken");
        }
      }
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar("로그인 실패", "로그인에 실패하셨습니다");
      print("Error logging in: ${response.body}");
    }
  }

  Future<void> postFCMToken() async {
    const String url = 'https://mvp-iot.cahlp.kr/fcm/add/';
    const Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    Map<String, String> body = {
      'username': Globals.userName, // Assuming Globals.userName is a String
      'token': Globals.fcmurl, // Assuming Globals.fcmurl is a String
    };

    try {
      print(Globals.userName);
      print(Globals.fcmurl);
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = json.decode(response.body);
        print('Data posted successfully: ${response.body}');

        // Extract and save FcmToken_id
        if (responseData.containsKey('data') &&
            responseData['data'].containsKey('FcmToken_id')) {
          final fcmTokenId = responseData['data']['FcmToken_id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('FcmToken_id', fcmTokenId);
          print('FcmToken_id saved: $fcmTokenId');
        } else {
          print('FcmToken_id not found in the response');
        }
      } else {
        print('Failed to post data. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(); // Remove all previous routes and navigate to home page
        return false; // Prevent the default behavior (i.e., exiting the app)
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.transparent, // Set scaffold background to transparent
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 240, 240, 240), // 원하는 테두리 색상
                  width: 2, // 원하는 테두리 두께
                ),
              ),
            ),
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Temas.blackicon),
                onPressed: () => Get.back(),
              ),
              centerTitle: true,
              title: const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Color.fromARGB(255, 255, 255, 255), // Make AppBar transparent
              elevation: 0,
            ),
          ),
        ),
        body: 
        Container(
          color: Colors.grey[100], // Set body background to grey
          padding: const EdgeInsets.only(right: 40, left: 40,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
           Container(
  height: 60, // Set the desired height
  child: TextField(
    controller: usernameController,
    decoration: InputDecoration(
      labelText: '이름',
      filled: true,
      fillColor: Colors.white, // 필드 내부 색상
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0), // Increase vertical padding to adjust height
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Temas.maincolor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      labelStyle: const TextStyle(
        color: Colors.black38,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  ),
),

              const SizedBox(height: 20),
            Container(
  height: 60, // Set the desired height
  child: TextField(
    controller: passwordController,
    obscureText: !_passwordVisible, // 비밀번호 숨김 여부
    decoration: InputDecoration(
      labelText: "비밀번호",
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Temas.maincolor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      labelStyle: const TextStyle(
        color: Colors.black38,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0), // Adjust vertical padding to increase height
      suffixIcon: IconButton(
        icon: Icon(
          // 아이콘을 바꿔서 비밀번호 표시/숨김 상태를 나타냅니다.
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.black38,
        ),
        onPressed: () {
          // 아이콘 버튼 클릭 시 비밀번호 표시/숨김 상태를 변경합니다.
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
      ),
    ),
  ),

),

              SizedBox(height: 60), // 최대한의 공간을 만들어 줍니다.
              GestureDetector(
                onTap: () {
                  Get.toNamed('/hardwarejoin');
                },
                child: Text(
                  "처음이신가요?",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(Globals.userName, "test");
                  Get.offAllNamed('diary');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Temas.maincolor,
              
                    borderRadius: BorderRadius.circular(25.0),
                       boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 0), // 그림자의 위치 조정
          ),
        ],
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w500,
                      fontSize: 14
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/passreset');
                },
                child: Text(
                  "비밀번호가 기억이나지 않으시나요?",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
