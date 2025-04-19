import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umi/screens/notice_centers/detail_notice.dart';
class RecentNotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  const RecentNotificationItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
  }) : super(key: key);

  void _navigateToDetailPage() {
    Get.to(
      () => NotificationDetailPage(), // 이동할 페이지 클래스
      arguments: {
        'title': title,
        'subtitle': subtitle,
        'time': time,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetailPage,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        height: 110,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 209, 209, 209).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],

          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 18, left: 18, top: 12), // 패딩을 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.867),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5.0), // 제목과 부제목 사이의 간격
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(), // 텍스트를 아래로 정렬
              Text(
                time,
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
