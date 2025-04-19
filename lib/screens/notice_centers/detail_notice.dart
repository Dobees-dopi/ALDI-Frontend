import 'package:flutter/material.dart';
import 'package:get/get.dart';

//공지 상세보기 페이지

class NotificationDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get.arguments를 사용하여 전달된 데이터를 받아옴
    final Map<String, String> notificationData = Get.arguments;

    return Scaffold(
     backgroundColor: Color.fromARGB(255, 246, 246, 246),
      //  extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            '알림센터',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            child: Container(
              color: const Color.fromARGB(255, 240, 240, 240),
              height: 2.0,
            ),
            preferredSize: const Size.fromHeight(1.0),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notificationData['title'] ?? '제목 없음',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              notificationData['subtitle'] ?? '내용 없음',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              notificationData['time'] ?? '시간 없음',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
