import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/screens/diary_pages/diary.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/profile_localDB.dart';
import 'dart:io';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';

class DiaryDetail {
  final String? profile_name; // `null`을 허용하도록 변경
  final String? profileImages; // `null`을 허용하도록 변경
  final int? profile_id; // Add this line for the ID

  DiaryDetail(
      {required this.profile_name,
      required this.profileImages,
      this.profile_id});
  @override
  String toString() {
    return 'DiaryDetail(profile_name: $profile_name, profileImages: $profileImages, profile_id: $profile_id)';
  }

  factory DiaryDetail.fromJson(Map<String, dynamic> json) {
    return DiaryDetail(
      profile_name: json['profile_name'] as String?, // `null` 허용
      profileImages: json['profileImages'] as String?, // `null` 허용
      profile_id: json['profile_id'] as int?, // Parse the ID
    );
  }
}

// 로컬 DB에서 프로필 태그 테이블에 태그ID를 추가하고 그 것을 키값으로 다이어리 테이블에 외래키로 태그ID를 부여
Future<List<DiaryDetail>> requestProfileFromLocalDB() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedUsername = prefs.getString('username');
  List<Map<String, dynamic>> profiledataFromlocaldb =
      await dbHelper.selectProfile(storedUsername);

  // 쿼리 결과가 비어있으면 빈 리스트 반환
  if (profiledataFromlocaldb.isEmpty) {
    return [];
  }

  // 쿼리 결과를 DiaryDetail 객체 리스트로 변환
  return List.generate(profiledataFromlocaldb.length, (index) {
    return DiaryDetail.fromJson(profiledataFromlocaldb[index]);
  });
}

// 로컬 DB에서 해당 프로필을 삭제하면 그 외래키와 연결된 다이어리 글들도 다 삭제(사진포함)

// 프로필 데이터를 불러와서 키 값별로 데이터 분리
Future<void> saveToSharedPreferences(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}
// Future<List<DiaryDetail>> fetchProfileData() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? storedUsername = prefs.getString('username');

//   final url = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/profile/search/');
//   final response = await http.post(
//     url,
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({'userid': storedUsername}),
//   );

//   if (response.statusCode == 200) {
//     final decodedBody = utf8.decode(response.bodyBytes);
//     print('Response data: $decodedBody');
//     List<dynamic> jsonList = jsonDecode(decodedBody)['detail'];
//     return jsonList.map((json) => DiaryDetail.fromJson(json)).toList();
//   } else {
//     print('Request failed with status: ${response.statusCode}.');
//     return []; // 오류 발생 시 빈 리스트 반환
//   }
// }

// 백엔드 프로필 데이터를 불러와서 삭제
// Future<void> deleteProfile(int tagId) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? storedUsername = prefs.getString('username');

//   final url = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/profile/delete/');
//   Map<String, String> headers = {"Content-Type": "application/json"};
//   String body = jsonEncode({
//     "Diary_where_tag_id": tagId.toString(),
//     "Diary_user_name": storedUsername // Replace with actual username if needed
//   });

//   var request = http.Request('DELETE', url)
//     ..headers.addAll(headers)
//     ..body = body;

//   try {
//     var response = await request.send();

//     if (response.statusCode == 204) {
//       print('Profile deleted successfully');
//       if (Get.isSnackbarOpen) {
//         Get.closeCurrentSnackbar();
//       }
//       Get.snackbar("삭제 완료", "프로필이 삭제되었습니다",);
//       // Handle success (e.g., update UI or show a success message)
//     } else {
//       print('Failed to delete profile. Status code: ${response.statusCode}');
//       if (Get.isSnackbarOpen) {
//         Get.closeCurrentSnackbar();
//       }
//       Get.snackbar("삭제 실패", "프로필이 삭제되지않 습니다",);
//     }
//   } catch (e) {
//     print('Error occurred: $e');
//     // Handle errors (e.g., show an error message)
//   }
// }

