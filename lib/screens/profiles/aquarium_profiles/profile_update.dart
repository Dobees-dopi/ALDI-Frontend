import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileupScreen extends StatefulWidget {
  @override
  _ProfileupScreenState createState() => _ProfileupScreenState();
}

class _ProfileupScreenState extends State<ProfileupScreen> {
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
  String diaryWhereTagId = "yourWhereTagId";

  @override
  void initState() {
    super.initState();
    yourFunction(); // 페이지가 로드될 때 함수 실행
  }

  Future<void> yourFunction() async {
    String? storedTagId = await loadFromSharedPreferences('selectedTagId');

    if (storedTagId != null) {
      // 저장된 Tag ID를 사용하는 로직
      print("Loaded Tag ID: $storedTagId");
      diaryWhereTagId = storedTagId;
      print("잔쩌: $diaryWhereTagId");

      // 추가적인 동작 수행
    } else {
      // Tag ID가 저장되어 있지 않은 경우의 처리
      print("No Tag ID saved in SharedPreferences");
    }
  }

  Future<String?> loadFromSharedPreferences(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

// ... 기타 코드 ...

  Future<void> pickImage() async {
    // Helper function to set the image
    void _setImage(XFile? pickedFile) {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }

    // Function to handle permission requests
    Future<bool> requestPermission(Permission permission) async {
      final status = await permission.request();
      return status.isGranted;
    }

    // Function to show a dialog for choosing between Camera and Gallery
    void _showPicker(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('갤러리'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      if (await requestPermission(Permission.photos)) {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        _setImage(pickedFile);
                      }
                    },
                  ),
                  ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('카메라'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      if (await requestPermission(Permission.camera)) {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        _setImage(pickedFile);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    _showPicker(context); // Show the picker when the button is pressed
  }

  Future<void> submitData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedUsername = prefs.getString('username') ?? 'defaultUsername';
    //String diaryWhereTagId = "yourWhereTagId"; // 이 값을 적절하게 설정하거나 가져와야 합니다.

    final uri = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/profile/update/');

    if (_image != null) {
      // 이미지가 있을 경우 멀티파트 요청 사용 (PUT)
      var request = http.MultipartRequest('PUT', uri);

      // 텍스트 필드 데이터 추가
      request.fields['Diary_where_tag_id'] = diaryWhereTagId;
      request.fields['Diary_user_name'] = storedUsername;
      request.fields['Diary_where_tag_name'] = _whereTagNameController.text;
      if (_selectedBigTag != null) {
        request.fields['Diary_who_Big_tag'] = _selectedBigTag!;
      }
      request.fields['Diary_who_tag_name'] = _whoTagNameController.text;

      // 이미지 파일 추가
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        _image!.path,
      ));

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          // PUT 요청 성공 처리
          print('업로드 성공');
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
          Get.snackbar("업데이트완료", "새로운 프로필이 성공적으로 업데이트되었습니다");
          Get.back();
        } else {
          // PUT 요청 실패 처리
          print('업로드 실패: ${response}');
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
          Get.snackbar("업데이트실패", "새로운 프로필이 업데이트실패하였습니다");
        }
      } catch (e) {
        // 예외 처리
        print('업로드 중 오류 발생: $e');
      }
    } else {
      // 이미지가 없을 경우 일반 PUT 요청 사용
      try {
        var response = await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'Diary_where_tag_id': diaryWhereTagId,
            'Diary_user_name': storedUsername,
            'Diary_where_tag_name': _whereTagNameController.text,
            'Diary_who_Big_tag': _whoBigTagController.text,
            'Diary_who_tag_name': _whoTagNameController.text,
          }),
        );

        if (response.statusCode == 200) {
          // PUT 요청 성공 처리
          print('업로드 성공');
          String responseBody = utf8.decode(response.bodyBytes); // UTF-8로 디코딩
          print('업로드 성공: $responseBody');
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
          Get.snackbar("업데이트 완료", "새로운 프로필이 성공적으로 업데이트되었습니다");
          Get.back();
        } else {
          // PUT 요청 실패 처리
          print('업로드 실패: ${response.statusCode}');
          String responseBody = utf8.decode(response.bodyBytes); // UTF-8로 디코딩
          print('업로드 실패: $responseBody');
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
          Get.snackbar("업데이트 실패", "새로운 프로필이 업데이트실패하였습니다");
        }
      } catch (e) {
        // 예외 처리
        print('업로드 중 오류 발생: $e');
      }
    }
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
              '프로필 업데이트',
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
              onTap: pickImage, // Call pickImage method when tapped
              child: _image != null
                  ? ClipOval(
                      child: SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: Image.file(_image!, fit: BoxFit.cover),
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
            ),

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
              onPressed: submitData,
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
                  '제출하기',
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
