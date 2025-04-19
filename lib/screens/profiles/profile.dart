import 'package:flutter/material.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:umi/screens/profiles/post_item.dart';

class CommunityProfilePage extends StatefulWidget {
  final int selectedIndex;

  const CommunityProfilePage({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _CommunityProfilePageState createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> {
  late ScrollController _controller;
  double _scrollLimit = 0; // Initial scroll limit
  bool isGreenBoxOnLeft = true;
  bool isActive = false; // 버튼의 상태를 저장하는 불린 변수
  bool isListView = false; // 초기값을 리스트 보기로 설
  int index = 30;

  void toggleState() {
    setState(() {
      isActive = !isActive; // 상태를 전환합니다.
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels > _scrollLimit) {
          _controller.jumpTo(_scrollLimit);
        }
      });
  }

  @override
  Widget build(BuildContext context) {//게시클란 스크롤 리미트- 수정 필요
 _scrollLimit = MediaQuery.of(context).size.height * 1.5;


    return WillPopScope(
      onWillPop: () async {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back();
        return true;
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight), // AppBar의 기본 높이를 사용
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                if (Get.isSnackbarOpen) {
                  Get.closeCurrentSnackbar();
                }
                Get.back();
              },
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings_outlined,   color: Colors.black87,),
                onPressed: () {
                  Get.toNamed('/settingmain');
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: MyBottomNavigationBar(selectedIndex: widget.selectedIndex),
        body: ListView(
          controller: _controller,
          padding: EdgeInsets.zero, // Remove padding to allow overlap
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width, // 화면의 전체 너비로 설정
                  height: MediaQuery.of(context).size.height * 0.1 + 280,
                  color: Color.fromARGB(171, 255, 255, 255),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20), // 좌우 패딩 설정
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬 설정
                      children: [
                        // const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 180,
                  color: Color.fromARGB(171, 189, 189, 189),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0, top:80),
                              child: Column(
                                children: [
                                  Text(
                                    '팔로워',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '120',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                print('큰 원형 버튼 클릭됨!');
                              },
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  boxShadow: [
                                    // 그림자 추가
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_outlined,
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  size: 90,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 40.0, top:70),
                              child: Column(
                                children: [
                                  Text(
                                    '팔로잉',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '108',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '모야모야삐',
                          style: TextStyle(
                            color: Colors.black, // Black text color
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '관상어 대표로 키우는 중',
                          style: TextStyle(
                            color: Colors.black, // Black text color
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 15),
                   
     Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
      GestureDetector(
  onTap: () {
    // Button action
  },
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
    decoration: BoxDecoration(
      color: Colors.white, // Background color
      border: Border.all(color: Colors.grey.shade300, width: 0.5), // Border color
      borderRadius: BorderRadius.circular(20.0), // Rounded corners

    ),
    child: Icon(
      Icons.send,
      color: Colors.blue,
    ),
  ),
),

SizedBox(width: 10),

GestureDetector(
  onTap: () {
    // Button action
  },
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
    decoration: BoxDecoration(
      color: Colors.white, // Background color
      border: Border.all(color: Colors.grey.shade300, width: 0.5), // Border color
      borderRadius: BorderRadius.circular(20.0), // Rounded corners
  
    ),
    child: Text(
      '언팔로우',
      style: TextStyle(
        color: Colors.orange,
        fontSize: 14,
      ),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, -2), // Shadow position adjustment
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            "게시글 $index",
                            style: TextStyle(
                              color: Colors.black54, // 선택된 아이콘의 색상 변경
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isListView = false;
                          });
                        },
                        child: Icon(
                          Icons.image_outlined,
                          color: isListView ? Colors.black54 : Colors.blue, // 선택된 아이콘의 색상 변경
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isListView = true;
                          });
                        },
                        child: Icon(
                          Icons.menu,
                          color: isListView ? Colors.blue : Colors.black54, // 선택된 아이콘의 색상 변경
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
            ),
           Container(
              height: 600,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: isListView
                  ? ListView.builder(
                      padding: EdgeInsets.zero, // Remove padding to ensure content starts from the top
                      itemCount: index,
                      itemBuilder: (context, index) {
                        // 임의로 이미지를 가진 포스트와 그렇지 않은 포스트를 구분
                        bool hasImage = index % 2 == 0;
                        return PostItem(
                          title: '어항 청소했는데 너무 피곤하네요.',
                          subtitle: '여러분들은 어항 청소를 얼마나 자주하시나요? 저는 자주자주 갈아주는 편인데도 금방 더러워지는 것 같네요. ㅠㅠ 물고기 가족들이 많이 늘어나서 그런 것 같기도 하네요.',
                          hasImage: hasImage,
                        );
                      },
                    )
                  : GridView.builder(
                      padding: EdgeInsets.zero, // Remove padding to ensure content starts from the top
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: index,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed('/detailfeed', arguments: {});
                          },
                          child: Container(
                            color: const Color.fromARGB(255, 235, 235, 235),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
