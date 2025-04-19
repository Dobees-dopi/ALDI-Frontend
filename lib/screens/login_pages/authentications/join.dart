import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:umi/theme.dart';

class HardwareJoinPage extends StatefulWidget {
  const HardwareJoinPage({Key? key}) : super(key: key);

  @override
  _HardwareJoinPageState createState() => _HardwareJoinPageState();
}

class _HardwareJoinPageState extends State<HardwareJoinPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> _register(String username, String email, String mobile, String password) async {
    final url = "http://${Globals.baseUrl}/register/";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8", // UTF-8 인코딩 설정
      },
      body: json.encode({
        "username": username,
        "email": email,
        "mobile": mobile,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      print("Registration successful");
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar("회원가입 성공", "회원가입에 성공하셨습니다");
      Get.offAllNamed('/hardwarelogin');
      print(response.body);
    } else {
      print("Error registering: ${response.statusCode}");
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar("회원가입 실패", "회원가입에 실패하셨습니다");
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
       filled: true,
 fillColor: Colors.white, // 필드 내부 색상
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0), // Increase vertical padding to adjust height
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Temas.maincolor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      labelStyle: const TextStyle(
        color: Colors.black38,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();  // Remove all previous routes and navigate to home page
        return true;  // Prevent the default behavior (i.e., exiting the app)
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,  // Make Scaffold transparent
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),  // AppBar's default height
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 240, 240, 240),  // Border color
                  width: 2,           // Border width
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
                '회원가입',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
            ),
          ),
        ),
        body: Container(
          color: Colors.grey[100],  // Set body background to gray
          padding: const EdgeInsets.only(right: 40, left: 40, ), // Desired padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              TextField(
                controller: usernameController,
                decoration: _inputDecoration("이름"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: _inputDecoration("이메일"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: mobileController,
                decoration: _inputDecoration("전화번호"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible,
                decoration: _inputDecoration("비밀번호").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black38,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),
            GestureDetector(
              
                onTap: () async {
               await _register(
                    usernameController.text,
                    emailController.text,
                    mobileController.text,
                    passwordController.text,
                  );
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
                    '회원가입',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600,
                      fontSize: 14
                    ),
                  ),
                ),
              ),
                   SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/hardwarelogin');
                },
                child: Text(
                  "이미 회원이신가요?",
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
