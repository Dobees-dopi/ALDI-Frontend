import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umi/screens/diary_pages/reusable_utils/singural_pic_picker.dart';

class ProfileAddScreen extends StatefulWidget {
  @override
  _ProfileAddScreenState createState() => _ProfileAddScreenState();
}

class _ProfileAddScreenState extends State<ProfileAddScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _whereTagNameController = TextEditingController();
  final TextEditingController _whoBigTagController = TextEditingController();
  final TextEditingController _whoTagNameController = TextEditingController();
  File? _image;
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
  String? _selectedBigTag;
  final imagePickerController = Get.find<ImagePickerController>();

  // ----------   f

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

  @override
  void dispose() {
    imagePickerController.reset();
    super.dispose();
  }

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
            Obx(() => GestureDetector(
                  onTap: () => imagePickerController.showPicker(context),
                  child: imagePickerController.selectedImage != null
                      ? ClipOval(
                          child: SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: Image.file(
                                File(imagePickerController.selectedImage!.path),
                                fit: BoxFit.cover),
                          ),
                        )
                      : Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Icon(
                            Icons.camera_alt, // 카메라 아이콘
                            size: 30, // 아이콘 크기
                            color: Colors.white,
                          ),
                        ),
                )),

            // 텍스트 필드
            const SizedBox(height: 50),
            TextField(
              controller: _whereTagNameController,
              decoration: InputDecoration(
                labelText: '사육장소 이름',
                labelStyle: TextStyle(color: Color(0xFF000000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                      color: Color(0xFF3E7FE0)), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedBigTag, // 현재 선택된 값
              hint: Text('큰 태그를 선택하세요'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBigTag = newValue;
                });
              },
              items: bigTags.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: '큰 태그',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                      color: Color(0xFF3E7FE0)), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _whoTagNameController,
              decoration: InputDecoration(
                labelText: '세부 태그 이름',
                labelStyle: TextStyle(color: Color(0xFF000000)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                      color: Color(0xFF3E7FE0)), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                ),
              ),
            ),
            // 제출 버튼
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF3E7FE0)),
                //elevation: MaterialStateProperty.all<double>(15.10),
                shadowColor: MaterialStateProperty.all<Color>(Colors.black38),
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(top: 15, bottom: 15, right: 40, left: 40),
                child: Text(
                  '추가하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
