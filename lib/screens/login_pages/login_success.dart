import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginSuccess extends StatefulWidget {
  const LoginSuccess({Key? key, }) : super(key: key);

  @override
  _LoginSuccessState createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess> with TickerProviderStateMixin {
  late final AnimationController animation1Controller;
  late final AnimationController animation2Controller;

  // 페이지 활성화 상태를 나타내는 변수
  bool _isPageActive = true;

  @override
  void initState() {
    super.initState();

    animation1Controller = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    animation2Controller = AnimationController(vsync: this, duration: const Duration(seconds: 10));

    // 5초 후에 페이지를 이동합니다.
    Future.delayed(const Duration(seconds: 3), () {
      if (_isPageActive) {  // 페이지가 여전히 활성화되어 있는 경우만 페이지를 이동
        Get.offAllNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    // 페이지가 dispose될 때 _isPageActive를 false로 설정
    _isPageActive = false;

    animation1Controller.dispose();
    animation2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: GestureDetector(
        onTapUp: (details) {
          Get.offAllNamed('/home');
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Lottie.asset('assets/animations/fire_works.json', 
                    controller: animation1Controller,
                    width: 600,
                    height: 600,
                    onLoaded: (composition) {
                      animation1Controller
                        ..duration = composition.duration
                        ..forward();
                    }),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Lottie.asset('assets/animations/fire_works.json', 
                    controller: animation2Controller,
                    width: 600,
                    height: 600,
                    onLoaded: (composition) {
                      animation2Controller
                        ..duration = composition.duration
                        ..forward();
                    }),
                ),
              ),
              Center(
                child: Lottie.asset('assets/animations/check.json', width: 200, height: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
