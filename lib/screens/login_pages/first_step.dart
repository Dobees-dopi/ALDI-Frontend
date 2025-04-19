import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:umi/screens/login_pages/second_step.dart';
import 'package:umi/theme.dart';
class FirstStepPage extends StatefulWidget {
  const FirstStepPage({Key? key, }) : super(key: key);

  @override
  _FirstStepPageState createState() => _FirstStepPageState();
}

class _FirstStepPageState extends State<FirstStepPage> with TickerProviderStateMixin {
  Timer? _timer;
  int currentAnimation = 0;

late AnimationController _gradientController;
  late Animation<double> _gradientPosition;
  
void resetTimer() {
    _timer?.cancel();  // 기존 타이머를 해제합니다.
    _timer = Timer(const Duration(seconds: 7), () {
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    _gradientController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _gradientPosition = Tween<double>(begin: 0, end: 1).animate(_gradientController);

    resetTimer();
  }


  late AnimationController _animationController;
  bool _showContent = true; // 콘텐츠 표시 여부를 결정하는 상태변수

  void _showSecondStepAsPopup(BuildContext context) {
  _animationController.forward(from: 0);

  // 페이드 아웃 시작
  setState(() {
    _showContent = false;
  });

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true, // 팝업 외부를 눌렀을 때 dismiss 가능하게 설정
      pageBuilder: (BuildContext context, _, __) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context); // 팝업을 닫습니다.
          },
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
            ),
            child: Dialog(
              backgroundColor: Temas.backgroundcolor,
              shape: RoundedRectangleBorder(  // 라운드 모서리 추가
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {}, // 팝업 내부의 탭 이벤트를 소비하여 밖의 GestureDetector에게 전달되지 않게 합니다.
                    child: Container(
                      width: 700,
                      child: SecondStepDialogContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ),
  ).then((_) {
    // 팝업이 닫힐 때 페이드 인 시작
    setState(() {
      _showContent = true;
    });
  });
}


@override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: GestureDetector(

        child: Scaffold(
          backgroundColor: const Color.fromARGB(214, 133, 200, 255),
          body: AnimatedBuilder(
            animation: _gradientPosition,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-_gradientPosition.value, -_gradientPosition.value),
                    end: Alignment(_gradientPosition.value, _gradientPosition.value),
                    colors: [const Color.fromARGB(255, 86, 120, 255), Colors.lightBlueAccent],
                  ),
                  
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
              AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0, // 투명도 제어
                duration: const Duration(milliseconds: 200), // 애니메이션 지속시간
                child: FractionallySizedBox(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 390.0,
                        height: 230.0,
                        decoration: BoxDecoration(
                          color: Temas.backgroundcolor,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(height: 30),
                            Text(
                              '알디에 오신것을 환영합니다!',
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                   color: Colors.black87,

                              ),
                            ),
                            const SizedBox(height: 5),

                            const SizedBox(height: 20),
                     GestureDetector(
  onTap: () {
    _showSecondStepAsPopup(context);
  },
  child: Container(
    width: 200.0,
    height: 50.0,
    decoration: BoxDecoration(
      color: Temas.maincolor, // 버튼 색상 설정
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Center(
      child: const Text(
        '알디 시작하기',
        style: TextStyle(
          fontSize: 17, // 텍스트 크기 조정 (원래 180은 매우 큰 크기이므로 18로 설정)
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(255, 255, 255, 255),
          
        ),
      ),
    ),
  ),
),

                            TextButton(
                              onPressed: () {
                                Get.toNamed('/inquire');
                              },
                              child: const Text(
                                '제휴/사용 문의',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38),
                                ),
                              ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}