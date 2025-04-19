import 'dart:async'; // 이 라인을 추가하세요
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/profile_localDB.dart'
    as insertDB;
import 'package:umi/screens/diary_pages/diary_localDB/saveImageOnLocalStorage/saveImageOnLocalStorage.dart';
import 'package:umi/golobalkey.dart';
import 'package:umi/screens/diary_pages/reusable_utils/singural_pic_picker.dart';
import 'package:umi/screens/diary_pages/diary.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';

class ProfileAddScreen extends StatefulWidget {
  const ProfileAddScreen({super.key});

  @override
  ProfileAddScreenState createState() => ProfileAddScreenState();
}

class ProfileAddScreenState extends State<ProfileAddScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _whereTagNameController = TextEditingController();
  final TextEditingController _whoTagNameController = TextEditingController();
  final insertDB.DatabaseHelper _dbHelper = insertDB.DatabaseHelper();
  SaveImageOnLocalStorage saveImage = SaveImageOnLocalStorage();
  final imagePickerController = Get.find<ImagePickerController>();
  final ProfileController profileIdController = Get.find<ProfileController>();
  List<String> bigTags = [
    '포유류',
    '조류',
    '파충류',
    '양서류',
    '관상어',
    '어류',
    '절지동물-갑각류',
    '절지동물-협각류',
    '절지동물-다지류',
    '절지동물-육각류',
    '기타'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Globals.userName;
  }

  @override
  void dispose() {
    imagePickerController.reset();
    super.dispose();
  }

  String? _selectedBigTag;

  Future<void> storeInLocalStorage() async {
    String name = _userNameController.text.trim();
    String location = _whereTagNameController.text.trim();
    String smallCategory = _whoTagNameController.text.trim();

    // 필드가 비어있는지 확인
    if (name.isEmpty || location.isEmpty || smallCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공란이 있습니다. 전부 입력해 주세요')),
      );
      return; // 필드가 비어있으면 데이터베이스 삽입을 중단합니다.
    }

    // 사진 선택 여부 확인
    if (imagePickerController.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 추가해 주세요')),
      );
      return; // 사진이 선택되지 않으면 데이터베이스 삽입을 중단합니다.
    }

    try {
      // 사진 저장
      String? savePath = await saveImage
          .saveProfileImageToAppDir(imagePickerController.selectedImage!);

      // 프로필 정보 설정
      Map<String, dynamic> profile = {
        'profile_name': name,
        'location': location,
        'big_category': _selectedBigTag,
        'small_category': smallCategory,
        'profileImages': savePath,
        'userid': Globals.userName,
      };

      // 프로필을 데이터베이스에 삽입
      await _dbHelper.insertProfile(profile);

      // 방금 추가된 프로필 ID를 가져와서 페이지로 이동
      int? lastProfileId =
          await _dbHelper.getLastProfileId(); // 가장 최근에 추가된 프로필 ID를 가져오는 메서드 필요
      print('$lastProfileId' + '프로필 마지막 ID 확인');
      if (lastProfileId != null) {
        List<Map<String, dynamic>> profileList =
            await _dbHelper.getProfileToshowList(lastProfileId);
        for (var profile in profileList) {
          print('$profile' + '프로필 추가 테스트');
        }
        // GetX 전역변수 업데이트 및 profileImages 출력
        profileIdController.updateListOfProfile(profileList, 1);
        _dbHelper.insertOrUpdateLastUsedProfile(profileList);
        // 페이지 이동
        navigateToProfile();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('데이터 저장에 실패했습니다.')),
      );
    }
  }

  void navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const DiaryPage(
                selectedIndex: 0,
              )), // Replace 'YourScreen' with the name of your screen class
    );
  }

  // Future<void> submitData() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String storedUsername = prefs.getString('username') ?? 'defaultUsername';

  //   final uri = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/profile/add/');

  //   if (_image != null) {
  //     // 이미지가 있을 경우 멀티파트 요청 사용
  //     var request = http.MultipartRequest('POST', uri);

  //     // 텍스트 필드 데이터 추가
  //     request.fields['Diary_user_name'] = storedUsername;
  //     request.fields['Diary_where_tag_name'] = _whereTagNameController.text;
  //     if (_selectedBigTag != null) {
  //       request.fields['Diary_who_Big_tag'] = _selectedBigTag!;
  //     }

  //     request.fields['Diary_who_tag_name'] = _whoTagNameController.text;

  //     // 이미지 파일 추가
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'images',
  //       _image!.path,
  //     ));

  //     try {
  //       var response = await request.send();

  //       if (response.statusCode == 201) {
  //         Get.snackbar(
  //           "추가완료",
  //           "새로운 프로필이 성공적으로 등록되었습니다",
  //         );
  //         print('업로드 성공');

  //         // 추가적인 성공 처리 로직
  //         // 예: 사용자에게 성공 메시지 표시
  //       } else {
  //         print('업로드 실패: ${response.statusCode}');
  //         Get.snackbar(
  //           "추가실패",
  //           "새로운 프로필이 등록실패하였습니다",
  //         );
  //         // 실패 처리 로직
  //         // 예: 사용자에게 오류 메시지 표시
  //       }
  //     } catch (e) {
  //       print('업로드 중 오류 발생: $e');
  //       // 예외 처리
  //       // 예: 사용자에게 오류 메시지 표시
  //     }
  //   } else {
  //     // 이미지가 없을 경우 일반 POST 요청 사용
  //     try {
  //       var response = await http.post(
  //         uri,
  //         headers: {
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode({
  //           'Diary_user_name': _userNameController.text,
  //           'Diary_where_tag_name': _whereTagNameController.text,
  //           'Diary_who_Big_tag': _whoBigTagController.text,
  //           'Diary_who_tag_name': _whoTagNameController.text,
  //         }),
  //       );

  //       if (response.statusCode == 201) {
  //         Get.snackbar(
  //           "추가완료",
  //           "새로운 프로필이 성공적으로 등록되었습니다",
  //         );
  //         print('업로드 성공');
  //         // 추가적인 성공 처리 로직
  //       } else {
  //         print('업로드 실패: ${response.statusCode}');
  //         Get.snackbar(
  //           "추가실패",
  //           "새로운 프로필이 등록실패하였습니다",
  //         );
  //         // 실패 처리 로직
  //       }
  //     } catch (e) {
  //       print('업로드 중 오류 발생: $e');
  //       // 예외 처리
  //     }
  //   }
  // }

  // Usecase
  // 1. 온라인 : 서버DB와 로컬DB양쪽에 저장
  // 2. 오프라인 : 로컬DB에만 저장
  // 3. 오프라인 => 온라인 전환 :

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // AppBar의 기본 높이를 사용
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 240, 240, 240), // 원하는 테두리 색상
                width: 2, // 원하는 테두리 두께
              ),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            centerTitle: true,
            title: const Text(
              '프로필 추가',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 42, 42, 43),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            right: 40, left: 40, top: 120), // 원하는 패딩 값을 지정합니다.
        child: Column(
          children: [
            GestureDetector(
              onTap: () => imagePickerController.showPicker(context),
              child: Obx(() {
                // Obx 위젯으로 감싸기
                final selectedImage = imagePickerController.selectedImage;
                return selectedImage != null
                    ? ClipOval(
                        child: SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: Image.file(
                            File(selectedImage.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.white,
                        ),
                      );
              }),
            ),

            // 텍스트 필드
            const SizedBox(height: 50),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: '이름',
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 42, 42, 43),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        const Color.fromARGB(255, 42, 42, 43).withOpacity(0.5),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 42, 42, 43),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _whereTagNameController,
              decoration: InputDecoration(
                labelText: '위치',
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 42, 42, 43),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        const Color.fromARGB(255, 42, 42, 43).withOpacity(0.5),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 42, 42, 43),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: _selectedBigTag,
              items: bigTags.map((String tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedBigTag = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: '대분류',
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 42, 42, 43),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        const Color.fromARGB(255, 42, 42, 43).withOpacity(0.5),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 42, 42, 43),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _whoTagNameController,
              decoration: InputDecoration(
                labelText: '소분류',
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 42, 42, 43),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        const Color.fromARGB(255, 42, 42, 43).withOpacity(0.5),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 42, 42, 43),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: storeInLocalStorage, // submitData 메서드 호출
              child: const Text('프로필 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
