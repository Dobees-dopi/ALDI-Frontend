import 'package:flutter/material.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:get/get.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';

class CommitPage extends StatefulWidget {
  const CommitPage({Key? key}) : super(key: key);

  @override
  _CommitPageState createState() => _CommitPageState();
}

class _CommitPageState extends State<CommitPage> {
  late Future<List<Map<String, dynamic>>> _data;
  final ProfileController profileController = Get.find(); // 컨트롤러 인스턴스 가져오기

  Future<void> _refreshData() async {
    setState(() {
      _data = DatabaseHelper.instance
          .queryAllRows(profileController.selectedProfileId.value);
    });
  }

  @override
  void initState() {
    super.initState();
    _data = DatabaseHelper.instance
        .queryAllRows(profileController.selectedProfileId.value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(); // Remove all previous routes and navigate to home page
        return false; // Prevent the default behavior (i.e., exiting the app)
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        //appBar: MyAppBar(),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // 로딩 인디케이터 표시
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // 에러 표시
            } else {
              List<Map<String, dynamic>> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = data[index];
                  return ListTile(
                    title: Text(item['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('내용: ${item['content']}'),
                        Text('알람 설정: ${item['alarmSet']}'),
                        Text('생성날짜: ${item['currentTime']}'),
                        Text('알람 날짜: ${item['selectedDate']}'),
                        Text('알람 시간: ${item['selectedTime']}'),
                        Text('반복 옵션: ${item['repeatOption']}'),
                        Text('아이콘 색상: ${item['iconColor']}'),
                        Text('아이콘 텍스트: ${item['iconText']}'),
                        Text('글 날짜: ${item['selectedDatea']}'),

                        // ... 기타 필드 ...
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        bottomNavigationBar: const MyBottomNavigationBar(
          selectedIndex: null,
        ),
      ),
    );
  }
}
