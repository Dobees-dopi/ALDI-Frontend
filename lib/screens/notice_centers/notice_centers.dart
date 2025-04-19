import 'package:flutter/material.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:get/get.dart';
import 'recent_notification_item.dart';
import 'previous_notification_item.dart';
import 'dart:async';
class NoticePage extends StatefulWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  int recentItemCount = 3;
  int previousItemCount = 0;
  late PageController _pageController;
  final int totalBoxes = 5;
  int _currentPage = 0;
  late Timer _timer;
  void _loadPreviousNotifications() {
    setState(() {
      previousItemCount += 5;
    });
  }
  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_pageController.hasClients) {
          if (_currentPage < totalBoxes - 1) {
            _pageController.nextPage(
                duration: const Duration(milliseconds: 350), curve: Curves.easeIn);
          } else {
            _pageController.jumpToPage(0);
          }
        }
      });

      _pageController.addListener(() {
        if (_pageController.page != null) {
          setState(() {
            _currentPage = _pageController.page!.round();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        extendBodyBehindAppBar: true,
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
              color: Colors.black,
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
        body: ListView.builder(
          itemCount: recentItemCount + previousItemCount + 2,
          padding: const EdgeInsets.only(top: 100.0),
          itemBuilder: (context, index) {
            if (index < recentItemCount) {
              // RecentNotificationItem 사용
              return RecentNotificationItem(
              
                title: '최근 알림 $index', subtitle: 'sdsdsdds', time: '2021.10.10', 
              );
            } else if (index == recentItemCount) {
              // 이전 알림이 보이지 않을 때: 버튼 스타일
              if (previousItemCount == 0) {
                return GestureDetector(
                  onTap: _loadPreviousNotifications,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 130.0, vertical: 15.0),
                    height: 35,
                
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
     
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        '이전 알림 보기',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              } 
              // 이전 알림이 보일 때: 텍스트 좌우 선 스타일
              else {
                return GestureDetector(
                  onTap: _loadPreviousNotifications,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: const Text(
                            '이전 알림 보기',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            } else if (index < recentItemCount + previousItemCount + 1) {
              // PreviousNotificationItem 사용, 마지막 항목에는 아래쪽 테두리 제거
              return PreviousNotificationItem(
             
                title: '이전 알림 $index', subtitle: 'sdsdsdds', time: '2021.10.10',
                hasBottomBorder: index != recentItemCount + previousItemCount, // 마지막 항목에는 테두리 제거
              );
            } else {

}

          },
        ),
        bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: null),
      ),
    );
  }

 }
