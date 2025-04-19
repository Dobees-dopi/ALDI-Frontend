import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:umi/theme.dart';
class PassResetPage extends StatefulWidget {
  const PassResetPage({Key? key}) : super(key: key);

  @override
  _PassResetPageState createState() => _PassResetPageState();
}

class _PassResetPageState extends State<PassResetPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool isButtonEnabled = false;

  bool _passwordVisible = false; 
  bool _confirmPasswordVisible = false;

  void _onTextChanged() {
    setState(() {
      isButtonEnabled = newPasswordController.text == confirmNewPasswordController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_onTextChanged);
    confirmNewPasswordController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    usernameController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    String username = usernameController.text;
    String newPassword = newPasswordController.text;
    String confirmNewPassword = confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      print("New passwords do not match");
      Get.snackbar("오류", "새 비밀번호가 일치하지 않습니다.");
      return;
    }

    final url = Uri.parse("https://${Globals.baseUrl}/resetpass/?username=$username&newpass=$newPassword&confirm=$confirmNewPassword");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        print("Password reset successful");
        Get.snackbar("성공", "비밀번호가 재설정되었습니다.");
        Get.toNamed('/hardwarelogin');
      } else {
        print("Error resetting password: ${response.body}");
        Get.snackbar("비밀번호 재설정 실패", "오류가 발생했습니다.");
      }
    } catch (e) {
      print("Exception occurred: $e");
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
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent, 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 240, 240, 240),  
                width: 2,           
              ),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            centerTitle: true,
            title: const Text(
              '비밀번호 재설정',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white, 
            elevation: 0,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100], 
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: _inputDecoration("사용자 이름"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: !_passwordVisible, 
              decoration: _inputDecoration("새 비밀번호").copyWith(
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
            const SizedBox(height: 20),
            TextField(
              controller: confirmNewPasswordController,
              obscureText: !_confirmPasswordVisible, 
              decoration: _inputDecoration("새 비밀번호 확인").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black38,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 60),
           GestureDetector(
              
                onTap: () async {
isButtonEnabled ? resetPassword : null;
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
                    '재설정',
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
                  Get.toNamed('/hardwarelogin');
                },
                child: Text(
                  "로그인 하러가기",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