// 해당 로컬 프로필의 이미지 + DB다 삭제
Future<void> deleteLocalProfile(int profileId, context) async {
  final ProfileController profileIdController = Get.find<ProfileController>();

  DatabaseHelper _dbHelper = DatabaseHelper();
  try {
    final profileList =
        await _dbHelper.getLargestOrLowestProfileBelow(profileId);
    if (profileList != null) {
      List<Map<String, dynamic>> largestOrLowestProfile = [profileList];
      profileIdController.updateListOfProfile(largestOrLowestProfile, 1);
      await _dbHelper.insertOrUpdateLastUsedProfile(largestOrLowestProfile);
      bool isAllDeletedData =
          await _dbHelper.deleteProfileAndRelatedDate(profileId);
      if (isAllDeletedData) {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.snackbar(
          "삭제 완료",
          "프로필이 삭제되었습니다",
        );
        navigateToProfile(context);
        // Handle success (e.g., update UI or show a success message)
      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.snackbar(
          "삭제 실패",
          "프로필이 삭제되지않 습니다",
        );
      }
    }
  } catch (e) {
    print('Error occurred: $e');
    // Handle errors (e.g., show an error message)
  }
}

void navigateToProfile(context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => const DiaryPage(
              selectedIndex: 0,
            )), // Replace 'YourScreen' with the name of your screen class
  );
}

void showPopup(BuildContext context, Offset offset) async {
  final profileController = Get.find<ProfileController>(); // 컨트롤러 인스턴스 가져오기
  List<DiaryDetail> diaryDetails = await requestProfileFromLocalDB();
  DatabaseHelper _dbHelper = DatabaseHelper();

  final RenderBox? overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;

  if (overlay != null) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        overlay.size.width - offset.dx,
        overlay.size.height - offset.dy,
      ),
      items: [
        PopupMenuItem(
          child: Container(
            constraints: const BoxConstraints(
                maxHeight: 5 * 48.0), // Max height for 5 items
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  ...diaryDetails.map((detail) {
                    bool _isSelected =
                        profileController.selectedProfileId.value ==
                            detail.profile_id;
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // 팝업 닫기
                        print('선택한 이미지 URL: ${detail.profileImages ?? "null"}');
                        print('선택한 태그 이름: ${detail.profile_name ?? "null"}');
                        print(
                            'Selected Tag ID: ${detail.profile_id ?? "null"}'); // Log the ID
                        if (detail.profileImages != null &&
                            detail.profileImages != null &&
                            detail.profile_name != null) {
                          List<Map<String, dynamic>> newList = [
                            {
                              'profile_name': detail.profile_name,
                              'profileImages': detail.profileImages,
                              'profile_id': detail.profile_id,
                            }
                          ];
                          await _dbHelper
                              .insertOrUpdateLastUsedProfile(newList);
                        }
                        // 이미지 URL 저장
                        if (detail.profileImages != null) {
                          await saveToSharedPreferences(
                              'selectedImageURL', detail.profileImages!);
                          profileController.updateSelectedProfileImage(
                              detail.profileImages!);
                        }

                        // 태그 이름 저장
                        if (detail.profile_name != null) {
                          await saveToSharedPreferences(
                              'selectedTagName', detail.profile_name!);
                          profileController
                              .updateSelectedProfileName(detail.profile_name!);
                        }

                        if (detail.profile_id != null) {
                          profileController
                              .updateSelectedTagId(detail.profile_id!);
                        }
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DiaryPage(
                                    selectedIndex: 0,
                                  )), // Replace 'YourScreen' with the name of your screen class
                        );
                      },
                      onLongPress: () async {
                        Navigator.of(context).pop(); // Close the dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                '프로필 삭제',
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                '정말 삭제 하시겠습니까?',
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      // 첫 번째 버튼을 Expanded로 감싸서 좌측 영역을 균등하게 차지하도록 함
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pop(); // 대화상자 닫기
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF3E7FE0),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            '취소',
                                            textAlign:
                                                TextAlign.center, // 텍스트 중앙 정렬
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10), // 버튼 사이의 간격
                                    Expanded(
                                      // 두 번째 버튼을 Expanded로 감싸서 우측 영역을 균등하게 차지하도록 함
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context)
                                              .pop(); // 대화상자 닫기
                                          if (detail.profile_id != null) {
                                            await deleteLocalProfile(
                                                detail.profile_id!, context);
                                          } else {
                                            print(
                                                'Tag ID is null, cannot delete profile');
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF3E7FE0),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            '삭제',
                                            textAlign:
                                                TextAlign.center, // 텍스트 중앙 정렬
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isSelected
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: detail.profileImages != null
                                  ? FileImage(File(
                                      detail.profileImages!)) // FileImage 사용
                                  : null,
                              backgroundColor: detail.profileImages == null
                                  ? Colors.red
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              detail.profile_name ?? '기본 태그명',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, bottom: 10, top: 7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // 팝업 닫기
                        Get.toNamed('/profiladde');
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '프로필',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.white,
    );
  }
}
