import 'package:flutter/material.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:get/get.dart';
import 'package:umi/widgets/surch_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:umi/golobalkey.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 패키지 import

class SettingmainPage extends StatefulWidget {
  final int selectedIndex;

  const SettingmainPage({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _SettingmainPageState createState() => _SettingmainPageState();
}

class _SettingmainPageState extends State<SettingmainPage> {


  Future<void> customLogout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Globals.userName = ""; // 사용자 이름 초기화
    await prefs.remove('username'); // username 삭제
    await prefs.remove('selectedTagName'); // selectedTagName 삭제
    await prefs.remove('selectedImageURL'); // selectedImageURL 삭제

    Get.offAllNamed('firststep');
  }

  Future<void> deleteUserData() async {
    final uri = Uri.parse('https://mvp-iot.cahlp.kr/user/delete/');
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "username": Globals.userName,
          "userid": Globals.userid,
        }),
      );

      if (response.statusCode == 204) {
        // 요청이 성공적으로 완료됨
        showSnackbar("탈퇴성공", "탈퇴되었습니다.");
        Get.offAllNamed('/Startpairing'); // 원하는 페이지로 이동
      } else {
        // 서버에서 에러 응답
        showSnackbar("탈퇴실패", "탈퇴 실패되었습니다.");
        print('삭제 실패: ${response.statusCode}');
        print('응답 본문: ${response.body}');
      }
    } catch (e) {
      // 네트워크 오류 또는 요청 실패
      print('요청 중 오류 발생: $e');
    }
  }

  void showSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(title, message);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back(); // Remove all previous routes and navigate to home page
        return true; // Prevent the default behavior (i.e., exiting the app)
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          // AppBar의 기본 높이를 사용합니다.
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 240, 240, 240), // 원하는 테두리 색상
                  width: 2.0, // 원하는 테두리 두께
                ),
              ),
            ),
            child: AppBar(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text(
                '설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.black,
                onPressed: Get.back,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.black,
                  onPressed: () {
                    final searchButton = SearchButton(context);
                    searchButton.showPopup(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Container(
            color: const Color.fromARGB(0, 10, 190, 181),
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                _buildButtonGroup(
                  title: tr('언어 설정'), // 번역된 텍스트 사용
                  buttons: [
                    SettingButton(
                      text: tr('기기 설정 언어 따르기'), // 번역된 텍스트
                      onPressed: () {
                        context.resetLocale();

                      },
                    ),
                    SettingButton(
                      text: tr('English'),
                      onPressed: () {
                        context.setLocale(Locale('en', 'US'));

                      },
                    ),
                    SettingButton(
                      text: tr('한국어'),
                      onPressed: () {
                        context.setLocale(Locale('ko', 'KR'));

                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildButtonGroup(
                  title: tr('설정 옵션'),
                  buttons: [
                    SettingButton(
                      text: tr('개인 정보 수정'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                    SettingButton(
                      text: tr('계정 연동'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                    SettingButton(
                      text: tr('문의하기'),
                      onPressed: () {
                        Get.toNamed('/inquire');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildButtonGroup(
                  title: tr('설정 옵션'),
                  buttons: [
                    SettingButton(
                      text: tr('이용 약관'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                    SettingButton(
                      text: tr('오픈소스 라이선스'),
                      onPressed: () {
                        Get.toNamed('/licenses');
                      },
                    ),
                    SettingButton(
                      text: tr('유료 서비스 약관'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildButtonGroup(
                  title: tr('설정 옵션'),
                  buttons: [
                    SettingButton(
                      text: tr('위치정보 서비스 약관'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                    SettingButton(
                      text: tr('개인정보 취급방침'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildButtonGroup(
                  title: tr('설정 옵션'),
                  buttons: [
                    SettingButton(
                      text: tr('서비스 이용약관'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                    SettingButton(
                      text: tr('로그아웃'),
                      onPressed: () {
                        customLogout(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildButtonGroup(
                  title: tr('설정 옵션'),
                  buttons: [
                    SettingButton(
                      text: tr('회원탈퇴'),
                      subtitle: tr('계정을 영구적으로 삭제합니다'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _buildDeleteAccountDialog(context);
                          },
                        );
                      },
                    ),
                    SettingButton(
                      text: tr('앱 버젼'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                    SettingButton(
                      text: tr('라이트모드/다크모드'),
                      onPressed: () {
                        // Get.to();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

          bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: null),
      ),
    );
  }

  AlertDialog _buildDeleteAccountDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '회원 탈퇴',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        '정말 탈퇴하시겠습니까?',
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E7FE0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    '취소',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  customLogout(context);
                  deleteUserData();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E7FE0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    '탈퇴',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

// 3~2개의 버튼을 그룹으로 묶어주는 메서드 (구분선 포함)
  Widget _buildButtonGroup(
      {required List<Widget> buttons, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그룹 상단의 제목 텍스트
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // 버튼 리스트와 구분선
          ...buttons
              .map((button) => Column(
                    children: [
                      button,
                      if (buttons.indexOf(button) != buttons.length - 1)
                        const Divider(
                          height: 5,
                          thickness: 1,
                          color: Color.fromARGB(255, 230, 230, 230),
                        ),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  final String text;
  final String? subtitle; // 작은 텍스트 (선택적)
  final VoidCallback? onPressed;

  const SettingButton({
    Key? key,
    required this.text,
    this.subtitle, // 작은 텍스트를 전달할 수 있도록 수정
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        decoration: BoxDecoration(
          color: Color.fromARGB(0, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5.0), // 네모 크기
              decoration: BoxDecoration(
                color: Colors.grey[300], // 회색 배경
                borderRadius: BorderRadius.circular(10), // 라운드 처리
              ),
              child: Icon(
                Icons.manage_accounts, // 아이콘
                color: Colors.black54, // 아이콘 색상
              ),
            ),
            SizedBox(width: 15), // 아이콘과 텍스트 사이 간격
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) // subtitle이 있을 경우에만 렌더링
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0), // 주 텍스트와의 간격 추가
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.left, // 작은 텍스트도 왼쪽 정렬
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black45,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonData {
  final String text;
  final VoidCallback? action;

  ButtonData(this.text, this.action);
}
