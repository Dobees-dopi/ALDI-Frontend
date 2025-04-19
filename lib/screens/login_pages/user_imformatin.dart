import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key}) : super(key: key);

  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  static const double topPaddingRatio = 0.16;
  static const double buttonSpacingRatio = 0.03;
  static const double itemSpacing = 20.0; // 아이템 간격을 일정하게 설정
  static const double buttonWidth = 80.0; // 원형 버튼 가로 크기
  static const double buttonHeight = 80.0; // 원형 버튼 세로 크기
  static const double profileTextSize = 14.0; // 프로필 등록 텍스트 크기
  static const double textFieldTextSize = 16.0; // 텍스트 필드 텍스트 크기
  static const double horizontalSpacing = 21.0; // 텍스트와 텍스트 필드 사이의 가로 여백
  static const double listnumber = 7;
  static const List<String> textFieldLabels = [
    '프로필 등록',
    '이름',
    '이메일 주소',
    '닉네임',
    '전화번호',
    '생일',
    '성별',
    '키우시고 있거나 키울 예정인 종',
  ];

  final ScrollController _scrollController = ScrollController();
  bool _showButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 10) {
      if (_showButton) {
        setState(() {
          _showButton = false;
        });
      }
    } else {
      if (!_showButton) {
        setState(() {
          _showButton = true;
        });
      }
    }
  }

  Future<bool> _showExitConfirmationDialog() async {//팝업부분
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('정말로 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 아니요 버튼을 눌렀을 때 팝업만 사라지도록 함
              },
              child: const Text('아니요'),
            ),
            ElevatedButton(
              onPressed: () async {
              Navigator.of(context).pop(true); // close the dialog
              await Future.delayed(const Duration(milliseconds: 500)); // add a small delay
              Get.back(); // navigate back
                },
              child: const Text('예'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));

    final buttonSpacing = MediaQuery.of(context).size.height * buttonSpacingRatio;

    return WillPopScope(
      onWillPop: () async {
        final confirmed = await _showExitConfirmationDialog();
        return confirmed;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(249, 251, 251, 251),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () async {
              final confirmed = await _showExitConfirmationDialog();
              if (confirmed) {
                Get.back();
              }
            },
          ),
          
          title: const Text(
            '회원 가입',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * topPaddingRatio,
              ),
              children: [
                const SizedBox(height: 0), //프로필 원형버튼 위에 간격 
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: FloatingActionButton(
                    onPressed: () {
                      // 원형 버튼이 클릭되었을 때 수행할 동작
                    },
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: buttonWidth * 0.45,
                      color: Colors.black,
                    ),
                    backgroundColor: const Color.fromARGB(255, 196, 196, 196),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: itemSpacing* 0.8), // 아이템 간격 추가
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: horizontalSpacing),
                  child: Text(
                    textFieldLabels[0], // 텍스트 필드 1의 레이블
                    style: const TextStyle(
                      fontSize: profileTextSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: itemSpacing* 3), // 아이템 간격 추가
                for (int i = 1; i < listnumber + 1; i++) ...[
                  const SizedBox(height: itemSpacing), // 아이템 간격 추가
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: horizontalSpacing),
                    child: Text(
                      textFieldLabels[i], // 텍스트 필드 레이블
                      style: const TextStyle(
                        fontSize: textFieldTextSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: buttonSpacing),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: horizontalSpacing),
                    child: Container(
                      width: 200,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          hintText: '텍스트를 입력하세요',
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: itemSpacing), // 아이템 간격 추가
                SizedBox(height: buttonSpacing),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: _showButton ? 0 : -60,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 0), // 좌우 여백 없이 꽉 채우기
                child: ElevatedButton(
                  onPressed: () {
                   Get.toNamed('/loginfaild');
                  },
                  child: const Text(
                    '작성완료',
                    style: TextStyle(
                      fontSize: textFieldTextSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // 버튼 내부 패딩 제거
                    minimumSize: const Size(double.infinity, 40), // 좌우 여백 없이 꽉 채우기
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}