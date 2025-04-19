import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class Additional extends StatefulWidget {
  const Additional({Key? key}) : super(key: key);

  @override
  _AdditionalState createState() => _AdditionalState();
}

class _AdditionalState extends State<Additional> {
  static const double topPaddingRatio = 0.16;
  static const double buttonSpacingRatio = 0.03;
  static const double itemSpacing = 20.0; // 아이템 간격을 일정하게 설정
  static const double profileTextSize = 14.0; // 프로필 등록 텍스트 크기
  static const double textFieldTextSize = 16.0; // 텍스트 필드 텍스트 크기
  static const double horizontalSpacing = 21.0; // 텍스트와 텍스트 필드 사이의 가로 여백
  static const double listnumber = 6;

  static const List<String> textFieldLabels = [
    '프로필 등록',
    '이름',
    '닉네임',
    '전화번호',
    '이메일',
    '주소',
    '키우는 종',
  //  '메모',
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
          title: const Text('정말로 나가시겠습니까?',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0)),
          backgroundColor:const Color.fromARGB(255, 253, 253, 253),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 아니요 버튼을 눌렀을 때 팝업만 사라지도록 함
              },
              child: const Text('아니요',
                  style: TextStyle(color:  Color(0xFF3E7FE0))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 예 버튼을 눌렀을 때 앱을 종료하도록 함
              },
              child: const Text('예',
              style: TextStyle(color:  Color(0xFF3E7FE0))),
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
        appBar:  PreferredSize(
  preferredSize: const Size.fromHeight(kToolbarHeight),  // AppBar의 기본 높이를 사용합니다.
  child: Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color.fromARGB(255, 240, 240, 240),  // 원하는 테두리 색상
          width: 2       // 원하는 테두리 두께
        ),
      ),
    ),
    child: AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '프로필 설정',
        style: TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 42, 42, 43),
          fontWeight: FontWeight.bold,
        ),
      ),

    ),
  ),
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
                  width: 80, // 원하는 크기로 설정
                  height: 80, // width와 같은 값을 사용
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 196, 196, 196), // 배경색
                    shape: BoxShape.circle, // 원형 설정
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                    onPressed: () {
                      // 버튼이 클릭되었을 때 수행할 동작
                    },
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
                const SizedBox(height: itemSpacing* 2), // 아이템 간격 추가
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
                Padding(
                    padding: const EdgeInsets.only(left: 100.0, right: 100.0, bottom: 30.0, top: 30),
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>( const Color(0xFF3E7FE0)),
                        //elevation: MaterialStateProperty.all<double>(15.10), // 여기에서 그림자 높이를 조절
                        shadowColor: MaterialStateProperty.all<Color>(Colors.black38), // 그림자 색상
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Center(
                          child: Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
