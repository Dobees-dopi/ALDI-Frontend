import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginFaildPage extends StatelessWidget {
  const LoginFaildPage({Key? key, }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '회원가입 실패',
                style: TextStyle(fontSize: 26,
                fontWeight: FontWeight.bold,),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
              Lottie.asset(
                  'assets/animations/faild.json',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: 370,  // Set the width
                height: 60,  // Set the height
                child: ElevatedButton(
                  onPressed: () {
                    Get.offNamed('/secondstep');
                  },
                  child: const Text(
                    '메인화면으로 돌아가기 ',
                    style: TextStyle(fontSize: 17),  // Here you can change the font size
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF3E7FE0),),
                    foregroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),  // Set the roundness of button
                      ),
                    ),
                    elevation: MaterialStateProperty.all(10),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  ),
                ),
              ),
              ),
                const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: 370,  // Set the width
                height: 60,  // Set the height
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    '뒤로가기',
                    style: TextStyle(fontSize: 17),  // Here you can change the font size
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
                    foregroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 9, 9, 9)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),  // Set the roundness of button
                      ),
                    ),
                    elevation: MaterialStateProperty.all(10),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  ),
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
