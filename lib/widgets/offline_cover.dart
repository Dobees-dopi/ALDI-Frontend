import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineOverlay extends StatelessWidget {
  const OfflineOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12.withOpacity(0.5),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(35),
            child: Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 텍스트
                  const Text(
                    "네트워크가 연결되지 않았습니다. \n Wi-Fi 또는 데이터를 확인해주세요.",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        decoration: TextDecoration.none, // 밑줄 없애기
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center, // 텍스트 가운데 정렬
                  ),
                  const SizedBox(height: 20), // 텍스트와 버튼 사이의 간격
                  // 수평 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // GetX를 사용하여 다이어리 페이지로 이동
                          Get.toNamed("/diary");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E7FE0),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "다이어리로 이동",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      // 두 번째 버튼
                      GestureDetector(
                        onTap: () {
                          // GetX를 사용하여 현재 페이지를 새로고침
                          Get.offAndToNamed(Get.currentRoute);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "다시시도",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
