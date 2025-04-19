import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/screens/profiles/aquarium_profiles/hardware_profile.dart';
import 'dart:async';
import 'package:umi/golobalkey.dart';
import 'package:umi/widgets/isOnline_Definder.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/profile_localDB.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';

// Assuming StatusTag class is defined somewhere in your code
class StatusTag {
  final int id;
  final String imageUrl;
  final String name;

  StatusTag({required this.id, required this.imageUrl, required this.name});
}

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  final ConnectivityController controller = Get.find(); // 컨트롤러 가져오기

  List<StatusTag> statusTags = [];
  late StreamController<String> _imageStreamController;
  String _tagname = "프로필"; // 초기값 설프로피정
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final String _imagePath = '';
  String _userid = '';
  final ProfileController selectedProfileIdController =
      Get.find<ProfileController>();
  @override
  void initState() {
    super.initState();
    _imageStreamController = StreamController<String>();
    _userid = Globals.userName;
    _loadProfileName();
    _loadProfileData();
  }

  void closeAllPopupsAndShowNew(BuildContext context, Offset globalPosition) {
    // 현재 Navigator 스택에 있는 모든 팝업을 닫습니다.
    // 새로운 팝업을 띄웁니다.
    showPopup(context, globalPosition);
  }

  Future<void> _loadProfileName() async {
    setState(() {
      _tagname = selectedProfileIdController.selectedProfileName.value;
    });
  }

  Future<void> _loadProfileData() async {
    print(
        '${selectedProfileIdController.selectedProfileImagePath.value.isNotEmpty}' +
            '프로필 사진 값유무 확인');
    // 이미지 경로가 비어 있으면 (즉, 이미지가 없으면)
    if (selectedProfileIdController.selectedProfileImagePath.value.isEmpty) {
      // 데이터베이스에서 마지막으로 사용한 프로필 데이터를 가져옴
      final profileData = await _dbHelper.getLastUsedProfile();

      if (profileData != null) {
        // 프로필 데이터를 리스트에 추가
        List<Map<String, dynamic>> profileList = [profileData];

        // 프로필 리스트 갱신 (Controller에 있는 updateListOfProfile 함수 호출)
        selectedProfileIdController.updateListOfProfile(profileList, 2);
        _imageStreamController
            .add(selectedProfileIdController.selectedProfileImagePath.value);
      } else {
        // 프로필 데이터를 찾을 수 없는 경우 처리
        print('No profile data found in database.');
      }
    } else if (selectedProfileIdController
        .selectedProfileImagePath.value.isNotEmpty) {
      // 이미지 경로가 있으면 스트림에 추가
      _imageStreamController
          .add(selectedProfileIdController.selectedProfileImagePath.value);
    }
  }

  // Future<List<StatusTag>> fetchStatusTags() async {
  //   final url = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/status/tag');
  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       // Decode the response body using UTF-8
  //       String decodedResponse = utf8.decode(response.bodyBytes);
  //       print("Response from API: $decodedResponse"); // Print the response

  //       List<dynamic> jsonResponse = jsonDecode(decodedResponse)['detail'];
  //       return jsonResponse.map((tag) => StatusTag.fromJson(tag)).toList();
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching status tags: $e');
  //     return [];
  //   }
  // }

  Future<void> checkAndNavigate() async {
    List<Map<String, dynamic>> storedValue =
        selectedProfileIdController.profileList;

    if (storedValue.isEmpty) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar('프로필을 선택해주세요', '프로필을 선택해야 합니다');
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.toNamed('/memodefault');
    }
  }

  @override
  void dispose() {
    _imageStreamController.close();
    super.dispose();
  }

  Future<String?> getSavedImageUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedImageURL');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 65.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                // Assuming showPopup is defined to show a popup menu
              },
              child: StreamBuilder<String>(
                stream: _imageStreamController.stream,
                builder: (context, snapshot) {
                  Widget imageChild;
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    imageChild = ClipOval(
                      child: Image.file(
                        File(snapshot.data!),
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    imageChild = const Icon(Icons.person_outlined,
                        color: Color.fromARGB(255, 255, 255, 255));
                  }

                  return SizedBox(
                    width: 65, // SizedBox를 사용하여 명시적인 크기 설정
                    height: 65,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          // Positioned.fill을 사용하여 컨테이너를 꽉 채움
                          child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              closeAllPopupsAndShowNew(
                                  context, details.globalPosition);
                              // else 부분은 필요 없으므로 제거
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 162, 162, 162),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: imageChild, // 이미지 또는 아이콘 표시
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {/* 새로고침 로직 */},
                            child: const Icon(Icons.refresh,
                                size: 22, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 65,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: statusTags.length,
                itemBuilder: (context, index) {
                  StatusTag tag = statusTags[index];
                  return GestureDetector(
                      onTap: () {
                        // Print tag details
                        print('Selected Tag ID: ${tag.id}');
                        print('Selected Tag Name: ${tag.name}');
                        print('Selected Tag Image URL: ${tag.imageUrl}');
                        Globals.tagurl = tag.imageUrl;
                        Globals.tagname = tag.name;
                        // Navigate to the memo default screen with the selected tag details
                        checkAndNavigate();
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Aligns children to the center of the column.
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centers children horizontally in the column.
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 15),
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 15), // 원하는 패딩 값을 지정합니다.
                                color: Colors.transparent,
                                child: Text(
                                  tag.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          ]));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
